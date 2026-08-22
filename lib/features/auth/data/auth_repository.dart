import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _apiClient.post(ApiEndpoints.login, data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    final data = Map<String, dynamic>.from(res.data is Map ? res.data : {});
    
    // Extract token from body or from set-cookie headers
    String? token = data['token']?.toString() ?? data['accessToken']?.toString();
    if (token == null || token.isEmpty) {
      final rawCookies = res.headers['set-cookie'];
      if (rawCookies != null) {
        for (final cookie in rawCookies) {
          final match = RegExp(r'accessToken=([^;]+)').firstMatch(cookie);
          if (match != null) {
            token = match.group(1);
            break;
          }
        }
      }
    }

    data['extractedToken'] = token;
    return data;
  }

  Future<Map<String, dynamic>> googleAuth({
    String? credential,
    String? accessToken,
    String? email,
    String? name,
    String? googleId,
    String? avatar,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.googleAuth, data: {
      if (credential != null) 'credential': credential,
      if (accessToken != null) 'accessToken': accessToken,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (googleId != null) 'googleId': googleId,
      if (avatar != null) 'avatar': avatar,
    });

    final data = Map<String, dynamic>.from(res.data is Map ? res.data : {});

    String? token = data['token']?.toString() ?? data['accessToken']?.toString();
    if (token == null || token.isEmpty) {
      final rawCookies = res.headers['set-cookie'];
      if (rawCookies != null) {
        for (final cookie in rawCookies) {
          final match = RegExp(r'accessToken=([^;]+)').firstMatch(cookie);
          if (match != null) {
            token = match.group(1);
            break;
          }
        }
      }
    }

    data['extractedToken'] = token;
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'BUYER',
    String? phoneNumber,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.register, data: {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    });

    final data = Map<String, dynamic>.from(res.data is Map ? res.data : {});
    String? token = data['token']?.toString() ?? data['accessToken']?.toString();
    if (token == null || token.isEmpty) {
      final rawCookies = res.headers['set-cookie'];
      if (rawCookies != null) {
        for (final cookie in rawCookies) {
          final match = RegExp(r'accessToken=([^;]+)').firstMatch(cookie);
          if (match != null) {
            token = match.group(1);
            break;
          }
        }
      }
    }
    data['extractedToken'] = token;
    return data;
  }

  Future<UserModel> getMe() async {
    final res = await _apiClient.get(ApiEndpoints.me);
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson is Map<String, dynamic> ? userJson : {});
  }

  Future<UserModel> selectRole(String role) async {
    final res = await _apiClient.post(ApiEndpoints.selectRole, data: {'role': role});
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson is Map<String, dynamic> ? userJson : {});
  }

  Future<UserModel> submitSellerOnboarding(Map<String, dynamic> data) async {
    final res = await _apiClient.post(ApiEndpoints.sellerOnboarding, data: data);
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson is Map<String, dynamic> ? userJson : {});
  }
}
