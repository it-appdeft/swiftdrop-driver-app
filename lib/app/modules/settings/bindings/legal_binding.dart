import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../controllers/legal_controller.dart';

class LegalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalController>(() => LegalController(AuthRepository()));
  }
}
