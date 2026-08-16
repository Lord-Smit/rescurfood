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

class RequestTimelineItem {
  final String key;
  final String label;
  final DateTime? at;
  final bool done;
  final bool active;

  RequestTimelineItem({
    required this.key,
    required this.label,
    this.at,
    required this.done,
    this.active = false,
  });

  factory RequestTimelineItem.fromMap(Map<String, dynamic> map) {
    return RequestTimelineItem(
      key: map['key'] ?? '',
      label: map['label'] ?? '',
      at: map['at'] != null ? DateTime.tryParse(map['at'].toString()) : null,
      done: map['done'] == true,
      active: map['active'] == true,
    );
  }
}

class RequestModel {
  final String id;
  final String donationId;
  final String ngoId;
  final String ngoName;
  final String donationName;
  final String? donorName;
  final String? donorPhone;
  final String? pickupAddress;
  final String? quantity;
  final String? unit;
  final RequestStatus status;
  final DateTime createdAt;
  final List<RequestTimelineItem> timeline;

  RequestModel({
    required this.id,
    required this.donationId,
    required this.ngoId,
    required this.ngoName,
    required this.donationName,
    this.donorName,
    this.donorPhone,
    this.pickupAddress,
    this.quantity,
    this.unit,
    required this.status,
    required this.createdAt,
    this.timeline = const [],
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    List<RequestTimelineItem> parsedTimeline = [];
    if (map['timeline'] is List) {
      parsedTimeline = (map['timeline'] as List)
          .map((e) => RequestTimelineItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return RequestModel(
      id: map['_id'] ?? map['id'] ?? '',
      donationId: map['donation_id'] ?? map['donationId'] ?? '',
      ngoId: map['ngo_id'] ?? map['ngoId'] ?? '',
      ngoName: map['ngo_name'] ?? map['ngoName'] ?? '',
      donationName: map['donation_name'] ?? map['donationName'] ?? '',
      donorName: map['donor_name'] ?? map['donorName'],
      donorPhone: map['donor_phone'] ?? map['donorPhone'],
      pickupAddress: map['pickup_address'] ?? map['pickupAddress'],
      quantity: map['quantity']?.toString(),
      unit: map['unit']?.toString(),
      status: RequestStatusExtension.fromString(map['status'] ?? 'pending'),
      createdAt: DateTime.parse(
          map['created_at'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()),
      timeline: parsedTimeline,
    );
  }

  Map<String, dynamic> toMap() => {
        'donation_id': donationId,
        'status': status.value,
        'donor_name': donorName,
      };

  int get stepIndex {
    switch (status) {
      case RequestStatus.pending:
        return 0;
      case RequestStatus.accepted:
        return 1;
      case RequestStatus.pickedUp:
        return 2;
      case RequestStatus.completed:
        return 3;
      case RequestStatus.cancelled:
        return -1;
    }
  }

  String? get nextStatus {
    switch (status) {
      case RequestStatus.pending:
        return 'accepted';
      case RequestStatus.accepted:
        return 'picked_up';
      case RequestStatus.pickedUp:
        return 'completed';
      case RequestStatus.completed:
      case RequestStatus.cancelled:
        return null;
    }
  }

  String? get nextStatusActionLabel {
    switch (status) {
      case RequestStatus.pending:
        return 'Accept Request';
      case RequestStatus.accepted:
        return 'Confirm Pickup';
      case RequestStatus.pickedUp:
        return 'Mark Delivered';
      case RequestStatus.completed:
      case RequestStatus.cancelled:
        return null;
    }
  }

  String? get nextStatusConfirmationMessage {
    switch (status) {
      case RequestStatus.pending:
        return 'Are you sure you want to accept this request? You will be responsible for picking up "$donationName".';
      case RequestStatus.accepted:
        return 'Have you arrived at the pickup location and collected "$donationName"?';
      case RequestStatus.pickedUp:
        return 'Have you successfully delivered "$donationName" to the intended beneficiaries?';
      default:
        return null;
    }
  }
}

