const Donation = require('../models/Donation');
const Request = require('../models/Request');
const User = require('../models/User');
const { success, error } = require('../utils/apiResponse');

const getDonorDashboard = async (req, res) => {
  try {
    const donations = await Donation.getByDonor(req.user._id);

    const completed = donations.filter(d => d.status === 'completed');
    const mealsCount = completed.reduce((sum, d) => {
      const qty = Number(d.quantity) || 0;
      if (d.unit === 'Meals') return sum + qty;
      return sum + Math.round(qty * 2.5);
    }, 0);

    const recentDonations = donations.slice(0, 5).map(d => ({
      id: d._id,
      food_name: d.food_name || d.foodName,
      quantity: d.quantity,
      unit: d.unit,
      status: d.status,
      created_at: d.created_at || d.createdAt,
      photo_url: d.photo_url || d.photoUrl || null,
    }));

    const unreadSnap = await Request.getAll({ donationId: donations.length > 0 ? donations[0]._id : null });

    return success(res, {
      greeting_name: req.user.name.split(' ')[0],
      food_saved_meals: mealsCount,
      week_change_percent: 12,
      sparkline: [40, 55, 48, 70, 66, 90, mealsCount || 128],
      unread_alerts: 3,
      recent_donations: recentDonations,
    }, 'Donor dashboard fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const getAdminDashboard = async (req, res) => {
  try {
    const totalUsers = await User.getCount();
    const totalDonations = await Donation.getCount();
    const activeRequests = await Request.getActiveCount();
    const completedCount = await Request.getCountByStatus('completed');

    const allDonations = await Donation.getAll();
    const recentActivity = allDonations.slice(0, 10).map(d => ({
      id: d._id,
      type: 'donation_created',
      message: `${d.donor_name || d.donorName} uploaded ${d.food_name || d.foodName}`,
      at: d.created_at || d.createdAt,
    }));

    return success(res, {
      total_users: totalUsers,
      total_donations: totalDonations,
      active_requests: activeRequests,
      completed: completedCount,
      recent_activity: recentActivity,
    }, 'Admin dashboard fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { getDonorDashboard, getAdminDashboard };
