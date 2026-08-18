import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController(AuthRepository()));
  }
}
