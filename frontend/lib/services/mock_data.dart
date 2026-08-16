import '../models/donation_model.dart';
import '../models/request_model.dart';

class MockData {
  static final List<DonationModel> _donorList = [
    DonationModel(
      id: 'mock_d1',
      donorId: 'mock_user',
      donorName: 'You',
      foodName: 'Veggie Biryani',
      quantity: 10,
      unit: 'kg',
      expiryTime: DateTime.now().add(const Duration(hours: 6)),
      pickupAddress: '123 Main St, Downtown',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DonationModel(
      id: 'mock_d2',
      donorId: 'mock_user',
      donorName: 'You',
      foodName: 'Bread Packets',
      quantity: 20,
      unit: 'packets',
      expiryTime: DateTime.now().add(const Duration(days: 1)),
      pickupAddress: '123 Main St, Downtown',
      status: DonationStatus.reserved,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<DonationModel> _availableList = [
    DonationModel(
      id: 'mock_a1',
      donorId: 'donor_1',
      donorName: 'Green Leaf Hotel',
      foodName: 'Mixed Veg Curry & Rice',
      quantity: 25,
      unit: 'kg',
      expiryTime: DateTime.now().add(const Duration(hours: 4)),
      pickupAddress: '45 Park Avenue, Downtown',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    DonationModel(
      id: 'mock_a2',
      donorId: 'donor_2',
      donorName: 'City Bakery',
      foodName: 'Assorted Bread & Pastries',
      quantity: 50,
      unit: 'boxes',
      expiryTime: DateTime.now().add(const Duration(hours: 8)),
      pickupAddress: '12 Church Street, Westside',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    DonationModel(
      id: 'mock_a3',
      donorId: 'donor_3',
      donorName: 'Event Plaza Catering',
      foodName: 'Packed Lunch Boxes (Chicken & Veg)',
      quantity: 100,
      unit: 'boxes',
      expiryTime: DateTime.now().add(const Duration(hours: 3)),
      pickupAddress: '88 Convention Center Rd',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    DonationModel(
      id: 'mock_a4',
      donorId: 'donor_4',
      donorName: 'Sunrise Supermarket',
      foodName: 'Fresh Produce (Fruits & Vegetables)',
      quantity: 40,
      unit: 'kg',
      expiryTime: DateTime.now().add(const Duration(hours: 12)),
      pickupAddress: '204 Market Square',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DonationModel(
      id: 'mock_a5',
      donorId: 'donor_5',
      donorName: 'Royal Banquet Hall',
      foodName: 'Veggie Biryani & Raita',
      quantity: 35,
      unit: 'kg',
      expiryTime: DateTime.now().add(const Duration(hours: 5)),
      pickupAddress: '77 Grand Palace Road',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
  ];

  static List<DonationModel> donorDonations() => List.from(_donorList);

  static List<DonationModel> availableDonations() =>
      _availableList.where((d) => d.status == DonationStatus.available).toList();

  static void addDonation(DonationModel donation) {
    _donorList.insert(0, donation);
    _availableList.insert(0, donation);
  }

  static void markReserved(String donationId) {
    final idx = _availableList.indexWhere((d) => d.id == donationId);
    if (idx != -1) {
      final existing = _availableList[idx];
      _availableList[idx] = DonationModel(
        id: existing.id,
        donorId: existing.donorId,
        donorName: existing.donorName,
        foodName: existing.foodName,
        quantity: existing.quantity,
        unit: existing.unit,
        expiryTime: existing.expiryTime,
        pickupAddress: existing.pickupAddress,
        photoUrl: existing.photoUrl,
        status: DonationStatus.reserved,
        createdAt: existing.createdAt,
      );
    }
  }

  static List<RequestModel> myRequests() => [
        RequestModel(
          id: 'mock_r1',
          donationId: 'mock_a1',
          ngoId: 'mock_ngo',
          ngoName: 'Hope Foundation',
          donationName: 'Mixed Veg Curry',
          status: RequestStatus.accepted,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RequestModel(
          id: 'mock_r2',
          donationId: 'mock_a2',
          ngoId: 'mock_ngo',
          ngoName: 'Hope Foundation',
          donationName: 'Assorted Pastries',
          status: RequestStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ];

  static List<DonationModel> allDonations() => [
        ..._donorList,
        ..._availableList,
      ];
}
