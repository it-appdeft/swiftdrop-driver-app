import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/auth_enums.dart';
import '../../../constants/storage_keys.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthController extends BaseController {
  final AuthRepository _repo;
  AuthController(this._repo);

  // ─── Login Logic ───────────────────────────────────────────────────────────

  final phoneController = TextEditingController();
  final RxBool isPhoneValid = false.obs;
  final RxInt phoneLength = 0.obs;
  final RxBool showValidation = false.obs;
  final Rx<Country> selectedCountry = Country.parse('GB').obs; // Default to UK (+44)

  String get dialCode => '+${selectedCountry.value.phoneCode}';
  String get flagEmoji => selectedCountry.value.flagEmoji;
  String get isoCode => selectedCountry.value.countryCode;

  void onCountrySelected(Country country) =>
      selectedCountry.value = country;

  void onPhoneChanged(String value) {
    phoneLength.value = value.length;
    isPhoneValid.value = AppUtils.isValidPhone(value);
  }


  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return AppStrings.mobileNumberRequired;
    if (phone.length < 8 || phone.length > 12) {
      return AppStrings.mobileNumberInvalid;
    }
    return null;
  }

  // ─── Login Send OTP API ────────────────────────────────────────────────────
  Future<void> sendOtp() async {
    showValidation.value = true;
    if (validatePhone(phoneController.text.trim()) != null) return;
    await runAsync(() async {
      final phone = phoneController.text.trim();
      final result = await _repo.sendOtp(
        countryCode: dialCode,
        countryIso: isoCode,
        phone: phone,
        type: AuthOtpType.login,
        channel: AuthChannel.phone,
      );
      if (result.success) {
        _startResendTimer();
        if (result.data != null) {
          StorageService.to.writeData(StorageKeys.otpData, result.data);
        }
        final testCode = result.data?.testCode ?? '1111';
        AppUtils.showSuccess(AppStrings.otpSentSuccess.replaceFirst('%s', testCode));
        Get.toNamed(
          AppRoutes.otp,
          arguments: {'phone': phone, 'countryCode': dialCode, 'countryIso': isoCode},
        );
      } else {
        throw Exception(result.message);
      }
    });
  }

  // ─── OTP Logic ─────────────────────────────────────────────────────────────

  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  final RxString otpValue = ''.obs;
  final RxBool isOtpComplete = false.obs;
  final RxInt resendTimer = 0.obs;

  String get phone =>
      (Get.arguments as Map<String, dynamic>?)?['phone'] as String? ?? '';

  String get otpCountryCode =>
      (Get.arguments as Map<String, dynamic>?)?['countryCode'] as String? ??
      '+44';

  String get otpCountryIso =>
      (Get.arguments as Map<String, dynamic>?)?['countryIso'] as String? ??
      'GB';

  String get _fullOtp => otpController.text;

  void onOtpChanged(String value) {
    otpValue.value = value;
    isOtpComplete.value = value.length == AppConstants.otpLength;
    if (value.length == AppConstants.otpLength) {
      otpFocusNode.unfocus();
    }
  }

  void resetOtp() {
    otpController.clear();
    otpValue.value = '';
    isOtpComplete.value = false;
    resendTimer.value = 0;
  }

  // ─── Verify OTP API ───────────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (_fullOtp.length < AppConstants.otpLength) {
      AppUtils.showError(AppConstants.enterCompleteOtp);
      return;
    }
    await runAsync(() async {
      final result = await _repo.verifyOtp(
        phone: phone,
        countryCode: otpCountryCode,
        countryIso: otpCountryIso,
        otp: _fullOtp,
        fcmToken: StorageService.to.fcmToken,
        type: AuthOtpType.login,
        channel: AuthChannel.phone,
      );

      if (!result.success) throw Exception(result.message);

      final data = result.data;
      if (data?.accessToken != null && data?.driver != null) {
        AuthService.to.saveSession(
          accessToken: data!.accessToken!,
          refreshToken: data.refreshToken ?? '',
          user: data.driver!,
        );

        // Enable auto-login ONLY if registration is complete
        final setupStep = data?.driver?.setupStep ?? 0;
        StorageService.to.setAutoLogin(setupStep >= 3);
      }

      AppUtils.showSuccess(result.message);

      final setupStep = data?.driver?.setupStep ?? 0;
      if (setupStep >= 3) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.registerSteps, arguments: {'step': setupStep + 1});
      }
    });
  }

  // ─── Login Resend OTP API ──────────────────────────────────────────────────
  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        countryCode: otpCountryCode,
        countryIso: otpCountryIso,
        phone: phone,
        type: AuthOtpType.login,
        channel: AuthChannel.phone,
      );
      if (result.success) {
        AppUtils.showSuccess(AppStrings.resendOtp);
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
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
}
