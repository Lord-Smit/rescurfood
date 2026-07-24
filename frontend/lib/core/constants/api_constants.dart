import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Live Production Render URL (Update this if your Render app URL is different)
  static const String liveBackendUrl = 'https://rescurfood-backend.onrender.com/api';

  /// PC Local IPv4 address for local physical Android/iOS devices
  static const String pcLocalIp = '192.168.1.2';

  /// Set to [true] to use the live Render backend, or [false] for local development
  static const bool useLiveBackend = true;

  static String get baseUrl {
    if (useLiveBackend) {
      return liveBackendUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://$pcLocalIp:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String adminLogin = '/auth/login';
  static const String register = '/auth/register';
  static const String applyRegistration = '/auth/apply';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // Profile & User
  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String usersImpact = '/users/me/impact';

  // Donations
  static const String donations = '/donations';
  static const String donationsAvailable = '/donations/available';
  static const String donationsNearby = '/donations/nearby';

  // Requests & Tracking
  static const String requests = '/requests';
  static const String tracking = '/tracking';

  // Dashboard & Alerts
  static const String dashboardDonor = '/dashboard/donor';
  static const String dashboardAdmin = '/dashboard/admin';
  static const String alerts = '/alerts';
  static const String deviceToken = '/notifications/device-token';

  // Uploads & Admin
  static const String uploadFoodPhoto = '/uploads/food-photo';
  static const String adminRequests = '/admin/requests';
}
