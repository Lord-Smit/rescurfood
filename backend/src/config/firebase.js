const admin = require('firebase-admin');
const { firebaseProjectId, firebaseClientEmail, firebasePrivateKey } = require('./env');

const cleanPrivateKey = (key) => {
  if (!key) return undefined;
  let formatted = key.trim();
  // Strip quotes if wrapped
  if ((formatted.startsWith('"') && formatted.endsWith('"')) || (formatted.startsWith("'") && formatted.endsWith("'"))) {
    formatted = formatted.slice(1, -1);
  }
  // Replace escaped newlines
  return formatted.replace(/\\n/g, '\n');
};

let initialized = false;

if (firebaseClientEmail && firebasePrivateKey) {
  try {
    const key = cleanPrivateKey(firebasePrivateKey);
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: firebaseProjectId,
        clientEmail: firebaseClientEmail,
        privateKey: key,
      }),
    });
    initialized = true;
    console.log('Firebase Admin initialized with service account certificate');
  } catch (err) {
    console.error('Firebase Admin cert initialization error:', err.message);
  }
}

if (!initialized) {
  admin.initializeApp({ projectId: firebaseProjectId });
  console.warn('Firebase Admin initialized with project ID only');
}

const db = admin.firestore();

module.exports = { admin, db };
