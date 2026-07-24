const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const {
  login,
  register,
  applyRegistration,
  getMe,
  logout,
  forgotPassword,
  socialLogin,
} = require('../controllers/authController');

router.post('/login', login);
router.post('/register', register);
router.post('/apply', applyRegistration);
router.post('/logout', authMiddleware, logout);
router.post('/forgot-password', forgotPassword);
router.post('/social', socialLogin);
router.get('/me', authMiddleware, getMe);

module.exports = router;
