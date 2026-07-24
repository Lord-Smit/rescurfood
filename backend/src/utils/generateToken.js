const jwt = require('jsonwebtoken');
const { jwtSecret, jwtExpire } = require('../config/env');

const generateToken = (userId, role) => {
  return jwt.sign({ id: userId, role }, jwtSecret, { expiresIn: jwtExpire });
};

module.exports = generateToken;
