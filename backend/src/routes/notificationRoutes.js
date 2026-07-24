const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User');
const { success, error } = require('../utils/apiResponse');

router.use(authMiddleware);

router.post('/device-token', async (req, res) => {
  try {
    const { token, platform } = req.body;
    if (!token) return error(res, 'Token is required', 400);

    if (req.user._id && req.user._id !== 'admin_id') {
      await User.update(req.user._id, {
        fcmToken: token,
        fcmPlatform: platform || 'unknown',
      });
    }

    return success(res, { token, platform: platform || 'unknown' }, 'Device token registered');
  } catch (err) {
    return error(res, err.message, 500);
  }
});

module.exports = router;
