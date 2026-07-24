const { admin, db } = require('../config/firebase');
const { success, error } = require('../utils/apiResponse');

const getAlerts = async (req, res) => {
  try {
    const { unread, page, limit } = req.query;
    const snap = await db.collection('notifications')
      .where('userId', '==', req.user._id)
      .get();
    let alerts = snap.docs.map(d => {
      const data = d.data();
      const ts = data.createdAt;
      const created_at = ts && typeof ts.toDate === 'function' ? ts.toDate().toISOString() : (ts || null);
      return {
        id: d.id,
        type: data.type || 'info',
        title: data.title || data.type || 'Notification',
        body: data.message || data.body || '',
        created_at,
        read: data.isRead === true,
        action: data.action || null,
      };
    });
    alerts.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    const unreadCount = alerts.filter(a => !a.read).length;

    if (unread === 'true') {
      alerts = alerts.filter(a => !a.read);
    }

    if (limit) {
      alerts = alerts.slice(0, Number(limit));
    }

    if (page && limit) {
      const p = Number(page);
      const l = Number(limit);
      alerts = alerts.slice((p - 1) * l, p * l);
    }

    return success(res, { unread_count: unreadCount, alerts }, 'Alerts fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const markAlertRead = async (req, res) => {
  try {
    const doc = await db.collection('notifications').doc(req.params.id).get();
    if (!doc.exists) return error(res, 'Alert not found', 404);

    await db.collection('notifications').doc(req.params.id).update({ isRead: true });
    return success(res, { id: req.params.id, read: true }, 'Alert marked as read');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { getAlerts, markAlertRead };
