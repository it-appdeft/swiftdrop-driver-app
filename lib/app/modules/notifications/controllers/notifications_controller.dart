import 'package:get/get.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../base/base_controller.dart';

class NotificationsController extends BaseController {
  final NotificationRepository _repo;

  NotificationsController(this._repo);

  final notifications = <NotificationModel>[].obs;
  final unreadCount   = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    await runAsync(() async {
      final res = await _repo.getNotifications();
      notifications.assignAll(res.data ?? []);
      _refreshUnread();
    });
  }

  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || notifications[idx].isRead) return;
    notifications[idx] = notifications[idx].copyWith(isRead: true);
    _refreshUnread();
    try {
      await _repo.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
    _refreshUnread();
    try {
      await _repo.markAllAsRead();
    } catch (_) {}
  }

  void _refreshUnread() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
}
