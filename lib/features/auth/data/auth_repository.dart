import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final cleanId = identifier.trim().toLowerCase();
    final res = await _apiClient.post(ApiEndpoints.login, data: {
      'identifier': cleanId,
      'email': cleanId,
      'username': cleanId,
      'password': password,
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

  Future<Map<String, dynamic>> googleAuth({
    String? credential,
    String? accessToken,
    String? email,
    String? name,
    String? googleId,
    String? avatar,
    String? role,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.googleAuth, data: {
      if (credential != null) 'credential': credential,
      if (accessToken != null) 'accessToken': accessToken,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (googleId != null) 'googleId': googleId,
      if (avatar != null) 'avatar': avatar,
      if (role != null) 'role': role,
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
    required String username,
    required String email,
    required String password,
    String? name,
    String role = 'BUYER',
    String? phoneNumber,
  }) async {
    final res = await _apiClient.post(ApiEndpoints.register, data: {
      'username': username.trim().toLowerCase(),
      'name': (name?.trim().isNotEmpty == true ? name!.trim() : username.trim()),
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

  Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? phoneNumber,
    String? avatar,
  }) async {
    final res = await _apiClient.put(ApiEndpoints.updateDetails, data: {
      if (name != null) 'name': name.trim(),
      if (username != null) 'username': username.trim().toLowerCase(),
      if (phoneNumber != null) 'phoneNumber': phoneNumber.trim(),
      if (avatar != null) 'avatar': avatar,
    });
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson is Map<String, dynamic> ? userJson : {});
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final filename = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData();
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(filePath, filename: filename)),
      );
      final res = await _apiClient.post('${ApiEndpoints.products}/upload', data: formData);
      final rawList = res.data['urls'] ?? res.data['images'] ?? res.data['data'] ?? [];
      if (rawList is List && rawList.isNotEmpty) {
        final avatarUrl = rawList.first.toString();
        await updateProfile(avatar: avatarUrl);
        return avatarUrl;
      }
    } catch (_) {}
    return '';
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.put(ApiEndpoints.updatePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'password': newPassword,
    });
  }

  Future<String> forgotPassword(String identifier) async {
    final res = await _apiClient.post('/auth/forgotpassword', data: {
      'identifier': identifier.trim().toLowerCase(),
      'email': identifier.trim().toLowerCase(),
      'username': identifier.trim().toLowerCase(),
    });
    return res.data['message']?.toString() ?? 'Password recovery instructions have been sent.';
  }

  Future<UserModel> completeOnboarding(Map<String, dynamic> payload) async {
    final res = await _apiClient.post('/auth/onboarding', data: payload);
    final userJson = res.data['user'] ?? res.data['data'] ?? res.data;
    return UserModel.fromJson(userJson is Map<String, dynamic> ? userJson : {});
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
    return completeOnboarding(data);
  }
}
