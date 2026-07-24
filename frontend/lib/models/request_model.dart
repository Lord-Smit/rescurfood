enum RequestStatus { pending, accepted, pickedUp, completed, cancelled }

extension RequestStatusExtension on RequestStatus {
  String get value {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.accepted:
        return 'accepted';
      case RequestStatus.pickedUp:
        return 'picked_up';
      case RequestStatus.completed:
        return 'completed';
      case RequestStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.pickedUp:
        return 'Picked Up';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  static RequestStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return RequestStatus.pending;
      case 'accepted':
        return RequestStatus.accepted;
      case 'picked_up':
        return RequestStatus.pickedUp;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }
}

class RequestModel {
  final String id;
  final String donationId;
  final String ngoId;
  final String ngoName;
  final String donationName;
  final String? donorName;
  final RequestStatus status;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.donationId,
    required this.ngoId,
    required this.ngoName,
    required this.donationName,
    this.donorName,
    required this.status,
    required this.createdAt,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['_id'] ?? map['id'] ?? '',
      donationId: map['donation_id'] ?? map['donationId'] ?? '',
      ngoId: map['ngo_id'] ?? map['ngoId'] ?? '',
      ngoName: map['ngo_name'] ?? map['ngoName'] ?? '',
      donationName: map['donation_name'] ?? map['donationName'] ?? '',
      donorName: map['donor_name'] ?? map['donorName'],
      status: RequestStatusExtension.fromString(map['status'] ?? 'pending'),
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'donation_id': donationId,
        'status': status.value,
        'donor_name': donorName,
      };
}
