const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  getProfile,
  updateProfile,
  getImpact,
  getSettings,
  updateSettings,
  getAllUsers,
  updateUser,
} = require('../controllers/userController');

router.use(authMiddleware);

router.get('/me', getProfile);
router.put('/me', updateProfile);
router.patch('/me', updateProfile);
router.get('/me/impact', getImpact);
router.get('/me/settings', getSettings);
router.put('/me/settings', updateSettings);
router.get('/', roleMiddleware('admin'), getAllUsers);
router.patch('/:id', roleMiddleware('admin'), updateUser);

module.exports = router;
