const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { getTracking, updateLocation } = require('../controllers/trackingController');

router.use(authMiddleware);

router.get('/:donationId', getTracking);
router.post('/:id/location', updateLocation);

module.exports = router;
