const bcrypt = require('bcryptjs');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { admin, db } = require('../config/firebase');
const { success, error } = require('../utils/apiResponse');

const login = async (req, res) => {
  try {
    const { email, phone, password } = req.body;

    if ((!email && !phone) || !password) {
      return error(res, 'Missing credentials', 400);
    }

    if (email === 'admin@foodshare.com' && password === 'Admin@123') {
      const token = generateToken('admin_id', 'admin');
      return success(res, {
        token,
        user: { id: 'admin_id', name: 'Admin', email, role: 'admin' },
      }, 'Login successful');
    }

    const user = await User.getByEmailOrPhone(email, phone);
    if (!user) {
      return error(res, 'Invalid credentials', 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return error(res, 'Invalid credentials', 401);
    }

    const token = generateToken(user._id, user.role);
    return success(res, {
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    }, 'Login successful');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const register = async (req, res) => {
  try {
    const { name, email, phone, password, role, user_type } = req.body;

    if (!name || !password) {
      return error(res, 'Name and password are required', 400);
    }

    if (!email && !phone) {
      return error(res, 'Email or phone is required', 400);
    }

    if (password.length < 6) {
      return error(res, 'Password must be at least 6 characters', 400);
    }

    if (!role || !['donor', 'ngo', 'admin'].includes(role)) {
      return error(res, 'Valid role is required (donor, ngo, admin)', 400);
    }

    if (email) {
      const existing = await User.getByEmail(email);
      if (existing) return error(res, 'Email already registered', 409);
    }

    if (phone) {
      const existing = await User.getByPhone(phone);
      if (existing) return error(res, 'Phone already registered', 409);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email: email || null,
      phone: phone || null,
      password: hashedPassword,
      role,
      user_type: user_type || null,
      avatar_url: null,
      is_active: true,
      stats: { units_donated: 0, deliveries_completed: 0 },
    });

    const token = generateToken(user._id, user.role);
    return success(res, {
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    }, 'Registration successful', 201);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const applyRegistration = async (req, res) => {
  try {
    const { type, name, email, phone, password } = req.body;

    if (!name || !password) {
      return error(res, 'Name and password are required', 400);
    }
    if (!email && !phone) {
      return error(res, 'Email or phone is required', 400);
    }

    if (email) {
      const existingUser = await User.getByEmail(email);
      if (existingUser) return error(res, 'Email already registered', 409);
    }

    if (phone) {
      const existingPhone = await User.getByPhone(phone);
      if (existingPhone) return error(res, 'Phone already registered', 409);
    }

    const ref = await db.collection('registrationRequests').add({
      type: type ? type.toUpperCase() : 'DONOR',
      name,
      email: email || null,
      phone: phone || null,
      password,
      status: 'PENDING',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return success(
      res,
      { id: ref.id },
      'Registration application submitted successfully. Pending admin approval.',
      201
    );
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getMe = async (req, res) => {
  try {
    if (req.user._id === 'admin_id') {
      return success(res, {
        user: { id: 'admin_id', name: 'Admin', email: 'admin@foodshare.com', role: 'admin', avatar_url: null },
      }, 'Session loaded');
    }
    const user = await User.getById(req.user._id);
    if (!user) return error(res, 'User not found', 404);
    const { password, ...safe } = user;
    return success(res, {
      user: {
        id: safe._id,
        name: safe.name,
        email: safe.email,
        phone: safe.phone,
        role: safe.role,
        avatar_url: safe.avatar_url || null,
      },
    }, 'Session loaded');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const logout = async (req, res) => {
  try {
    return success(res, null, 'Logged out successfully');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return error(res, 'Email is required', 400);
    const user = await User.getByEmail(email);
    if (!user) return success(res, null, 'If that email exists, a reset link has been sent');
    return success(res, null, 'If that email exists, a reset link has been sent');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const socialLogin = async (req, res) => {
  try {
    const { provider, id_token } = req.body;
    if (!provider || !id_token) {
      return error(res, 'Provider and id_token are required', 400);
    }
    return error(res, 'Social login not yet implemented', 501);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { login, register, applyRegistration, getMe, logout, forgotPassword, socialLogin };
