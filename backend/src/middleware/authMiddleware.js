const jwt = require('jsonwebtoken');
const { db } = require('../config/firebase');
const { jwtSecret } = require('../config/env');
const { error } = require('../utils/apiResponse');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return error(res, 'Not authenticated, no token provided', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);

    if (decoded.id === 'admin_id') {
      req.user = {
        _id: 'admin_id',
        name: 'Admin',
        email: 'admin@foodshare.com',
        role: 'admin',
      };
      return next();
    }

    const userDoc = await db.collection('users').doc(decoded.id).get();
    if (!userDoc.exists) return error(res, 'User not found', 401);

    const user = { _id: userDoc.id, ...userDoc.data() };
    delete user.password;

    req.user = user;
    next();
  } catch (err) {
    return error(res, 'Invalid or expired token', 401);
  }
};

module.exports = authMiddleware;
