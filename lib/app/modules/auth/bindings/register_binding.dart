import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<RegisterController>(() => RegisterController(Get.find()));
  }
}
