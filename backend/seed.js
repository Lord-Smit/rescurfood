const bcrypt = require('bcryptjs');
const { admin, db } = require('./src/config/firebase');

const collections = {
  users: db.collection('users'),
  donations: db.collection('donations'),
  requests: db.collection('requests'),
  notifications: db.collection('notifications'),
  registrationRequests: db.collection('registrationRequests'),
};

const timestamp = () => admin.firestore.FieldValue.serverTimestamp();

async function seed() {
  console.log('Seeding Firestore...\n');

  const donorPass = await bcrypt.hash('donor123', 10);
  const ngoPass = await bcrypt.hash('ngo123', 10);

  const donor1 = await collections.users.add({
    name: 'Green Leaf Hotel',
    email: 'donor@test.com',
    password: donorPass,
    phone: '9876543210',
    role: 'donor',
    user_type: 'Restaurant / Hotel',
    is_active: true,
    avatar_url: null,
    stats: { units_donated: 0, deliveries_completed: 0 },
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  User: donor@test.com / donor123  (${donor1.id})`);

  const donor2 = await collections.users.add({
    name: 'City Bakery',
    email: 'bakery@test.com',
    password: donorPass,
    phone: '9876543211',
    role: 'donor',
    user_type: 'Grocery / Bakery',
    is_active: true,
    avatar_url: null,
    stats: { units_donated: 0, deliveries_completed: 0 },
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  User: bakery@test.com / donor123   (${donor2.id})`);

  const ngo1 = await collections.users.add({
    name: 'Hope Foundation',
    email: 'ngo@test.com',
    password: ngoPass,
    phone: '9876543212',
    role: 'ngo',
    user_type: null,
    is_active: true,
    avatar_url: null,
    stats: { units_donated: 0, deliveries_completed: 0 },
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  User: ngo@test.com / ngo123       (${ngo1.id})`);

  const ngo2 = await collections.users.add({
    name: 'Food for All Trust',
    email: 'ngo2@test.com',
    password: ngoPass,
    phone: '9876543213',
    role: 'ngo',
    user_type: null,
    is_active: true,
    avatar_url: null,
    stats: { units_donated: 0, deliveries_completed: 0 },
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  User: ngo2@test.com / ngo123      (${ngo2.id})`);

  const d1 = await collections.donations.add({
    donorId: donor1.id,
    donor_name: 'Green Leaf Hotel',
    food_name: 'Mixed Veg Curry',
    quantity: 25,
    unit: 'kg',
    food_type: 'veg',
    expiry_time: new Date(Date.now() + 4 * 3600 * 1000),
    pickup_address: '45 Park Avenue, Downtown',
    latitude: 18.5204,
    longitude: 73.8567,
    photo_url: null,
    status: 'available',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Donation: Mixed Veg Curry (25 kg) — available`);

  const d2 = await collections.donations.add({
    donorId: donor2.id,
    donor_name: 'City Bakery',
    food_name: 'Assorted Pastries',
    quantity: 50,
    unit: 'Packets',
    food_type: 'veg',
    expiry_time: new Date(Date.now() + 8 * 3600 * 1000),
    pickup_address: '12 Church Street',
    latitude: 18.5210,
    longitude: 73.8570,
    photo_url: null,
    status: 'available',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Donation: Assorted Pastries (50 packets) — available`);

  const d3 = await collections.donations.add({
    donorId: donor1.id,
    donor_name: 'Green Leaf Hotel',
    food_name: 'Veg Biryani',
    quantity: 15,
    unit: 'Meals',
    food_type: 'veg',
    expiry_time: new Date(Date.now() + 6 * 3600 * 1000),
    pickup_address: '45 Park Avenue, Downtown',
    latitude: 18.5204,
    longitude: 73.8567,
    photo_url: null,
    status: 'available',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Donation: Veg Biryani (15 meals) — available`);

  const d4 = await collections.donations.add({
    donorId: donor1.id,
    donor_name: 'Green Leaf Hotel',
    food_name: 'Fruit Basket',
    quantity: 10,
    unit: 'kg',
    food_type: 'veg',
    expiry_time: new Date(Date.now() + 24 * 3600 * 1000),
    pickup_address: '45 Park Avenue, Downtown',
    latitude: 18.5204,
    longitude: 73.8567,
    photo_url: null,
    status: 'completed',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Donation: Fruit Basket (10 kg) — completed`);

  const d5 = await collections.donations.add({
    donorId: donor2.id,
    donor_name: 'City Bakery',
    food_name: 'Bread Packets',
    quantity: 30,
    unit: 'Packets',
    food_type: 'veg',
    expiry_time: new Date(Date.now() - 2 * 3600 * 1000),
    pickup_address: '12 Church Street',
    latitude: 18.5210,
    longitude: 73.8570,
    photo_url: null,
    status: 'expired',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Donation: Bread Packets (30 packets) — expired`);

  const timelineAccepted = [
    { key: 'requested', label: 'Requested', at: new Date(Date.now() - 3600 * 1000).toISOString(), done: true },
    { key: 'accepted', label: 'NGO Accepted', at: new Date(Date.now() - 1800 * 1000).toISOString(), done: true, active: true },
    { key: 'picked_up', label: 'Picked Up', at: null, done: false },
    { key: 'delivered', label: 'Delivered', at: null, done: false },
  ];

  const timelineCompleted = [
    { key: 'requested', label: 'Requested', at: new Date(Date.now() - 7200 * 1000).toISOString(), done: true },
    { key: 'accepted', label: 'NGO Accepted', at: new Date(Date.now() - 6000 * 1000).toISOString(), done: true },
    { key: 'picked_up', label: 'Picked Up', at: new Date(Date.now() - 3600 * 1000).toISOString(), done: true },
    { key: 'delivered', label: 'Delivered', at: new Date(Date.now() - 1800 * 1000).toISOString(), done: true, active: true },
  ];

  const r1 = await collections.requests.add({
    donationId: d1.id,
    donation_name: 'Mixed Veg Curry',
    ngoId: ngo1.id,
    ngo_name: 'Hope Foundation',
    donor_name: 'Green Leaf Hotel',
    status: 'accepted',
    timeline: timelineAccepted,
    requestedAt: timestamp(),
    respondedAt: new Date().toISOString(),
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Request: Hope Foundation -> Mixed Veg Curry (accepted)`);

  const r2 = await collections.requests.add({
    donationId: d2.id,
    donation_name: 'Assorted Pastries',
    ngoId: ngo1.id,
    ngo_name: 'Hope Foundation',
    donor_name: 'City Bakery',
    status: 'pending',
    timeline: [
      { key: 'requested', label: 'Requested', at: new Date().toISOString(), done: true, active: true },
      { key: 'accepted', label: 'NGO Accepted', at: null, done: false },
      { key: 'picked_up', label: 'Picked Up', at: null, done: false },
      { key: 'delivered', label: 'Delivered', at: null, done: false },
    ],
    requestedAt: timestamp(),
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Request: Hope Foundation -> Assorted Pastries (pending)`);

  const r3 = await collections.requests.add({
    donationId: d4.id,
    donation_name: 'Fruit Basket',
    ngoId: ngo2.id,
    ngo_name: 'Food for All Trust',
    donor_name: 'Green Leaf Hotel',
    status: 'completed',
    timeline: timelineCompleted,
    requestedAt: timestamp(),
    respondedAt: new Date().toISOString(),
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log(`  Request: Food for All Trust -> Fruit Basket (completed)`);

  await collections.notifications.add({
    userId: donor1.id,
    message: 'Hope Foundation has requested your Mixed Veg Curry donation.',
    type: 'donation_requested',
    title: 'Donation requested',
    body: 'Hope Foundation has requested your Mixed Veg Curry donation.',
    isRead: false,
    action: { screen: 'tracking', donation_id: d1.id },
    createdAt: timestamp(),
  });
  console.log('  Notification for donor');

  await collections.notifications.add({
    userId: ngo1.id,
    message: 'Your request for Mixed Veg Curry has been accepted!',
    type: 'request_accepted',
    title: 'Donation accepted',
    body: 'Your request for Mixed Veg Curry has been accepted!',
    isRead: false,
    action: { screen: 'tracking', donation_id: d1.id },
    createdAt: timestamp(),
  });
  console.log('  Notification for NGO');

  await collections.registrationRequests.add({
    type: 'DONOR',
    name: 'Grand Plaza Event',
    email: 'events@test.com',
    phone: '9876543214',
    password: 'tempPass123',
    documents: '',
    status: 'PENDING',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log('  Registration request: Grand Plaza Event (PENDING)');

  await collections.registrationRequests.add({
    type: 'NGO',
    name: 'Helping Hands NGO',
    email: 'help@test.com',
    phone: '9876543215',
    password: 'tempPass123',
    documents: '',
    status: 'PENDING',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log('  Registration request: Helping Hands NGO (PENDING)');

  await collections.registrationRequests.add({
    type: 'DONOR',
    name: 'Sunrise Cafe',
    email: 'cafe@test.com',
    phone: '9876543216',
    password: 'tempPass123',
    documents: '',
    status: 'APPROVED',
    createdAt: timestamp(),
    updatedAt: timestamp(),
  });
  console.log('  Registration request: Sunrise Cafe (APPROVED)');

  console.log('\n--- Seeding complete! ---\n');
  console.log('Test Credentials:');
  console.log('  Admin:   admin@foodshare.com / Admin@123');
  console.log('  Donor:   donor@test.com      / donor123');
  console.log('  Donor:   bakery@test.com     / donor123');
  console.log('  NGO:     ngo@test.com        / ngo123');
  console.log('  NGO:     ngo2@test.com       / ngo123');
  console.log('');

  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
