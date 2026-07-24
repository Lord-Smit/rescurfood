const { admin, db } = require('../config/firebase');

const collection = () => db.collection('donations');

const getById = async (id) => {
  const doc = await collection().doc(id).get();
  if (!doc.exists) return null;
  return { _id: doc.id, ...doc.data() };
};

const getAll = async (filters = {}) => {
  let query = collection();
  if (filters.status && !Array.isArray(filters.status)) {
    query = query.where('status', '==', filters.status);
  }
  if (filters.donorId) query = query.where('donorId', '==', filters.donorId);
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
  if (filters.limit) docs = docs.slice(0, Number(filters.limit));
  return docs;
};

const getAvailable = async (filters = {}) => {
  const snap = await collection()
    .where('status', '==', 'available')
    .get();
  let docs = snap.docs.map(d => ({ _id: d.id, ...d.data() }));
  docs.sort((a, b) => {
    const aTime = (a.created_at || a.createdAt || 0)?.toMillis?.() || new Date(a.created_at || a.createdAt || 0).getTime();
    const bTime = (b.created_at || b.createdAt || 0)?.toMillis?.() || new Date(b.created_at || b.createdAt || 0).getTime();
    return bTime - aTime;
  });
  if (filters.food_type) {
    docs = docs.filter(d => d.food_type === filters.food_type);
  }
  if (filters.q) {
    const q = filters.q.toLowerCase();
    docs = docs.filter(d =>
      (d.food_name && d.food_name.toLowerCase().includes(q)) ||
      (d.donor_name && d.donor_name.toLowerCase().includes(q))
    );
  }
  return docs;
};

const getByDonor = async (donorId) => {
  const snap = await collection()
    .where('donorId', '==', donorId)
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

const remove = async (id) => {
  await collection().doc(id).delete();
  return true;
};

const getCount = async () => {
  const snap = await collection().get();
  return snap.size;
};

const getCountByStatus = async (status) => {
  const snap = await collection().where('status', '==', status).get();
  return snap.size;
};

module.exports = { getById, getAll, getAvailable, getByDonor, create, update, remove, getCount, getCountByStatus };
