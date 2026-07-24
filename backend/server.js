const express = require('express');
const cors = require('cors');
const path = require('path');
const { port } = require('./src/config/env');
require('./src/config/firebase');
const errorHandler = require('./src/middleware/errorHandler');

const authRoutes = require('./src/routes/authRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const donationRoutes = require('./src/routes/donationRoutes');
const requestRoutes = require('./src/routes/requestRoutes');
const userRoutes = require('./src/routes/userRoutes');
const trackingRoutes = require('./src/routes/trackingRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const alertsRoutes = require('./src/routes/alertsRoutes');
const uploadRoutes = require('./src/routes/uploadRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.get('/', (req, res) => {
  res.json({ message: 'FoodBridge API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/donations', donationRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tracking', trackingRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/alerts', alertsRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/notifications', notificationRoutes);

app.use(errorHandler);

// Listen on '0.0.0.0' so Android Emulator (10.0.2.2) and local network devices can connect
app.listen(port, '0.0.0.0', () => {
  console.log(`FoodBridge server running on http://0.0.0.0:${port}`);
});
