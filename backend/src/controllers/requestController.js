const Donation = require('../models/Donation');
const Request = require('../models/Request');
const Notification = require('../models/Notification');
const createNotification = require('./notificationHelper');
const { success, error } = require('../utils/apiResponse');

const getRequests = async (req, res) => {
  try {
    const { status } = req.query;
    const filters = {};
    if (status) filters.status = status.split(',');

    let requests;
    if (req.user.role === 'ngo') {
      requests = await Request.getAll({ ...filters, ngoId: req.user._id });
    } else if (req.user.role === 'donor') {
      const donations = await Donation.getByDonor(req.user._id);
      const donationIds = donations.map(d => d._id);
      requests = [];
      for (const id of donationIds) {
        const reqs = await Request.getAll({ ...filters, donationId: id });
        requests.push(...reqs);
      }
      requests.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } else {
      requests = await Request.getAll(filters);
    }

    const mapped = requests.map(r => ({
      id: r._id,
      donation_id: r.donationId,
      ngo_id: r.ngoId,
      ngo_name: r.ngo_name || r.ngoName,
      donation_name: r.donation_name || r.donationName,
      donor_name: r.donor_name || null,
      status: r.status,
      created_at: r.created_at || r.createdAt,
      timeline: r.timeline || [],
    }));

    return success(res, { requests: mapped }, 'Requests fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getRequestById = async (req, res) => {
  try {
    const request = await Request.getById(req.params.id);
    if (!request) return error(res, 'Request not found', 404);
    return success(res, {
      id: request._id,
      donation_id: request.donationId,
      ngo_id: request.ngoId,
      ngo_name: request.ngo_name || request.ngoName,
      donation_name: request.donation_name || request.donationName,
      status: request.status,
      created_at: request.created_at || request.createdAt,
      timeline: request.timeline || [],
    }, 'Request fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const createRequest = async (req, res) => {
  try {
    const { donation_id, donationId } = req.body;
    const finalDonationId = donation_id || donationId;

    if (!finalDonationId) return error(res, 'donation_id is required', 400);

    const donation = await Donation.getById(finalDonationId);
    if (!donation) return error(res, 'Donation not found', 404);
    if (donation.status !== 'available') return error(res, 'Donation is not available', 400);

    const existing = await Request.getAll({ donationId: finalDonationId, ngoId: req.user._id });
    const hasActive = existing.some(r => ['pending', 'accepted', 'picked_up'].includes(r.status));
    if (hasActive) return error(res, 'You already have an active request for this donation', 400);

    const timeline = [
      { key: 'requested', label: 'Requested', at: new Date().toISOString(), done: true },
      { key: 'accepted', label: 'NGO Accepted', at: null, done: false },
      { key: 'picked_up', label: 'Picked Up', at: null, done: false },
      { key: 'delivered', label: 'Delivered', at: null, done: false },
    ];

    const request = await Request.create({
      donationId: finalDonationId,
      donation_name: donation.food_name || donation.foodName,
      ngoId: req.user._id,
      ngo_name: req.user.name,
      donor_name: donation.donor_name || donation.donorName,
      status: 'pending',
      timeline,
    });

    await Donation.update(finalDonationId, { status: 'reserved' });

    await createNotification(
      donation.donorId,
      `${req.user.name} has requested your donation: ${donation.food_name || donation.foodName}`,
      'donation_requested',
      { screen: 'tracking', donation_id: finalDonationId },
    );

    return success(res, {
      request: {
        id: request._id,
        donation_id: request.donationId,
        ngo_id: request.ngoId,
        ngo_name: request.ngo_name || request.ngoName,
        donation_name: request.donation_name || request.donationName,
        status: request.status,
        created_at: request.created_at || request.createdAt,
        timeline: request.timeline,
      },
    }, 'Request created', 201);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateRequestStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['accepted', 'picked_up', 'completed', 'cancelled'];

    if (!status || !validStatuses.includes(status)) {
      return error(res, `Valid status is required: ${validStatuses.join(', ')}`, 400);
    }

    const request = await Request.getById(req.params.id);
    if (!request) return error(res, 'Request not found', 404);

    const allowedTransitions = {
      pending: ['accepted', 'cancelled'],
      accepted: ['picked_up', 'cancelled'],
      picked_up: ['completed', 'cancelled'],
      completed: [],
      cancelled: [],
    };

    const currentStatus = request.status;
    const allowed = allowedTransitions[currentStatus] || [];

    if (!allowed.includes(status)) {
      return error(res, `Cannot transition from ${currentStatus} to ${status}`, 400);
    }

    const donation = await Donation.getById(request.donationId);
    if (!donation) return error(res, 'Associated donation not found', 404);

    if (donation.donorId !== req.user._id && request.ngoId !== req.user._id && req.user.role !== 'admin') {
      return error(res, 'Not authorized to update this request', 403);
    }

    const timeline = request.timeline || [];
    const updatedTimeline = timeline.map(t => {
      if (t.key === status && !t.done) {
        return { ...t, at: new Date().toISOString(), done: true, active: true };
      }
      return { ...t, active: false };
    });

    const foundInTimeline = timeline.some(t => t.key === status);
    if (!foundInTimeline) {
      updatedTimeline.push({
        key: status,
        label: status.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
        at: new Date().toISOString(),
        done: true,
        active: true,
      });
    }

    const donationStatusMap = {
      accepted: 'accepted',
      picked_up: 'picked_up',
      completed: 'completed',
      cancelled: 'available',
    };

    const donationStatus = donationStatusMap[status] || currentStatus;

    const updated = await Request.update(req.params.id, {
      status,
      timeline: updatedTimeline,
      respondedAt: new Date().toISOString(),
    });

    await Donation.update(request.donationId, { status: donationStatus });

    const notifyUserId = donation.donorId === req.user._id ? request.ngoId : donation.donorId;
    const statusLabel = status.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    await createNotification(
      notifyUserId,
      `Request for ${donation.food_name || donation.foodName} has been ${statusLabel}`,
      `request_${status}`,
      { screen: 'tracking', donation_id: request.donationId },
    );

    return success(res, {
      request: {
        id: updated._id,
        donation_id: updated.donationId,
        ngo_id: updated.ngoId,
        ngo_name: updated.ngo_name || updated.ngoName,
        donation_name: updated.donation_name || updated.donationName,
        status: updated.status,
        timeline: updatedTimeline,
      },
    }, `Request ${statusLabel}`);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { getRequests, getRequestById, createRequest, updateRequestStatus };
