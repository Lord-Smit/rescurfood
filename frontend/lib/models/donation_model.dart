enum DonationStatus { available, reserved, pickedUp, completed, expired }

extension DonationStatusExtension on DonationStatus {
  String get value {
    switch (this) {
      case DonationStatus.available:
        return 'available';
      case DonationStatus.reserved:
        return 'reserved';
      case DonationStatus.pickedUp:
        return 'picked_up';
      case DonationStatus.completed:
        return 'completed';
      case DonationStatus.expired:
        return 'expired';
    }
  }

  String get displayName {
    switch (this) {
      case DonationStatus.available:
        return 'Available';
      case DonationStatus.reserved:
        return 'Reserved';
      case DonationStatus.pickedUp:
        return 'Picked Up';
      case DonationStatus.completed:
        return 'Completed';
      case DonationStatus.expired:
        return 'Expired';
    }
  }

  static DonationStatus fromString(String status) {
    switch (status) {
      case 'available':
        return DonationStatus.available;
      case 'reserved':
        return DonationStatus.reserved;
      case 'picked_up':
        return DonationStatus.pickedUp;
      case 'completed':
        return DonationStatus.completed;
      case 'expired':
        return DonationStatus.expired;
      default:
        return DonationStatus.available;
    }
  }
}

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String foodName;
  final double quantity;
  final String unit;
  final DateTime expiryTime;
  final String pickupAddress;
  final String? photoUrl;
  final DonationStatus status;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.expiryTime,
    required this.pickupAddress,
    this.photoUrl,
    required this.status,
    required this.createdAt,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is Map && val['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch((val['_seconds'] as int) * 1000);
      }
      return DateTime.now();
    }

    return DonationModel(
      id: map['_id'] ?? map['id'] ?? '',
      donorId: map['donor_id'] ?? map['donorId'] ?? '',
      donorName: map['donor_name'] ?? map['donorName'] ?? '',
      foodName: map['food_name'] ?? map['foodName'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'kg',
      expiryTime: parseDate(map['expiry_time'] ?? map['expiryTime']),
      pickupAddress: map['pickup_address'] ?? map['pickupAddress'] ?? '',
      photoUrl: map['photo_url'] ?? map['photoUrl'],
      status: DonationStatusExtension.fromString(map['status'] ?? 'available'),
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'food_name': foodName,
        'quantity': quantity,
        'unit': unit,
        'expiry_time': expiryTime.toIso8601String(),
        'pickup_address': pickupAddress,
        'photo_url': photoUrl,
        'status': status.value,
      };
}
