import 'package:get/get.dart';
import '../controllers/delivery_verification_controller.dart';

class DeliveryVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryVerificationController>(
      () => DeliveryVerificationController(),
    );
  }
}
