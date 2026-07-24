const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  getRegistrationRequests,
  getRegistrationRequestById,
  approveRegistration,
  rejectRegistration,
  getAllDonations,
} = require('../controllers/adminController');

router.use(authMiddleware);
router.use(roleMiddleware('admin'));

router.get('/donations', getAllDonations);
router.get('/requests', getRegistrationRequests);
router.get('/requests/:id', getRegistrationRequestById);
router.patch('/requests/:id/approve', approveRegistration);
router.patch('/requests/:id/reject', rejectRegistration);

module.exports = router;
