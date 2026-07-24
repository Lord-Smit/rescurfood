const bcrypt = require('bcryptjs');
const { admin, db } = require('../config/firebase');
const Donation = require('../models/Donation');
const createNotification = require('./notificationHelper');
const { success, error } = require('../utils/apiResponse');

const getRegistrationRequests = async (req, res) => {
  try {
    const { status } = req.query;
    let ref = db.collection('registrationRequests');
    let snap;
    if (status) {
      snap = await ref.where('status', '==', status.toUpperCase()).get();
    } else {
      snap = await ref.get();
    }

    let requests = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    requests.sort((a, b) => {
      const aTime = (a.createdAt || 0)?.toMillis?.() || new Date(a.createdAt || 0).getTime();
      const bTime = (b.createdAt || 0)?.toMillis?.() || new Date(b.createdAt || 0).getTime();
      return bTime - aTime;
    });

    return success(res, { requests }, 'Registration requests fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getRegistrationRequestById = async (req, res) => {
  try {
    const doc = await db.collection('registrationRequests').doc(req.params.id).get();
    if (!doc.exists) {
      return error(res, 'Registration request not found', 404);
    }
    return success(res, { id: doc.id, ...doc.data() }, 'Registration request fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const approveRegistration = async (req, res) => {
  try {
    const doc = await db.collection('registrationRequests').doc(req.params.id).get();
    if (!doc.exists) {
      return error(res, 'Registration request not found', 404);
    }

    const request = { id: doc.id, ...doc.data() };

    if (request.status !== 'PENDING') {
      return error(res, `Request is already ${request.status.toLowerCase()}`, 400);
    }

    const hashedPassword = await bcrypt.hash(request.password, 10);

    const userRef = await db.collection('users').add({
      name: request.name,
      email: request.email,
      password: hashedPassword,
      phone: request.phone,
      role: request.type.toLowerCase(),
      user_type: request.user_type || null,
      is_active: true,
      avatar_url: null,
      stats: { units_donated: 0, deliveries_completed: 0 },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await db.collection('registrationRequests').doc(req.params.id).update({
      status: 'APPROVED',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await createNotification(userRef.id, 'Your registration has been approved! You can now log in.', 'success');

    const userSnap = await userRef.get();
    const user = { id: userRef.id, ...userSnap.data() };
    delete user.password;

    return success(res, { user, request: { ...request, status: 'APPROVED' } }, 'Registration approved successfully');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const rejectRegistration = async (req, res) => {
  try {
    const doc = await db.collection('registrationRequests').doc(req.params.id).get();
    if (!doc.exists) {
      return error(res, 'Registration request not found', 404);
    }

    const request = { id: doc.id, ...doc.data() };

    if (request.status !== 'PENDING') {
      return error(res, `Request is already ${request.status.toLowerCase()}`, 400);
    }

    await db.collection('registrationRequests').doc(req.params.id).update({
      status: 'REJECTED',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return success(res, { ...request, status: 'REJECTED' }, 'Registration rejected');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getAllDonations = async (req, res) => {
  try {
    const { status, limit, page } = req.query;
    const filters = {};
    if (status) filters.status = status.split(',');

    let donations = await Donation.getAll(filters);

    if (limit) {
      const l = Number(limit);
      const p = Number(page || 1);
      donations = donations.slice((p - 1) * l, p * l);
    }

    const mapped = donations.map(d => ({
      id: d._id,
      donor_id: d.donorId,
      donor_name: d.donor_name || d.donorName,
      food_name: d.food_name || d.foodName,
      quantity: d.quantity,
      unit: d.unit,
      food_type: d.food_type || d.foodType || 'other',
      status: d.status,
      created_at: d.created_at || d.createdAt,
      pickup_address: d.pickup_address || d.pickupAddress,
    }));

    return success(res, { donations: mapped }, 'All donations fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = {
  getRegistrationRequests,
  getRegistrationRequestById,
  approveRegistration,
  rejectRegistration,
  getAllDonations,
};
