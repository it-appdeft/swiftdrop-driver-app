import 'package:get/get.dart';
import '../../../../data/repositories/order_repository.dart';
import '../controllers/active_delivery_controller.dart';

class ActiveDeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveDeliveryController>(
      () => ActiveDeliveryController(Get.find<OrderRepository>()),
    );
  }
}
