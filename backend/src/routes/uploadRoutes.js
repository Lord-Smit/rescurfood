const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { uploadFoodPhoto, uploadAvatar } = require('../controllers/uploadsController');

router.use(authMiddleware);

router.post('/food-photo', uploadFoodPhoto);
router.post('/avatar', uploadAvatar);

module.exports = router;
