import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.notifications);
      final list = res.data['notifications'] ?? res.data['data'] ?? [];
      if (list is List) {
        return list.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is ApiException && (e.statusCode == 401 || e.statusCode == 404)) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.put('${ApiEndpoints.notifications}/$id/read');
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put(ApiEndpoints.readAllNotifications);
    } catch (_) {}
  }
}
