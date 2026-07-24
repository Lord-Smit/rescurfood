import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get(ApiConstants.usersMe);
    return (response.data['data'] ?? response.data) as Map<String, dynamic>;
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put(ApiConstants.usersMe, data: data);
    final resData = (response.data['data'] ?? response.data) as Map<String, dynamic>;
    return UserModel.fromMap(resData);
  }

  Future<Map<String, dynamic>> getImpact() async {
    final response = await _api.get(ApiConstants.usersImpact);
    return (response.data['data'] ?? response.data) as Map<String, dynamic>;
  }
}
