import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _apiClient.get(ApiEndpoints.notifications);
    final list = res.data['notifications'] ?? res.data['data'] ?? [];
    return (list as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.put('${ApiEndpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put(ApiEndpoints.readAllNotifications);
  }
}
