import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/driver_repository.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../modules/earnings/controllers/earnings_controller.dart';
import '../../../modules/notifications/controllers/notifications_controller.dart';
import '../../../modules/order_history/controllers/order_history_controller.dart';
import '../../../modules/profile/controllers/profile_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<DriverRepository>(() => DriverRepository());
    Get.lazyPut<EarningsRepository>(() => EarningsRepository());
    Get.lazyPut<NotificationRepository>(() => NotificationRepository());
    Get.lazyPut<AuthRepository>(() => AuthRepository());

    // Tab controllers (lazy — initialized only when tab is first visited)
    Get.lazyPut<DashboardController>(
        () => DashboardController(Get.find(), Get.find()));
    Get.lazyPut<OrderHistoryController>(
        () => OrderHistoryController(Get.find()));
    Get.lazyPut<EarningsController>(() => EarningsController(Get.find()));
    Get.lazyPut<NotificationsController>(
        () => NotificationsController(Get.find()));
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()));
  }
}
