const { admin, db } = require('../config/firebase');

const createNotification = async (userId, message, type = 'info', action = null) => {
  try {
    const titles = {
      pickup_scheduled: 'Pickup scheduled',
      donation_accepted: 'Donation accepted',
      nearby_donation: 'New nearby donation',
      donation_requested: 'Donation requested',
      request_accepted: 'Request accepted',
      request_picked_up: 'Picked up',
      request_completed: 'Completed',
      request_cancelled: 'Request cancelled',
      info: 'Notification',
      success: 'Success',
    };

    await db.collection('notifications').add({
      userId,
      message,
      type,
      title: titles[type] || 'Notification',
      body: message,
      isRead: false,
      action: action ? JSON.parse(JSON.stringify(action)) : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    console.error('Failed to create notification:', err.message);
  }
};

module.exports = createNotification;
