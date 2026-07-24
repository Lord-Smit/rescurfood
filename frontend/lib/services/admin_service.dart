import '../core/constants/api_constants.dart';
import '../models/registration_request.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  Future<List<RegistrationRequest>> getRequests({String? status}) async {
    final params = status != null ? {'status': status} : null;
    final response = await _api.get(ApiConstants.adminRequests, queryParams: params);
    final list = (response.data['data']['requests'] as List);
    return list.map((e) => RegistrationRequest.fromMap(e)).toList();
  }

  Future<RegistrationRequest> getRequestById(String id) async {
    final response = await _api.get('${ApiConstants.adminRequests}/$id');
    return RegistrationRequest.fromMap(response.data['data']);
  }

  Future<void> approveRequest(String id) async {
    await _api.patch('${ApiConstants.adminRequests}/$id/approve');
  }

  Future<void> rejectRequest(String id) async {
    await _api.patch('${ApiConstants.adminRequests}/$id/reject');
  }
}
