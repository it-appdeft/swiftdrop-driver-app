import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';

class ProfileController extends BaseController {
  final AuthRepository _authRepo;

  ProfileController(this._authRepo);

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<void> refreshProfile() async {
    await runAsync(() async {
      final res = await _authRepo.getProfile();
      if (res.data != null) {
        AuthService.to.updateUser(res.data!);
      }
    });
  }

  void navigateToEditProfile() =>
      Get.toNamed(AppRoutes.editProfile, arguments: AuthService.to.user);

  void navigateToSettings() => Get.toNamed(AppRoutes.settings);

  void navigateToNotifications() => Get.toNamed(AppRoutes.notifications);

  void navigateToSupport() =>
      AppUtils.showInfo('Support feature coming soon');

  Future<void> logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDangerous: true,
    );
    if (!confirmed) return;
    AuthService.to.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> saveEditedProfile({
    required String name,
    String? email,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    await runAsync(() async {
      final res = await _authRepo.updateProfile(
        name: name,
        email: email,
        vehicleType: vehicleType,
        vehicleNumber: vehicleNumber,
      );
      if (res.data != null) {
        AuthService.to.updateUser(res.data!);
        AppUtils.showSuccess('Profile updated!');
        Get.back();
      }
    });
  }
}
