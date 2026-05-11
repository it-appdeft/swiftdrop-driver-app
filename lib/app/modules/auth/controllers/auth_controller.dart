import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthController extends BaseController {
  final AuthRepository _repo;
  AuthController(this._repo);

  // ─── Login ─────────────────────────────────────────────────────────────────

  final phoneController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  final RxBool isPhoneValid = false.obs;

  void onPhoneChanged(String value) =>
      isPhoneValid.value = AppUtils.isValidPhone(value);

  Future<void> sendOtp() async {
    if (!loginFormKey.currentState!.validate()) return;
    await runAsync(() async {
      final phone = phoneController.text.trim();
      final result = await _repo.sendOtp(phone);
      if (result.success) {
        _startResendTimer();
        Get.toNamed(AppRoutes.otp, arguments: {'phone': phone});
      } else {
        throw Exception(result.message);
      }
    });
  }

  // ─── OTP — 4 individual boxes ──────────────────────────────────────────────

  final otpBoxControllers =
      List.generate(4, (_) => TextEditingController());
  final otpBoxFocusNodes = List.generate(4, (_) => FocusNode());
  final RxBool isOtpComplete = false.obs;
  final RxInt resendTimer = 0.obs;

  String get phone =>
      (Get.arguments as Map<String, dynamic>?)?['phone'] as String? ?? '';

  String get _fullOtp =>
      otpBoxControllers.map((c) => c.text).join();

  void onOtpBoxChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      otpBoxFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpBoxFocusNodes[index - 1].requestFocus();
    }
    isOtpComplete.value = _fullOtp.length == AppConstants.otpLength;
  }

  Future<void> verifyOtp() async {
    if (_fullOtp.length < AppConstants.otpLength) {
      AppUtils.showError('Please enter the complete OTP');
      return;
    }
    if (_fullOtp != AppConstants.defaultOtp) {
      AppUtils.showError('Invalid OTP. Please enter the correct code.');
      return;
    }
    await runAsync(() async {
      final result = await _repo.verifyOtp(
        phone: phone,
        otp: _fullOtp,
        fcmToken: StorageService.to.fcmToken,
      );
      if (!result.success) throw Exception(result.message);

      final data = result.data!;
      final user =
          UserModel.fromJson(data['driver'] as Map<String, dynamic>);
      AuthService.to.saveSession(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        user: user,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    await runAsync(() async {
      final result = await _repo.sendOtp(phone);
      if (result.success) {
        AppUtils.showSuccess('OTP resent successfully');
        _startResendTimer();
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
  }

  void _startResendTimer() {
    resendTimer.value = AppConstants.otpResendTimer;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value <= 0) return false;
      resendTimer.value--;
      return resendTimer.value > 0;
    });
  }

  @override
  void onClose() {
    phoneController.dispose();
    for (final c in otpBoxControllers) { c.dispose(); }
    for (final f in otpBoxFocusNodes) { f.dispose(); }
    super.onClose();
  }
}
