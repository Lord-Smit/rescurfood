const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', '..', '.env') });

module.exports = {
  port: process.env.PORT || 5000,
  jwtSecret: process.env.JWT_SECRET || 'fallback_dev_secret',
  jwtExpire: '7d',
  firebaseProjectId: process.env.FIREBASE_PROJECT_ID || 'foodlink-007',
  firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
  firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY || '',
};
