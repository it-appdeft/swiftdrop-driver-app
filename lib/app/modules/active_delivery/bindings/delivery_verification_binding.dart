import 'package:get/get.dart';
import '../../../../data/repositories/order_repository.dart';
import '../controllers/delivery_verification_controller.dart';

class DeliveryVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    Get.lazyPut<DeliveryVerificationController>(
      () => DeliveryVerificationController(),
    );
  }
}
