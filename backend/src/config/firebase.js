const admin = require('firebase-admin');
const { firebaseProjectId, firebaseClientEmail, firebasePrivateKey } = require('./env');

if (firebaseClientEmail && firebasePrivateKey) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: firebaseProjectId,
      clientEmail: firebaseClientEmail,
      privateKey: firebasePrivateKey.replace(/\\n/g, '\n'),
    }),
  });
  console.log('Firebase Admin initialized with service account');
} else {
  admin.initializeApp({ projectId: firebaseProjectId });
  console.warn('Firebase Admin initialized with project ID only — set FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY in .env for full access');
}

const db = admin.firestore();

module.exports = { admin, db };
