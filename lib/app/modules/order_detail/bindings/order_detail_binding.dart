import 'package:get/get.dart';
import '../../../../data/repositories/order_repository.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<OrderDetailController>(
      () => OrderDetailController(Get.find()),
    );
  }
}
