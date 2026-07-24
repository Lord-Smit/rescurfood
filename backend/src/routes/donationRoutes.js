const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  getDonations,
  getAvailableDonations,
  getNearbyDonations,
  getDonationById,
  createDonation,
  updateDonation,
  deleteDonation,
} = require('../controllers/donationController');

router.use(authMiddleware);

router.get('/available', roleMiddleware('ngo', 'admin'), getAvailableDonations);
router.get('/nearby', getNearbyDonations);
router.get('/', getDonations);
router.get('/:id', getDonationById);
router.post('/', roleMiddleware('donor', 'admin'), createDonation);
router.patch('/:id', updateDonation);
router.delete('/:id', deleteDonation);

module.exports = router;
