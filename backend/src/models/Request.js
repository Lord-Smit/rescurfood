const { admin, db } = require('../config/firebase');

const collection = () => db.collection('requests');

const getById = async (id) => {
  const doc = await collection().doc(id).get();
  if (!doc.exists) return null;
  return { _id: doc.id, ...doc.data() };
};

const getAll = async (filters = {}) => {
  let query = collection();
  if (filters.ngoId) query = query.where('ngoId', '==', filters.ngoId);
  if (filters.donationId) query = query.where('donationId', '==', filters.donationId);
  if (filters.status && !Array.isArray(filters.status)) {
    query = query.where('status', '==', filters.status);
  }
  const snap = await query.get();
  let docs = snap.docs.map(d => ({ _id: d.id, ...d.data() }));
  docs.sort((a, b) => {
    const aTime = (a.created_at || a.createdAt || 0)?.toMillis?.() || new Date(a.created_at || a.createdAt || 0).getTime();
    const bTime = (b.created_at || b.createdAt || 0)?.toMillis?.() || new Date(b.created_at || b.createdAt || 0).getTime();
    return bTime - aTime;
  });
  if (Array.isArray(filters.status)) {
    docs = docs.filter(d => filters.status.includes(d.status));
  }
  return docs;
};

const getByDonationId = async (donationId) => {
  const snap = await collection()
    .where('donationId', '==', donationId)
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
    requestedAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  const doc = await ref.get();
  return { _id: ref.id, ...doc.data() };
};

const update = async (id, data) => {
  await collection().doc(id).update({
    ...data,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return getById(id);
};

const getCountByStatus = async (status) => {
  const snap = await collection().where('status', '==', status).get();
  return snap.size;
};

const getActiveCount = async () => {
  const snap = await collection()
    .where('status', 'in', ['pending', 'accepted', 'picked_up'])
    .get();
  return snap.size;
};

module.exports = { getById, getAll, getByDonationId, create, update, getCountByStatus, getActiveCount };
