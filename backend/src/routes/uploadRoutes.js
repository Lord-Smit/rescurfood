const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const { uploadFoodPhoto, uploadAvatar } = require('../controllers/uploadsController');

router.use(authMiddleware);

router.post('/food-photo', upload.single('file'), uploadFoodPhoto);
router.post('/avatar', upload.single('file'), uploadAvatar);

module.exports = router;
