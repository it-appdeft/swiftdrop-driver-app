import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/driver_repository.dart';
import '../../data/repositories/earnings_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/realtime_service.dart';
import '../services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services — permanent throughout app lifetime
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<LocationService>(LocationService(), permanent: true);
    Get.put<RealtimeService>(RealtimeService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);

    // Global Core Repositories — available across all routes
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    Get.lazyPut<DriverRepository>(() => DriverRepository(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<EarningsRepository>(() => EarningsRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => NotificationRepository(), fenix: true);
  }
}
