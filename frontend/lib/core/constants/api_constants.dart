import 'package:flutter/foundation.dart';

class ApiConstants {
  /// PC Local IPv4 address for physical Android/iOS devices on local Wi-Fi.
  /// If using USB debugging, you can also run: `adb reverse tcp:5000 tcp:5000`
  static const String pcLocalIp = '192.168.1.2';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Uses host Wi-Fi IP so physical Android devices can connect
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
