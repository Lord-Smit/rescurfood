const { admin, db } = require('../config/firebase');

const collection = () => db.collection('users');

const getById = async (id) => {
  const doc = await collection().doc(id).get();
  if (!doc.exists) return null;
  return { _id: doc.id, ...doc.data() };
};

const getByEmail = async (email) => {
  const snap = await collection().where('email', '==', email).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { _id: doc.id, ...doc.data() };
};

const getByPhone = async (phone) => {
  const snap = await collection().where('phone', '==', phone).limit(1).get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  return { _id: doc.id, ...doc.data() };
};

const getByEmailOrPhone = async (email, phone) => {
  if (email) {
    const user = await getByEmail(email);
    if (user) return user;
  }
  if (phone) {
    const user = await getByPhone(phone);
    if (user) return user;
  }
  return null;
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
  const doc = await collection().doc(id).get();
  return { _id: doc.id, ...doc.data() };
};

const getAll = async (filters = {}) => {
  let query = collection();
  if (filters.role) query = query.where('role', '==', filters.role);
  const snap = await query.get();
  let docs = snap.docs.map(d => ({ _id: d.id, ...d.data() }));
  docs.sort((a, b) => {
    const aTime = (a.created_at || a.createdAt || 0)?.toMillis?.() || new Date(a.created_at || a.createdAt || 0).getTime();
    const bTime = (b.created_at || b.createdAt || 0)?.toMillis?.() || new Date(b.created_at || b.createdAt || 0).getTime();
    return bTime - aTime;
  });
  return docs;
};

const getCount = async () => {
  const snap = await collection().get();
  return snap.size;
};

module.exports = { getById, getByEmail, getByPhone, getByEmailOrPhone, create, update, getAll, getCount };
