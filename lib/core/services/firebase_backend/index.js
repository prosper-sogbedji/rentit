import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import { createBackend } from './backend.js';
import { ServiceError } from './domain.js';

initializeApp();
const handle = createBackend({ db: getFirestore(), Timestamp, authAdmin: getAuth() });
const businessCodes = new Set(['conflict', 'invalid-transition', 'price-changed', 'unavailable-stock']);

export const rentIt = onCall({ region: 'europe-west1' }, async (request) => {
  try {
    return await handle(request);
  } catch (error) {
    if (error instanceof ServiceError) {
      throw new HttpsError(businessCodes.has(error.code) ? 'failed-precondition' : error.code,
        error.message, { code: error.code });
    }
    logger.error('RentIt operation failed', { action: request.data?.action, code: error.code });
    throw new HttpsError('internal', 'Opération impossible. Réessayer avec le même identifiant de demande.');
  }
});
