export class ServiceError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

export function check(condition, code, message) {
  if (!condition) throw new ServiceError(code, message);
}

export function text(value, field, { empty = false, max = 2000 } = {}) {
  check(typeof value === 'string' && value.length <= max &&
    (empty || value.trim().length > 0), 'invalid-argument', `${field} invalide.`);
  return value.trim();
}

export function id(value) {
  const result = text(value, 'id', { max: 128 });
  check(!result.includes('/') && result !== '.' && result !== '..',
    'invalid-argument', 'Identifiant invalide.');
  return result;
}

export function integer(value, field, min = 0, max = 1000000000) {
  check(Number.isSafeInteger(value) && value >= min && value <= max,
    'invalid-argument', `${field} invalide.`);
  return value;
}

export function period(startDate, endDate) {
  const parse = (value) => {
    check(typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:00(?:\.000)?Z$/.test(value),
      'invalid-argument', 'Dates UTC requises, à la minute exacte.');
    const ms = Date.parse(value);
    check(Number.isFinite(ms) && new Date(ms).toISOString() === (value.includes('.') ? value : value.replace('Z', '.000Z')),
      'invalid-argument', 'Date invalide.');
    return ms;
  };
  const start = parse(startDate);
  const end = parse(endDate);
  check(end > start, 'invalid-argument', 'La fin doit être après le début.');
  return { start, end, durationMinutes: (end - start) / 60000 };
}

export function quote(pricePerHourCents, durationMinutes) {
  integer(pricePerHourCents, 'pricePerHourCents', 1);
  integer(durationMinutes, 'durationMinutes', 1);
  const numerator = BigInt(pricePerHourCents) * BigInt(durationMinutes);
  const total = (numerator + 30n) / 60n;
  check(total <= BigInt(Number.MAX_SAFE_INTEGER), 'invalid-argument', 'Montant trop élevé.');
  return { pricePerHourCents, durationMinutes, totalPriceCents: Number(total), currency: 'USD' };
}

// Half-open intervals: release capacity before allocating at the same instant.
export function peakOccupancy(rentals, start, end) {
  const events = [];
  for (const rental of rentals) {
    if (rental.status !== 'confirmed') continue;
    const a = rental.startDate.toMillis();
    const b = rental.endDate.toMillis();
    if (a < end && b > start) {
      events.push([Math.max(a, start), 1], [Math.min(b, end), -1]);
    }
  }
  events.sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  let current = 0;
  let peak = 0;
  for (const [, delta] of events) {
    current += delta;
    peak = Math.max(peak, current);
  }
  return peak;
}

export function requireAuth(auth) {
  check(auth?.uid, 'unauthenticated', 'Connexion requise.');
  return auth.uid;
}

export function requireAdmin(auth) {
  requireAuth(auth);
  check(auth.token?.admin === true, 'permission-denied', 'Accès administrateur requis.');
}

export function requireOwner(auth, userId) {
  requireAuth(auth);
  check(auth.uid === userId || auth.token?.admin === true,
    'permission-denied', 'Accès refusé.');
}

export function transition(rental, next, auth, now) {
  requireOwner(auth, rental.userId);
  check(['confirmed', 'cancelled', 'completed'].includes(next),
    'invalid-argument', 'Statut cible invalide.');
  if (next !== 'cancelled') requireAdmin(auth);
  if (rental.status === next) return false;
  const allowed = {
    pending: ['confirmed', 'cancelled'],
    confirmed: ['cancelled', 'completed'],
    cancelled: [],
    completed: [],
  };
  check(allowed[rental.status]?.includes(next), 'invalid-transition', 'Transition interdite.');
  if (next === 'completed') {
    check(now >= rental.endDate.toMillis(), 'invalid-transition', 'Location non terminée.');
  } else if (rental.status === 'confirmed' || next === 'confirmed') {
    check(now < rental.startDate.toMillis(), 'invalid-transition', 'La location a déjà commencé.');
  }
  return true;
}
