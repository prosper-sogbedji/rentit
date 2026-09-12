import test from 'node:test';
import assert from 'node:assert/strict';
import { period, quote, peakOccupancy, requireAdmin, requireOwner, transition, id } from '../domain.js';

const at = (ms) => ({ toMillis: () => ms });
const rental = (a, b, status = 'confirmed') => ({ startDate: at(a), endDate: at(b), status });
const client = { uid: 'u1', token: {} };
const admin = { uid: 'admin', token: { admin: true } };
const hasCode = (code) => (error) => error.code === code;

test('hourly proportional price and single cent rounding', () => {
  assert.equal(quote(1250, 90).totalPriceCents, 1875);
  assert.equal(quote(100, 1).totalPriceCents, 2);
  assert.equal(quote(1, 30).totalPriceCents, 1);
  assert.equal(quote(1, 29).totalPriceCents, 0);
  assert.equal(quote(1250, 1440).totalPriceCents, 30000);
});

test('reject invalid money, duration and overflow', () => {
  for (const rate of [0, -1, 0.5, NaN, Infinity, '1250']) {
    assert.throws(() => quote(rate, 60), hasCode('invalid-argument'));
  }
  assert.throws(() => quote(100, 0), hasCode('invalid-argument'));
  assert.throws(() => quote(1e9, 1e9), hasCode('invalid-argument'));
});

test('UTC periods accept Dart ISO and reject invalid calendar dates and fractions', () => {
  assert.equal(period('2026-10-01T10:00:00.000Z', '2026-10-01T11:30:00Z').durationMinutes, 90);
  for (const start of ['2026-02-30T10:00:00Z', '2026-10-01T10:00:01Z',
    '2026-10-01T10:00:00+01:00', '2026-10-01T10:00:00.001Z', 'invalid']) {
    assert.throws(() => period(start, '2026-10-01T11:00:00Z'), hasCode('invalid-argument'));
  }
  assert.throws(() => period('2026-10-01T10:00:00Z', '2026-10-01T10:00:00Z'), hasCode('invalid-argument'));
});

test('availability counts simultaneous occupancy, not all touching reservations', () => {
  assert.equal(peakOccupancy([rental(0, 10), rental(10, 20)], 0, 20), 1);
  assert.equal(peakOccupancy([rental(0, 15), rental(10, 20)], 0, 20), 2);
  assert.equal(peakOccupancy([rental(0, 10)], 10, 20), 0);
  assert.equal(peakOccupancy([rental(0, 30), rental(10, 20, 'pending')], 10, 20), 1);
  assert.equal(peakOccupancy([rental(0, 30, 'cancelled')], 10, 20), 0);
});

test('authorization uses Auth admin claim, not profile role or request input', () => {
  assert.throws(() => requireAdmin(null), hasCode('unauthenticated'));
  assert.throws(() => requireAdmin({ ...client, role: 'admin' }), hasCode('permission-denied'));
  assert.throws(() => requireOwner(client, 'u2'), hasCode('permission-denied'));
  requireAdmin(admin);
  requireOwner(admin, 'u2');
});

test('rental transitions enforce role, owner, time and terminal states', () => {
  const pending = { ...rental(100, 200, 'pending'), userId: 'u1' };
  assert.throws(() => transition(pending, 'confirmed', client, 50), hasCode('permission-denied'));
  assert.equal(transition(pending, 'confirmed', admin, 50), true);
  assert.equal(transition(pending, 'cancelled', client, 50), true);
  assert.throws(() => transition(pending, 'confirmed', admin, 100), hasCode('invalid-transition'));
  const confirmed = { ...pending, status: 'confirmed' };
  assert.equal(transition(confirmed, 'confirmed', admin, 50), false);
  assert.throws(() => transition(confirmed, 'cancelled', client, 100), hasCode('invalid-transition'));
  assert.throws(() => transition(confirmed, 'completed', admin, 199), hasCode('invalid-transition'));
  assert.equal(transition(confirmed, 'completed', admin, 200), true);
  assert.throws(() => transition({ ...pending, status: 'cancelled' }, 'confirmed', admin, 50), hasCode('invalid-transition'));
});

test('document identifiers cannot escape their collection', () => {
  for (const key of ['', ' ', '../users', '.', '..']) {
    assert.throws(() => id(key), hasCode('invalid-argument'));
  }
});
