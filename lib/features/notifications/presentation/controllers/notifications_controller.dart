import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationsRepository(client);
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.isLoading || !auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
    return [];
  }
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});
