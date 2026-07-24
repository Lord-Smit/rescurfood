const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');
const {
  getRequests,
  getRequestById,
  createRequest,
  updateRequestStatus,
} = require('../controllers/requestController');

router.use(authMiddleware);

router.get('/', getRequests);
router.get('/:id', getRequestById);
router.post('/', roleMiddleware('ngo', 'admin'), createRequest);
router.patch('/:id/status', updateRequestStatus);

module.exports = router;
