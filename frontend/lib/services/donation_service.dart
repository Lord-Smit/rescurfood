import 'package:flutter/foundation.dart';
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
      final resData = response.data['data'] ?? response.data;
      return ((resData['donations'] ?? []) as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.donorDonations();
    }
  }

  Future<List<DonationModel>> getAllDonations() async {
    try {
      final response = await _api.get(ApiConstants.donations);
      final resData = response.data['data'] ?? response.data;
      return ((resData['donations'] ?? []) as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.availableDonations();
    }
  }

  Future<List<DonationModel>> getAvailableDonations() async {
    try {
      final response = await _api.get(ApiConstants.donationsAvailable);
      final resData = response.data['data'] ?? response.data;
      return ((resData['donations'] ?? []) as List)
          .map((e) => DonationModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.availableDonations();
    }
  }

  Future<String?> uploadFoodPhoto(String filePath) async {
    try {
      final response = await _api.uploadFile(ApiConstants.uploadFoodPhoto, filePath);
      final resData = response.data['data'] ?? response.data;
      return resData['url'] as String?;
    } catch (e) {
      debugPrint('Photo upload error: $e');
      return null;
    }
  }

  Future<DonationModel> createDonation(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConstants.donations, data: data);
      final resData = response.data['data'] ?? response.data;
      final created = DonationModel.fromMap(resData['donation'] ?? resData);
      MockData.addDonation(created);
      return created;
    } catch (_) {
      final fallback = DonationModel(
        id: 'mock_new_${DateTime.now().millisecondsSinceEpoch}',
        donorId: 'mock_user',
        donorName: 'You',
        foodName: data['food_name'] ?? '',
        quantity: (data['quantity'] ?? 0).toDouble(),
        unit: data['unit'] ?? 'kg',
        expiryTime: DateTime.tryParse(data['expiry_time'] ?? '') ??
            DateTime.now().add(const Duration(days: 1)),
        pickupAddress: data['pickup_address'] ?? '',
        photoUrl: data['photo_url'],
        status: DonationStatus.available,
        createdAt: DateTime.now(),
      );
      MockData.addDonation(fallback);
      return fallback;
    }
  }

  Future<bool> claimDonation(String donationId) async {
    try {
      await _api.post(ApiConstants.requests, data: {'donation_id': donationId});
      return true;
    } catch (e) {
      debugPrint('Claim donation error: $e');
      return false;
    }
  }

  Future<bool> updateRequestStatus(String requestId, String status) async {
    try {
      await _api.patch('${ApiConstants.requests}/$requestId/status',
          data: {'status': status});
      return true;
    } catch (e) {
      debugPrint('Update request status error: $e');
      return false;
    }
  }

  Future<List<RequestModel>> getMyRequests() async {
    try {
      final response = await _api.get(ApiConstants.requests);
      final resData = response.data['data'] ?? response.data;
      return ((resData['requests'] ?? []) as List)
          .map((e) => RequestModel.fromMap(e))
          .toList();
    } catch (_) {
      return MockData.myRequests();
    }
  }
}
