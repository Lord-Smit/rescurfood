const User = require('../models/User');
const Donation = require('../models/Donation');
const { success, error } = require('../utils/apiResponse');

const getProfile = async (req, res) => {
  try {
    if (req.user._id === 'admin_id') {
      return success(res, {
        id: 'admin_id', name: 'Admin', email: 'admin@foodshare.com', role: 'admin',
        user_type: null, avatar_url: null,
        stats: { units_donated: 0, deliveries_completed: 0 },
      }, 'Profile fetched');
    }
    const user = await User.getById(req.user._id);
    if (!user) return error(res, 'User not found', 404);

    const donations = await Donation.getByDonor(user._id);
    const completedDonations = donations.filter(d => d.status === 'completed');
    const mealsCount = completedDonations.reduce((sum, d) => {
      const qty = Number(d.quantity) || 0;
      if (d.unit === 'Meals') return sum + qty;
      return sum + Math.round(qty * 2.5);
    }, 0);

    const { password, ...safe } = user;
    return success(res, {
      id: safe._id,
      name: safe.name,
      email: safe.email,
      phone: safe.phone,
      role: safe.role,
      user_type: safe.user_type || null,
      avatar_url: safe.avatar_url || null,
      stats: {
        units_donated: mealsCount,
        deliveries_completed: completedDonations.length,
      },
    }, 'Profile fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateProfile = async (req, res) => {
  try {
    const { name, email, phone, avatar_url, avatarUrl } = req.body;
    const updates = {};
    if (name) updates.name = name;
    if (email) updates.email = email;
    if (phone) updates.phone = phone;
    if (avatar_url || avatarUrl) updates.avatar_url = avatar_url || avatarUrl;

    const user = await User.update(req.user._id, updates);
    const { password, ...safe } = user;
    return success(res, {
      id: safe._id,
      name: safe.name,
      email: safe.email,
      phone: safe.phone,
      role: safe.role,
      avatar_url: safe.avatar_url || null,
    }, 'Profile updated');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getImpact = async (req, res) => {
  try {
    const user = await User.getById(req.user._id);
    const donations = await Donation.getByDonor(user._id);
    const completedDonations = donations.filter(d => d.status === 'completed');
    const mealsCount = completedDonations.reduce((sum, d) => {
      const qty = Number(d.quantity) || 0;
      if (d.unit === 'Meals') return sum + qty;
      return sum + Math.round(qty * 2.5);
    }, 0);

    let rank = 'Food Saver';
    if (mealsCount > 500) rank = 'Food Champion';
    else if (mealsCount > 200) rank = 'Food Hero';
    else if (mealsCount > 50) rank = 'Food Saver';
    else rank = 'Beginner';

    return success(res, {
      meals_saved: mealsCount,
      deliveries_completed: completedDonations.length,
      co2_saved_kg: Math.round(mealsCount * 0.42 * 10) / 10,
      rank,
    }, 'Impact fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getSettings = async (req, res) => {
  try {
    return success(res, {
      notifications_enabled: true,
      email_notifications: true,
      push_notifications: true,
      language: 'en',
    }, 'Settings fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateSettings = async (req, res) => {
  try {
    return success(res, req.body, 'Settings updated');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getAllUsers = async (req, res) => {
  try {
    const { role, q } = req.query;
    const filters = {};
    if (role) filters.role = role;

    let users = await User.getAll(filters);
    let sanitized = users.map(u => {
      const { password, ...rest } = u;
      return {
        id: rest._id,
        name: rest.name,
        email: rest.email,
        phone: rest.phone,
        role: rest.role,
        user_type: rest.user_type || null,
        created_at: rest.created_at || rest.createdAt,
        is_active: rest.is_active !== false,
      };
    });

    if (q) {
      const query = q.toLowerCase();
      sanitized = sanitized.filter(u =>
        (u.name && u.name.toLowerCase().includes(query)) ||
        (u.email && u.email.toLowerCase().includes(query)) ||
        (u.phone && u.phone.includes(query))
      );
    }

    return success(res, { users: sanitized }, 'Users fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateUser = async (req, res) => {
  try {
    const { is_active, role } = req.body;
    const updates = {};
    if (is_active !== undefined) updates.is_active = is_active;
    if (role) updates.role = role;

    const user = await User.update(req.params.id, updates);
    const { password, ...safe } = user;
    return success(res, {
      id: safe._id,
      name: safe.name,
      email: safe.email,
      role: safe.role,
      is_active: safe.is_active !== false,
    }, 'User updated');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { getProfile, updateProfile, getImpact, getSettings, updateSettings, getAllUsers, updateUser };
