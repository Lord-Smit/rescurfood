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
      foodName: 'Mixed Veg Curry',
      quantity: 25,
      unit: 'kg',
      expiryTime: DateTime.now().add(const Duration(hours: 4)),
      pickupAddress: '45 Park Avenue',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    DonationModel(
      id: 'mock_a2',
      donorId: 'donor_2',
      donorName: 'City Bakery',
      foodName: 'Assorted Pastries',
      quantity: 50,
      unit: 'boxes',
      expiryTime: DateTime.now().add(const Duration(hours: 8)),
      pickupAddress: '12 Church Street',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    DonationModel(
      id: 'mock_a3',
      donorId: 'donor_3',
      donorName: 'Event Plaza',
      foodName: 'Packed Lunch Boxes',
      quantity: 100,
      unit: 'boxes',
      expiryTime: DateTime.now().add(const Duration(hours: 3)),
      pickupAddress: '88 Convention Center Rd',
      status: DonationStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  static List<DonationModel> donorDonations() => List.from(_donorList);

  static List<DonationModel> availableDonations() => List.from(_availableList);

  static void addDonation(DonationModel donation) {
    _donorList.insert(0, donation);
    _availableList.insert(0, donation);
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
