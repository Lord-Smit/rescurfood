const { admin, db } = require('../config/firebase');

const collection = () => db.collection('notifications');

const getByUser = async (userId) => {
  const snap = await collection()
    .where('userId', '==', userId)
    .get();
  let docs = snap.docs.map(d => ({ _id: d.id, ...d.data() }));
  docs.sort((a, b) => {
    const aTime = (a.created_at || a.createdAt || 0)?.toMillis?.() || new Date(a.created_at || a.createdAt || 0).getTime();
    const bTime = (b.created_at || b.createdAt || 0)?.toMillis?.() || new Date(b.created_at || b.createdAt || 0).getTime();
    return bTime - aTime;
  });
  return docs;
};

const create = async (data) => {
  const ref = await collection().add({
    ...data,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  const doc = await ref.get();
  return { _id: ref.id, ...doc.data() };
};

const markAsRead = async (id) => {
  await collection().doc(id).update({ isRead: true });
  return getById(id);
};

const getById = async (id) => {
  const doc = await collection().doc(id).get();
  if (!doc.exists) return null;
  return { _id: doc.id, ...doc.data() };
};

module.exports = { getByUser, create, markAsRead, getById };
