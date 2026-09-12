import test, { before, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { initializeApp, deleteApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, collection, getDocs, query, where } from 'firebase/firestore';
import { createBackend } from '../backend.js';

// Refuse to connect to a real project when this test is run without an emulator.
assert.ok(process.env.FIRESTORE_EMULATOR_HOST, 'Start the Firestore emulator first.');
const projectId = 'demo-rentit-services';
const app = initializeApp({ projectId }, 'rentit-tests');
const db = getFirestore(app);
const admin = { uid: 'admin', token: { admin: true } };
const client = { uid: 'client1', token: {} };
const other = { uid: 'client2', token: {} };
let currentTime = Date.parse('2026-10-01T08:00:00Z');
const handle = createBackend({ db, Timestamp, clock: () => currentTime,
  authAdmin: { getUser: async (uid) => ({ email: `${uid}@example.test`, customClaims: {} }) } });
const call = (action, input = {}, auth = admin) => handle({ auth, data: { action, input } });
const hasCode = (code) => (error) => error.code === code;
let environment;

before(async () => {
  const [host, port] = process.env.FIRESTORE_EMULATOR_HOST.split(':');
  environment = await initializeTestEnvironment({ projectId, firestore: {
    host, port: Number(port), rules: await readFile(new URL('../../firestore.rules', import.meta.url), 'utf8'),
  } });
  await environment.clearFirestore();
});

after(async () => {
  await environment?.cleanup();
  await deleteApp(app);
});

test('CRUD, protected profiles, quotes, concurrent confirmation and cancellation', async () => {
  await assert.rejects(() => call('items.create', {}, null), hasCode('unauthenticated'));
  await assert.rejects(() => call('items.create', {}, client), hasCode('permission-denied'));
  await call('users.create', { name: 'Client', phone: '', role: 'admin' }, client);
  await call('users.create', { name: 'Other', phone: '' }, other);
  const user = await call('users.get', { id: client.uid }, client);
  assert.equal(user.role, 'client');
  assert.equal(user.email, 'client1@example.test');
  await assert.rejects(() => call('users.update', { id: other.uid, name: 'Hacked', phone: '' }, client), hasCode('permission-denied'));
  const changed = await call('users.update', { id: client.uid, name: 'New name', phone: '123', role: 'admin' }, client);
  assert.equal(changed.role, 'client');
  assert.equal(changed.name, 'New name');

  await call('categories.create', { id: 'c1', name: 'Caméras', imageUrl: '' });
  const itemInput = { id: 'i1', name: 'Camera', description: '', categoryId: 'c1', imageUrl: '',
    pricePerHourCents: 1250, quantity: 1, status: 'available' };
  const item = await call('items.create', itemInput);
  assert.equal(item.pricePerDay, 300);
  await assert.rejects(() => call('categories.delete', { id: 'c1' }), hasCode('conflict'));
  const input = { itemId: 'i1', startDate: '2026-10-01T10:00:00.000Z', endDate: '2026-10-01T11:30:00.000Z',
    expectedPricePerHourCents: 1250 };
  const estimate = await call('rentals.quote', input, client);
  assert.equal(estimate.totalPriceCents, 1875);
  assert.equal((await call('rentals.availability', input, client)).availableQuantity, 1);
  const first = await call('rentals.create', { ...input, requestId: 'request1', userId: 'victim', totalPrice: 0 }, client);
  assert.equal(first.userId, client.uid);
  assert.equal(first.totalPrice, 18.75);
  assert.equal(first.duration, 1);
  assert.equal((await call('rentals.create', { ...input, requestId: 'request1' }, client)).id, first.id);
  await assert.rejects(() => call('rentals.create', { ...input, requestId: 'request1', endDate: '2026-10-01T12:00:00Z' }, client), hasCode('conflict'));
  const second = await call('rentals.create', { ...input, requestId: 'request2' }, other);
  const confirmations = await Promise.allSettled([
    call('rentals.update', { id: first.id, status: 'confirmed' }),
    call('rentals.update', { id: second.id, status: 'confirmed' }),
  ]);
  assert.equal(confirmations.filter((r) => r.status === 'fulfilled').length, 1);
  assert.equal(confirmations.find((r) => r.status === 'rejected').reason.code, 'unavailable-stock');
  const winner = confirmations.find((r) => r.status === 'fulfilled').value;
  assert.equal((await call('rentals.availability', input, client)).available, false);
  await assert.rejects(() => call('items.update', { ...itemInput, quantity: 0 }), hasCode('conflict'));
  await assert.rejects(() => call('items.update', { ...itemInput, status: 'maintenance' }), hasCode('conflict'));
  await assert.rejects(() => call('items.delete', { id: 'i1' }), hasCode('conflict'));
  await assert.rejects(() => call('users.delete', { id: client.uid }), hasCode('conflict'));
  await assert.rejects(() => call('rentals.delete', { id: winner.id }, winner.userId === client.uid ? other : client), hasCode('permission-denied'));
  await call('rentals.delete', { id: winner.id });
  assert.equal((await call('rentals.availability', input, client)).available, true);
  const owner = winner.userId === client.uid ? client : other;
  const requestId = winner.userId === client.uid ? 'request1' : 'request2';
  assert.equal((await call('rentals.create', { ...input, requestId }, owner)).status, 'cancelled');
  await call('items.update', { ...itemInput, pricePerHourCents: 1500 });
  await assert.rejects(() => call('rentals.create', { ...input, requestId: 'request3' }, client), hasCode('price-changed'));
  await call('users.create', { name: 'Temporary', phone: '' }, { uid: 'temporary', token: {} });
  await call('users.delete', { id: 'temporary' });
  await call('items.create', { ...itemInput, id: 'temporary-item' });
  await call('items.delete', { id: 'temporary-item' });
  await call('categories.create', { id: 'temporary-category', name: 'Temp', imageUrl: '' });
  await call('categories.update', { id: 'temporary-category', name: 'Updated', imageUrl: '' });
  await call('categories.delete', { id: 'temporary-category' });
});

test('Firestore rules deny direct mutations and cross-user reads', async () => {
  const userDb = environment.authenticatedContext(client.uid).firestore();
  const otherDb = environment.authenticatedContext(other.uid).firestore();
  const adminDb = environment.authenticatedContext('admin', { admin: true }).firestore();
  const anonymousDb = environment.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(userDb, 'users', client.uid)));
  await assertFails(getDoc(doc(otherDb, 'users', client.uid)));
  await assertFails(getDoc(doc(anonymousDb, 'items', 'i1')));
  await assertSucceeds(getDoc(doc(userDb, 'items', 'i1')));
  await assertFails(setDoc(doc(userDb, 'users', client.uid), { role: 'admin' }));
  await assertFails(setDoc(doc(adminDb, 'items', 'i1'), { quantity: 99 }));
  await assertFails(setDoc(doc(userDb, 'rentals', 'forged'), { userId: client.uid, status: 'confirmed' }));
  await assertFails(getDoc(doc(userDb, 'inventoryLocks', 'i1')));
  await assertFails(getDocs(collection(userDb, 'rentals')));
  await assertSucceeds(getDocs(query(collection(userDb, 'rentals'), where('userId', '==', client.uid))));
  await assertSucceeds(getDocs(collection(adminDb, 'rentals')));
});
