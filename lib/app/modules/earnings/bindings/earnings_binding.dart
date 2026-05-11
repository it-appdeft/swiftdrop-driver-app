import 'package:get/get.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../controllers/earnings_controller.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsRepository>(() => EarningsRepository());
    Get.lazyPut<EarningsController>(
      () => EarningsController(Get.find()),
    );
  }
}
