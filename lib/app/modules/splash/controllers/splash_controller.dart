import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class SplashController extends BaseController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDuration),
    );
    try {
      if (!StorageService.to.onboardingCompleted) {
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }
      if (AuthService.to.isAuthenticated) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
