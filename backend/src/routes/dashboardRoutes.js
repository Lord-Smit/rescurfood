const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const { getDonorDashboard, getAdminDashboard } = require('../controllers/dashboardController');

router.use(authMiddleware);

router.get('/donor', roleMiddleware('donor'), getDonorDashboard);
router.get('/admin', roleMiddleware('admin'), getAdminDashboard);

module.exports = router;
