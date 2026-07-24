import '../core/constants/api_constants.dart';
import '../models/donation_model.dart';
import '../models/request_model.dart';
import 'api_service.dart';
import 'mock_data.dart';

class DonationService {
  final ApiService _api = ApiService();

  Future<List<DonationModel>> getMyDonations() async {
    try {
      final response = await _api.get(ApiConstants.donations);
      return (response.data['donations'] as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.donorDonations();
    }
  }

  Future<List<DonationModel>> getAvailableDonations() async {
    try {
      final response = await _api.get(ApiConstants.donationsAvailable);
      return (response.data['donations'] as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.availableDonations();
    }
  }

  Future<DonationModel> createDonation(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConstants.donations, data: data);
      return DonationModel.fromMap(response.data['donation']);
    } catch (_) {
      return DonationModel(
        id: 'mock_new_${DateTime.now().millisecondsSinceEpoch}',
        donorId: 'mock_user',
        donorName: 'You',
        foodName: data['food_name'] ?? '',
        quantity: (data['quantity'] ?? 0).toDouble(),
        unit: data['unit'] ?? 'kg',
        expiryTime: DateTime.parse(data['expiry_time'] ?? DateTime.now().toIso8601String()),
        pickupAddress: data['pickup_address'] ?? '',
        photoUrl: data['photo_url'],
        status: DonationStatus.available,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<List<RequestModel>> getMyRequests() async {
    try {
      final response = await _api.get(ApiConstants.requests);
      return (response.data['requests'] as List)
          .map((e) => RequestModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.myRequests();
    }
  }

  Future<List<DonationModel>> getAllDonations() async {
    try {
      final response = await _api.get(ApiConstants.donations);
      return (response.data['donations'] as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.allDonations();
    }
  }
}
