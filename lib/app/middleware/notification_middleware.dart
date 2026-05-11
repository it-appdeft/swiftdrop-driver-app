import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../utils/app_logger.dart';

// Ensures notification service is warmed up when entering the main app flow
class NotificationMiddleware extends GetMiddleware {
  @override
  int? get priority => 3;

  @override
  GetPage? onPageCalled(GetPage? page) {
    _ensureNotificationService();
    return page;
  }

  void _ensureNotificationService() {
    try {
      if (!Get.isRegistered<NotificationService>()) {
        AppLogger.w('NotificationService not registered — skipping');
        return;
      }
      // Service is already initialized via InitialBinding
      AppLogger.d('NotificationMiddleware: service active');
    } catch (e) {
      AppLogger.e('NotificationMiddleware error', e);
    }
  }
}
