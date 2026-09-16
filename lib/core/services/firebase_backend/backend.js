import {
  check, id, integer, text, period, quote, peakOccupancy,
  requireAuth, requireAdmin, requireOwner, transition,
} from './domain.js';

// Inject the Admin SDK for emulator tests; never expose an Admin SDK in Flutter.
export function createBackend({ db, Timestamp, authAdmin, clock = Date.now }) {
  const doc = (collection, key) => db.collection(collection).doc(id(key));
  const now = () => Timestamp.fromMillis(clock());
  const dataOf = (snapshot) => {
    check(snapshot.exists, 'not-found', 'Document introuvable.');
    return snapshot.data();
  };
  const wire = (value) => {
    if (value && typeof value.toDate === 'function') return value.toDate().toISOString();
    if (Array.isArray(value)) return value.map(wire);
    if (value && typeof value === 'object') {
      return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, wire(v)]));
    }
    return value;
  };
  const read = async (collection, key) => {
    const ref = doc(collection, key);
    return wire({ ...dataOf(await ref.get()), id: ref.id });
  };
  const rentalsFor = (itemId) => db.collection('rentals')
    .where('itemId', '==', itemId).where('status', '==', 'confirmed');
  const lockFor = (itemId) => doc('inventoryLocks', itemId);
  const touchLock = (tx, lock, snapshot) => tx.set(lock, {
    revision: (snapshot.data()?.revision ?? 0) + 1,
  });

  async function profile(action, input, auth) {
    const uid = action === 'users.create' ? auth.uid : id(input.id);
    requireOwner(auth, uid);
    if (action === 'users.get') return read('users', uid);
    if (action === 'users.delete') requireAdmin(auth);
    const ref = doc('users', uid);
    // Identity data and permissions are sourced from Auth, never from input.
    const identity = action === 'users.create' ? await authAdmin.getUser(uid) : null;
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      if (action === 'users.create') {
        if (existing.exists) return;
        check(identity.email, 'invalid-argument', 'Adresse email Auth requise.');
        tx.create(ref, {
          name: text(input.name, 'name', { max: 120 }),
          phone: text(input.phone, 'phone', { empty: true, max: 40 }),
          email: identity.email,
          role: identity.customClaims?.admin === true ? 'admin' : 'client',
          createdAt: now(),
        });
      } else {
        dataOf(existing);
        if (action === 'users.update') {
          tx.update(ref, {
            name: text(input.name, 'name', { max: 120 }),
            phone: text(input.phone, 'phone', { empty: true, max: 40 }),
          });
        } else {
          const rentals = await tx.get(db.collection('rentals').where('userId', '==', uid).limit(1));
          check(rentals.empty, 'conflict', 'Profil référencé par une location.');
          tx.delete(ref);
        }
      }
    });
    return action === 'users.delete' ? null : read('users', uid);
  }

  async function catalogue(action, input, auth) {
    requireAdmin(auth);
    const [collection, operation] = action.split('.');
    const ref = doc(collection, input.id);
    await db.runTransaction(async (tx) => {
      const snapshot = await tx.get(ref);
      if (operation === 'create') check(!snapshot.exists, 'conflict', 'Identifiant déjà utilisé.');
      else dataOf(snapshot);
      if (collection === 'categories') {
        if (operation === 'delete') {
          const children = await tx.get(db.collection('items').where('categoryId', '==', ref.id).limit(1));
          check(children.empty, 'conflict', 'Catégorie utilisée par un article.');
          tx.delete(ref);
        } else {
          tx.set(ref, {
            name: text(input.name, 'name', { max: 120 }),
            imageUrl: text(input.imageUrl, 'imageUrl', { empty: true }),
          });
        }
        return;
      }
      const lock = lockFor(ref.id);
      const lockSnapshot = await tx.get(lock);
      const history = await tx.get(db.collection('rentals').where('itemId', '==', ref.id));
      if (operation === 'delete') {
        check(history.empty, 'conflict', 'Article référencé par une location.');
        tx.delete(ref);
        touchLock(tx, lock, lockSnapshot);
        return;
      }
      const categoryId = id(input.categoryId);
      dataOf(await tx.get(doc('categories', categoryId)));
      const quantity = integer(input.quantity, 'quantity');
      const pricePerHourCents = integer(input.pricePerHourCents, 'pricePerHourCents', 1);
      check(['available', 'unavailable', 'maintenance'].includes(input.status),
        'invalid-argument', 'Statut article invalide.');
      const peak = peakOccupancy(history.docs.map((d) => d.data()), clock(), Infinity);
      check(quantity >= peak, 'conflict', 'Stock inférieur aux réservations confirmées.');
      check(input.status === 'available' || peak === 0, 'conflict', 'Réservations confirmées à honorer.');
      tx.set(ref, {
        name: text(input.name, 'name', { max: 120 }),
        description: text(input.description, 'description', { empty: true, max: 10000 }),
        categoryId,
        imageUrl: text(input.imageUrl, 'imageUrl', { empty: true }),
        pricePerHourCents,
        // Compatibility projection only: authoritative price is hourly cents.
        pricePerDay: pricePerHourCents * 24 / 100,
        currency: 'USD', quantity, status: input.status,
        createdAt: snapshot.data()?.createdAt ?? now(), updatedAt: now(),
      });
      touchLock(tx, lock, lockSnapshot);
    });
    return operation === 'delete' ? null : read(collection, ref.id);
  }

  async function getQuote(input) {
    const window = period(input.startDate, input.endDate);
    const item = dataOf(await doc('items', input.itemId).get());
    check(Number.isSafeInteger(item.pricePerHourCents), 'conflict',
      'Tarif horaire absent : renseigner explicitement le tarif de cet article.');
    return quote(item.pricePerHourCents, window.durationMinutes);
  }

  async function availability(input) {
    const { start, end } = period(input.startDate, input.endDate);
    const itemRef = doc('items', input.itemId);
    return db.runTransaction(async (tx) => {
      const item = dataOf(await tx.get(itemRef));
      const rentals = await tx.get(rentalsFor(itemRef.id));
      const availableQuantity = item.status === 'available'
        ? Math.max(0, item.quantity - peakOccupancy(rentals.docs.map((d) => d.data()), start, end)) : 0;
      return { available: availableQuantity >= 1, availableQuantity };
    });
  }

  async function createRental(input, auth) {
    const itemId = id(input.itemId);
    const requestId = id(input.requestId);
    const window = period(input.startDate, input.endDate);
    integer(input.expectedPricePerHourCents, 'expectedPricePerHourCents', 1);
    const receipt = db.collection('reservationRequests').doc(auth.uid).collection('requests').doc(requestId);
    const payload = {
      itemId, startDate: new Date(window.start).toISOString(),
      endDate: new Date(window.end).toISOString(),
      expectedPricePerHourCents: input.expectedPricePerHourCents,
    };
    const rentalRef = db.collection('rentals').doc();
    const rentalId = await db.runTransaction(async (tx) => {
      const previous = await tx.get(receipt);
      if (previous.exists) {
        check(Object.keys(payload).every((key) => previous.data().payload[key] === payload[key]),
        'conflict', 'requestId déjà utilisé avec une autre demande.');
        return previous.data().rentalId;
      }
      check(window.start > clock(), 'invalid-argument', 'Le début doit être dans le futur.');
      dataOf(await tx.get(doc('users', auth.uid)));
      const item = dataOf(await tx.get(doc('items', itemId)));
      check(item.status === 'available' && item.quantity > 0, 'unavailable-stock', 'Article indisponible.');
      check(item.pricePerHourCents === input.expectedPricePerHourCents,
        'price-changed', 'Le tarif a changé : demander un nouveau devis.');
      const price = quote(item.pricePerHourCents, window.durationMinutes);
      const timestamp = now();
      tx.create(rentalRef, {
        userId: auth.uid, itemId,
        startDate: Timestamp.fromMillis(window.start), endDate: Timestamp.fromMillis(window.end),
        duration: Math.ceil(window.durationMinutes / 1440),
        ...price, totalPrice: price.totalPriceCents / 100,
        status: 'pending', createdAt: timestamp, updatedAt: timestamp,
      });
      tx.create(receipt, { rentalId: rentalRef.id, payload });
      return rentalRef.id;
    });
    return read('rentals', rentalId);
  }

  async function updateRental(input, auth) {
    const rentalRef = doc('rentals', input.id);
    await db.runTransaction(async (tx) => {
      const rental = dataOf(await tx.get(rentalRef));
      if (!transition(rental, input.status, auth, clock())) return;
      const itemRef = doc('items', rental.itemId);
      const item = dataOf(await tx.get(itemRef));
      const lock = lockFor(rental.itemId);
      const lockSnapshot = await tx.get(lock);
      if (input.status === 'confirmed') {
        const existing = await tx.get(rentalsFor(rental.itemId));
        const peak = peakOccupancy(existing.docs.map((d) => d.data()),
          rental.startDate.toMillis(), rental.endDate.toMillis());
        check(item.status === 'available' && peak < item.quantity,
          'unavailable-stock', 'Stock insuffisant pour cette période.');
      }
      tx.update(rentalRef, { status: input.status, updatedAt: now() });
      touchLock(tx, lock, lockSnapshot);
    });
    return read('rentals', rentalRef.id);
  }

  const actions = new Set([
    'users.create', 'users.get', 'users.update', 'users.delete',
    'categories.create', 'categories.update', 'categories.delete',
    'items.create', 'items.update', 'items.delete',
    'rentals.quote', 'rentals.availability', 'rentals.create', 'rentals.update', 'rentals.delete',
  ]);
  return async function handle(request) {
    requireAuth(request.auth);
    const { action, input = {} } = request.data ?? {};
    check(actions.has(action), 'invalid-argument', 'Action inconnue.');
    check(input && typeof input === 'object' && !Array.isArray(input), 'invalid-argument', 'Entrée invalide.');
    if (action.startsWith('users.')) return profile(action, input, request.auth);
    if (action.startsWith('items.') || action.startsWith('categories.')) return catalogue(action, input, request.auth);
    if (action === 'rentals.quote') return getQuote(input);
    if (action === 'rentals.availability') return availability(input);
    if (action === 'rentals.create') return createRental(input, request.auth);
    // Deletion means cancellation: keep the audit history and idempotency receipt.
    return updateRental(action === 'rentals.delete' ? { ...input, status: 'cancelled' } : input, request.auth);
  };
}
