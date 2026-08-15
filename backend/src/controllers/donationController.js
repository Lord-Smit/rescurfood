const Donation = require('../models/Donation');
const Request = require('../models/Request');
const { success, error } = require('../utils/apiResponse');

const formatDate = (val) => {
  if (!val) return new Date().toISOString();
  if (typeof val === 'string') return val;
  if (val.toDate && typeof val.toDate === 'function') return val.toDate().toISOString();
  if (val._seconds) return new Date(val._seconds * 1000).toISOString();
  if (val instanceof Date) return val.toISOString();
  return new Date(val).toISOString();
};

const getDonations = async (req, res) => {
  try {
    const { status, limit, page, mine } = req.query;
    const filters = {};

    if (status) {
      filters.status = status.split(',');
    }

    if (mine === 'true' || (req.user && req.user.role === 'donor')) {
      filters.donorId = req.user._id;
    }

    if (limit) filters.limit = Number(limit);

    let donations = await Donation.getAll(filters);
    const total = donations.length;

    if (page && limit) {
      const p = Number(page);
      const l = Number(limit);
      donations = donations.slice((p - 1) * l, p * l);
    }

    const mapped = donations.map(d => ({
      id: d._id,
      donor_id: d.donorId,
      donor_name: d.donor_name || d.donorName || 'Donor',
      food_name: d.food_name || d.foodName,
      quantity: d.quantity,
      unit: d.unit || 'kg',
      food_type: d.food_type || d.foodType || 'other',
      expiry_time: formatDate(d.expiry_time || d.expiryTime),
      pickup_address: d.pickup_address || d.pickupAddress,
      photo_url: d.photo_url || d.photoUrl || null,
      status: d.status || 'available',
      created_at: formatDate(d.created_at || d.createdAt),
      latitude: d.latitude || null,
      longitude: d.longitude || null,
    }));

    return success(res, { donations: mapped, total }, 'Donations fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getAvailableDonations = async (req, res) => {
  try {
    const { q, food_type } = req.query;
    const donations = await Donation.getAvailable({ q, food_type });

    const mapped = donations.map(d => ({
      id: d._id,
      donor_id: d.donorId,
      donor_name: d.donor_name || d.donorName || 'Donor',
      food_name: d.food_name || d.foodName,
      quantity: d.quantity,
      unit: d.unit || 'kg',
      food_type: d.food_type || d.foodType || 'other',
      expiry_time: formatDate(d.expiry_time || d.expiryTime),
      pickup_address: d.pickup_address || d.pickupAddress,
      photo_url: d.photo_url || d.photoUrl || null,
      status: d.status || 'available',
      created_at: formatDate(d.created_at || d.createdAt),
      latitude: d.latitude || null,
      longitude: d.longitude || null,
    }));

    return success(res, { donations: mapped }, 'Available donations fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getNearbyDonations = async (req, res) => {
  try {
    const { lat, lng, radius_km, q, food_type } = req.query;

    const donations = await Donation.getAvailable({ q, food_type });

    const mapped = donations.map(d => {
      const dlat = d.latitude || 0;
      const dlng = d.longitude || 0;

      let distance_km = null;
      if (lat && lng && dlat && dlng) {
        const R = 6371;
        const dLat = ((dlat - Number(lat)) * Math.PI) / 180;
        const dLng = ((dlng - Number(lng)) * Math.PI) / 180;
        const a =
          Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos((Number(lat) * Math.PI) / 180) *
            Math.cos((dlat * Math.PI) / 180) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        distance_km = Math.round(R * c * 10) / 10;
      }

      const expiryStr = formatDate(d.expiry_time || d.expiryTime);
      const expiry = new Date(expiryStr);
      const time_left_minutes = Math.max(0, Math.round((expiry - Date.now()) / 60000));

      return {
        id: d._id,
        food_name: d.food_name || d.foodName,
        quantity: d.quantity,
        unit: d.unit || 'kg',
        distance_km,
        time_left_minutes,
        expiry_time: expiryStr,
        photo_url: d.photo_url || d.photoUrl || null,
        latitude: d.latitude,
        longitude: d.longitude,
        donor_name: d.donor_name || d.donorName || 'Donor',
        status: d.status || 'available',
      };
    });

    let filtered = mapped;
    if (radius_km && lat && lng) {
      filtered = mapped.filter(d => d.distance_km !== null && d.distance_km <= Number(radius_km));
    }

    filtered.sort((a, b) => {
      if (a.distance_km === null) return 1;
      if (b.distance_km === null) return -1;
      return a.distance_km - b.distance_km;
    });

    return success(res, { donations: filtered }, 'Nearby donations fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getDonationById = async (req, res) => {
  try {
    const donation = await Donation.getById(req.params.id);
    if (!donation) return error(res, 'Donation not found', 404);
    return success(res, {
      id: donation._id,
      donor_id: donation.donorId,
      donor_name: donation.donor_name || donation.donorName || 'Donor',
      food_name: donation.food_name || donation.foodName,
      quantity: donation.quantity,
      unit: donation.unit || 'kg',
      food_type: donation.food_type || donation.foodType || 'other',
      expiry_time: formatDate(donation.expiry_time || donation.expiryTime),
      pickup_address: donation.pickup_address || donation.pickupAddress,
      photo_url: donation.photo_url || donation.photoUrl || null,
      status: donation.status || 'available',
      created_at: formatDate(donation.created_at || donation.createdAt),
      latitude: donation.latitude || null,
      longitude: donation.longitude || null,
    }, 'Donation fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const createDonation = async (req, res) => {
  try {
    const {
      food_name, foodName,
      quantity,
      unit,
      food_type, foodType,
      expiry_time, expiryTime,
      pickup_address, pickupAddress,
      photo_url, photoUrl,
      latitude, lat,
      longitude, lng,
    } = req.body;

    const finalFoodName = food_name || foodName;
    const finalFoodType = food_type || foodType || 'other';
    const finalExpiry = expiry_time || expiryTime;
    const finalPickup = pickup_address || pickupAddress;
    const finalPhoto = photo_url || photoUrl || null;
    const finalLat = latitude || lat || null;
    const finalLng = longitude || lng || null;

    if (!finalFoodName || !quantity || !finalExpiry || !finalPickup) {
      return error(res, 'food_name, quantity, expiry_time, and pickup_address are required', 400);
    }

    const finalUnit = unit || 'kg';

    const donationData = {
      donorId: req.user._id,
      donor_name: req.user.name || 'Anonymous Donor',
      food_name: finalFoodName,
      quantity: Number(quantity),
      unit: finalUnit,
      food_type: finalFoodType,
      expiry_time: new Date(finalExpiry),
      pickup_address: finalPickup,
      photo_url: finalPhoto,
      latitude: finalLat ? Number(finalLat) : null,
      longitude: finalLng ? Number(finalLng) : null,
      status: 'available',
    };

    const donation = await Donation.create(donationData);

    return success(res, {
      donation: {
        id: donation._id,
        donor_id: donation.donorId,
        donor_name: donation.donor_name || 'Donor',
        food_name: donation.food_name,
        quantity: donation.quantity,
        unit: donation.unit,
        food_type: donation.food_type,
        expiry_time: formatDate(donation.expiry_time || donation.expiryTime),
        pickup_address: donation.pickup_address,
        photo_url: donation.photo_url,
        status: donation.status || 'available',
        created_at: formatDate(donation.created_at || donation.createdAt),
        latitude: donation.latitude,
        longitude: donation.longitude,
      },
    }, 'Donation created', 201);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateDonation = async (req, res) => {
  try {
    const donation = await Donation.getById(req.params.id);
    if (!donation) return error(res, 'Donation not found', 404);

    if (donation.donorId !== req.user._id && req.user.role !== 'admin') {
      return error(res, 'Not authorized to update this donation', 403);
    }

    const updates = {};
    const {
      food_name, foodName,
      quantity,
      unit,
      food_type, foodType,
      expiry_time, expiryTime,
      pickup_address, pickupAddress,
      photo_url, photoUrl,
      status,
      latitude, longitude,
    } = req.body;

    if (food_name || foodName) updates.food_name = food_name || foodName;
    if (quantity) updates.quantity = Number(quantity);
    if (unit) updates.unit = unit;
    if (food_type || foodType) updates.food_type = food_type || foodType;
    if (expiry_time || expiryTime) updates.expiry_time = new Date(expiry_time || expiryTime);
    if (pickup_address || pickupAddress) updates.pickup_address = pickup_address || pickupAddress;
    if (photo_url || photoUrl) updates.photo_url = photo_url || photoUrl;
    if (status) updates.status = status;
    if (latitude !== undefined) updates.latitude = Number(latitude);
    if (longitude !== undefined) updates.longitude = Number(longitude);

    const updated = await Donation.update(req.params.id, updates);
    return success(res, { donation: { id: updated._id, ...updated } }, 'Donation updated');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const deleteDonation = async (req, res) => {
  try {
    const donation = await Donation.getById(req.params.id);
    if (!donation) return error(res, 'Donation not found', 404);

    if (donation.donorId !== req.user._id && req.user.role !== 'admin') {
      return error(res, 'Not authorized to delete this donation', 403);
    }

    await Donation.remove(req.params.id);
    return success(res, null, 'Donation deleted');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = {
  getDonations,
  getAvailableDonations,
  getNearbyDonations,
  getDonationById,
  createDonation,
  updateDonation,
  deleteDonation,
};
