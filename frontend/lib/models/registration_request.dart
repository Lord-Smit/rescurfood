class RegistrationRequest {
  final String id;
  final String type;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final DateTime createdAt;

  RegistrationRequest({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  factory RegistrationRequest.fromMap(Map<String, dynamic> map) {
    return RegistrationRequest(
      id: map['_id'] ?? map['id'] ?? '',
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? 'PENDING',
      createdAt: DateTime.parse(
        map['createdAt'] ?? map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
