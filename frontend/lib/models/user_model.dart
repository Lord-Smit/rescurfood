enum UserRole { donor, ngo, admin }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.donor:
        return 'donor';
      case UserRole.ngo:
        return 'ngo';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.ngo:
        return 'NGO / Volunteer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'donor':
        return UserRole.donor;
      case 'ngo':
        return UserRole.ngo;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.donor;
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRoleExtension.fromString(map['role'] ?? 'donor'),
      token: map['token'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.value,
        'token': token,
      };
}
