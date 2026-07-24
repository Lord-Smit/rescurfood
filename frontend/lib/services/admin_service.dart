import '../core/constants/api_constants.dart';
import '../models/registration_request.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _api = ApiService();

  Future<List<RegistrationRequest>> getRequests({String? status}) async {
    final params = status != null ? {'status': status} : null;
    final response = await _api.get(ApiConstants.adminRequests, queryParams: params);
    final resData = response.data['data'] ?? response.data;
    final list = (resData['requests'] as List? ?? []);
    return list.map((e) => RegistrationRequest.fromMap(e)).toList();
  }

  Future<RegistrationRequest> getRequestById(String id) async {
    final response = await _api.get('${ApiConstants.adminRequests}/$id');
    final resData = response.data['data'] ?? response.data;
    return RegistrationRequest.fromMap(resData);
  }

  Future<void> approveRequest(String id) async {
    await _api.patch('${ApiConstants.adminRequests}/$id/approve');
  }

  Future<void> rejectRequest(String id) async {
    await _api.patch('${ApiConstants.adminRequests}/$id/reject');
  }

  Future<List<UserModel>> getAllUsers({String? role}) async {
    final params = role != null ? {'role': role} : null;
    final response = await _api.get(ApiConstants.users, queryParams: params);
    final resData = response.data['data'] ?? response.data;
    final list = (resData['users'] as List? ?? []);
    return list.map((e) => UserModel.fromMap(e)).toList();
  }
}
