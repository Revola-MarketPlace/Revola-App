import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _apiClient.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'BUYER',
    String? phoneNumber,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });
    return res.data;
  }

  Future<UserModel> getMe() async {
    final res = await _apiClient.get(ApiEndpoints.me);
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson);
  }

  Future<UserModel> selectRole(String role) async {
    final res = await _apiClient.post(ApiEndpoints.selectRole, data: {'role': role});
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson);
  }

  Future<UserModel> submitSellerOnboarding(Map<String, dynamic> data) async {
    final res = await _apiClient.post(ApiEndpoints.sellerOnboarding, data: data);
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson);
  }
}
