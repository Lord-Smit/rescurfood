const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { getAlerts, markAlertRead } = require('../controllers/alertsController');

router.use(authMiddleware);

router.get('/', getAlerts);
router.patch('/:id/read', markAlertRead);

module.exports = router;
