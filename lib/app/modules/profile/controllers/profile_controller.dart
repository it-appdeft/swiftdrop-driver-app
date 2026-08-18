import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/auth_enums.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_confirm_dialog.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import 'dart:async';
import 'dart:io';

class ProfileController extends BaseController {
  final AuthRepository _authRepo;
  ProfileController(this._authRepo);

  // ─── Profile Form Fields ───────────────────────────────────────────────────

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final newContactController = TextEditingController();
  final RxBool showValidation = false.obs;
  final RxInt newPhoneLength = 0.obs;
  final Rx<File?> avatarFile = Rx<File?>(null);
  final Rx<Country> selectedCountry = Country.parse('GB').obs;
  String _originalName = '';

  /// True only when the driver has actually changed the name or picked a new photo.
  final RxBool canSave = false.obs;

  UserModel? get user => AuthService.to.user;

  String get dialCode => '+${selectedCountry.value.phoneCode}';
  String get flagEmoji => selectedCountry.value.flagEmoji;
  String get isoCode => selectedCountry.value.countryCode;

  void onCountrySelected(Country country) => selectedCountry.value = country;

  void onNewPhoneChanged(String value) {
    newPhoneLength.value = value.length;
  }
  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return AppStrings.mobileNumberRequired;
    if (phone.length < 8 || phone.length > 12) {
      return AppStrings.mobileNumberInvalid;
    }
    return null;
  }

  // ─── OTP Screen State ──────────────────────────────────────────────────────
  // Shared with AppRoutes.otp — the OTP screen reads these via Get.arguments
  // and drives its display from these observables through this same controller.

  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  final RxInt resendTimer = 0.obs;
  final RxBool isOtpComplete = false.obs;
  final RxBool isSaving = false.obs;

  /// Spinner for the "Send OTP to current phone" button on the change-contact screen.
  final RxBool isPhoneSending = false.obs;

  /// Spinner for the "Send OTP to current email" button on the change-contact screen.
  final RxBool isEmailSending = false.obs;
  Worker? _userWorker;
  Worker? _avatarWorker;

  // ─── Route-Argument Helpers ────────────────────────────────────────────────
  // The OTP screen is shared across auth and profile flows. These getters pull
  // the typed arguments passed via Get.toNamed so the controller knows which
  // contact and which step it is currently handling.

  /// The phone number being verified (local digits, no country code).
  String get phone => Get.arguments?['phone'] ?? '';
  String get email => Get.arguments?['email'] ?? '';
  String get otpCountryCode => Get.arguments?['countryCode'] ?? '+44';
  String get otpCountryIso => Get.arguments?['countryIso'] ?? 'GB';

  /// Which OTP operation the backend should verify against.
  AuthOtpType? get _argOtpType => Get.arguments?['otpType'] as AuthOtpType?;

  /// 'verify-existing' → proving ownership of the current contact.
  /// 'verify-new'      → confirming the new contact the driver wants to use.
  String get _argMode => Get.arguments?['mode'] ?? '';

  /// 'phone' or 'email' — determines which branch of [verifyOtp] to follow.
  String get _argType => Get.arguments?['type'] ?? '';

  String get _argPhone => phone;
  String get _argEmail => email;
  String get _argCountryCode => otpCountryCode;

  void onOtpChanged(String value) {
    isOtpComplete.value = value.length == AppConstants.otpLength;
  }

  void resetLoaders() {
    isSaving.value = false;
    isPhoneSending.value = false;
    isEmailSending.value = false;
    isLoading.value = false;
  }

  void resetOtp() {
    resetLoaders();
    otpController.clear();
    isOtpComplete.value = false;
    resendTimer.value = 0;
  }

  // ─── Private OTP API Helper ────────────────────────────────────────────────
  Future<void> _sendOtpApi({
    required AuthOtpType type,
    String? phone,
    String? countryCode,
    String? countryIso,
    String? email,
  }) async {
    final isEmail = email != null;
    final result = await _authRepo.sendOtp(
      phone: phone,
      countryCode: countryCode,
      countryIso: countryIso,
      email: email,
      type: type,
      channel: isEmail ? AuthChannel.email : AuthChannel.phone,
      userType: UserType.driver,
    );

    if (result.success) {
      _startResendTimer();
      // Backend returns a test_code during development so QA can verify without SMS.
      final testCode = result.data?.testCode ?? '1111';
      AppUtils.showSuccess(
          AppStrings.otpSentSuccess.replaceFirst('%s', testCode));
    } else {
      throw Exception(result.message);
    }
  }

  // ─── Step 1: Initiate Contact Change (Verify Current Contact) ─────────────

  void startPhoneChange() async {
    await runAsync(() async {
      isPhoneSending.value = true;
      final phone = phoneController.text.trim();
      final cc = dialCode;
      try {
        await _sendOtpApi(
          type: AuthOtpType.verifyCurrentPhone,
          phone: phone,
          countryCode: cc,
          countryIso: isoCode,
        );
        isPhoneSending.value = false;
        Get.toNamed(AppRoutes.otp, arguments: {
          'from': 'profile',
          'mode': 'verify-existing',
          'otpType': AuthOtpType.verifyCurrentPhone,
          'type': 'phone',
          'phone': phone,
          'countryCode': cc,
          'countryIso': isoCode,
        });
      } finally {
        if (!isClosed) isPhoneSending.value = false;
      }
    }, showLoadingIndicator: false);
  }

  void startEmailChange() async {
    await runAsync(() async {
      isEmailSending.value = true;
      final email = emailController.text.trim();
      try {
        await _sendOtpApi(
          type: AuthOtpType.verifyCurrentEmail,
          email: email,
        );
        isEmailSending.value = false;
        Get.toNamed(AppRoutes.otp, arguments: {
          'from': 'profile',
          'mode': 'verify-existing',
          'otpType': AuthOtpType.verifyCurrentEmail,
          'type': 'email',
          'email': email,
          // 'phone' key reused here because OtpView reads it for the masked display.
          'phone': email,
        });
      } finally {
        if (!isClosed) isEmailSending.value = false;
      }
    }, showLoadingIndicator: false);
  }

  // ─── Step 2: Send OTP to New Contact ──────────────────────────────────────

  /// After verifying the current phone, sends an OTP to the *new* number the
  /// driver wants to switch to. Navigates to OTP screen in 'verify-new' mode.
  Future<void> sendOtpToNewPhone(String newPhone) async {
    showValidation.value = true;
    final phone = newPhone.trim();
    if (validatePhone(phone) != null) return;

    await runAsync(() async {
      isPhoneSending.value = true;
      await _sendOtpApi(
        type: AuthOtpType.updatePhone,
        phone: phone,
        countryCode: dialCode,
        countryIso: isoCode,
      );
      if (!isClosed) isPhoneSending.value = false;

      Get.toNamed(AppRoutes.otp, arguments: {
        'from': 'profile',
        'mode': 'verify-new',
        'otpType': AuthOtpType.updatePhone,
        'type': 'phone',
        'phone': phone,
        'countryCode': dialCode,
        'countryIso': isoCode,
      });
    }, showLoadingIndicator: false);
  }

  /// After verifying the current email, sends an OTP to the *new* email address.
  /// Navigates to OTP screen in 'verify-new' mode.
  Future<void> sendOtpToNewEmail(String newEmail) async {
    showValidation.value = true;
    final email = newEmail.trim();
    if (!AppUtils.isValidEmail(email)) {
      AppUtils.showError(AppStrings.emailHint);
      return;
    }

    await runAsync(() async {
      isEmailSending.value = true;
      await _sendOtpApi(
        type: AuthOtpType.updateEmail,
        email: email,
      );
      if (!isClosed) isEmailSending.value = false;

      Get.toNamed(AppRoutes.otp, arguments: {
        'from': 'profile',
        'mode': 'verify-new',
        'otpType': AuthOtpType.updateEmail,
        'type': 'email',
        'email': email,
        'phone': email,
      });
    }, showLoadingIndicator: false);
  }

  // ─── OTP Verification ─────────────────────────────────────────────────────

  Future<void> verifyOtp() async {
    if (otpController.text.length < AppConstants.otpLength) {
      AppUtils.showError(AppStrings.enterVerificationCode);
      return;
    }

    await runAsync(() async {
      final isEmail = _argType == 'email';
      final result = await _authRepo.verifyOtp(
        phone: !isEmail ? _argPhone : null,
        countryCode: !isEmail ? _argCountryCode : null,
        countryIso: !isEmail ? otpCountryIso : null,
        email: isEmail ? _argEmail : null,
        otp: otpController.text,
        type: _argOtpType ??
            (isEmail ? AuthOtpType.updateEmail : AuthOtpType.updatePhone),
        channel: isEmail ? AuthChannel.email : AuthChannel.phone,
        userType: UserType.driver,
      );

      if (!result.success) throw Exception(result.message);

      otpFocusNode.unfocus();
      resetOtp();
      resetLoaders();

      if (_argMode == 'verify-existing') {
        // Current contact ownership confirmed — clear any stale new-contact input
        // before navigating to the form where the driver enters their new details.
        newContactController.clear();
        newPhoneLength.value = 0;
        final route = isEmail ? AppRoutes.changeEmail : AppRoutes.changePhone;
        Get.toNamed(route, arguments: {'type': _argType});
      } else {
        // New contact confirmed — mirror the change locally so the edit-profile
        // screen shows the updated value without waiting for another API fetch.
        if (isEmail) {
          emailController.text = _argEmail;
        } else {
          phoneController.text = _argPhone;
        }

        final currentUser = AuthService.to.user;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            email: isEmail ? _argEmail : currentUser.email,
            phone: !isEmail ? _argPhone : currentUser.phone,
            countryCode: !isEmail ? _argCountryCode : currentUser.countryCode,
          );
          AuthService.to.updateUser(updatedUser);
        }

        // Pop both OTP screens and the change-contact screen back to edit-profile.
        Get.until((route) => Get.currentRoute == AppRoutes.editProfile);

        final successMessage = isEmail
            ? AppStrings.emailUpdatedSuccess
            : AppStrings.phoneUpdatedSuccess;
        AppUtils.showSuccess(successMessage);
      }
    });
  }

  // ─── Resend OTP ────────────────────────────────────────────────────────────

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    await runAsync(() async {
      final isEmail = _argType == 'email';
      await _sendOtpApi(
        type: _argOtpType ??
            (isEmail ? AuthOtpType.updateEmail : AuthOtpType.updatePhone),
        phone: !isEmail ? _argPhone : null,
        countryCode: !isEmail ? _argCountryCode : null,
        countryIso: !isEmail ? otpCountryIso : null,
        email: isEmail ? _argEmail : null,
      );
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

  // ─── Profile Actions ───────────────────────────────────────────────────────

  Future<void> refreshProfile() async {
    await runAsync(() async {
      await Future.delayed(const Duration(seconds: 3));

      // final res = await _authRepo.getProfile();
      // if (res.data != null) {
      //   AuthService.to.updateUser(res.data!);
      //   _loadUserData();
      // }
    });
  }

  void _updateCanSave() {
    if (isClosed) return;
    final nameChanged = nameController.text.trim() != _originalName;
    final photoChanged = avatarFile.value != null;
    canSave.value = nameChanged || photoChanged;
  }

  void _lookupByPhoneCode(String? cc) {
    if (cc != null && cc.isNotEmpty) {
      final phoneCode = cc.startsWith('+') ? cc.substring(1) : cc;
      try {
        selectedCountry.value = CountryService()
            .getAll()
            .firstWhere((c) => c.phoneCode == phoneCode);
      } catch (_) {}
    }
  }

  void _loadUserData() {
    if (isClosed) return;
    final u = user;
    if (u != null) {
      _originalName = u.name;
      nameController.text = u.name;
      emailController.text = u.email ?? '';

      // Resolve the country picker from the API-supplied country_iso or country_code field.
      final iso = u.countryIso;
      final cc = u.countryCode;
      
      if (iso != null && iso.isNotEmpty) {
        try {
          selectedCountry.value = CountryService().findByCode(iso)!;
        } catch (_) {
          _lookupByPhoneCode(cc);
        }
      } else {
        _lookupByPhoneCode(cc);
      }

      final rawPhone = u.phone;
      final prefix = '+${selectedCountry.value.phoneCode}';
      if (!isClosed) {

        phoneController.text = rawPhone.startsWith(prefix)
            ? rawPhone.substring(prefix.length)
            : rawPhone;
      }
    }
  }

  void navigateToEditProfile() {
    isPhoneSending.value = false;
    isEmailSending.value = false;
    _loadUserData();
    refreshProfile();
    Get.toNamed(AppRoutes.editProfile);
  }

  void navigateToSettings() => Get.toNamed(AppRoutes.settings);

  void navigateToAccountDetails() => Get.toNamed(AppRoutes.accountDetails);

  void navigateToNotifications() => Get.toNamed(AppRoutes.notifications);

  void navigateToPrivacyPolicy() => Get.toNamed(AppRoutes.privacyPolicy, arguments: {'mode': 'privacy'});

  void navigateToTermsAndConditions() => Get.toNamed(AppRoutes.termsAndConditions, arguments: {'mode': 'terms'});

  void navigateToSupport() => Get.toNamed(AppRoutes.support, arguments: {'mode': 'contact'});

  void navigateToHelpCenter() => Get.toNamed(AppRoutes.support, arguments: {'mode': 'help'});

  void logout() {
    AppConfirmDialog.show(
      isLogout: true,
      onConfirm: () async {
        await _authRepo.logout();
        AuthService.to.logout();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  void deleteAccount() {
    AppConfirmDialog.show(
      isLogout: false,
      onConfirm: () async {
        AppUtils.hideKeyboard();

        // Brief pause lets the keyboard begin its hide animation before
        // the route transition fires, preventing a visual layout jump.
        await Future.delayed(const Duration(milliseconds: 100));

        if (Get.isOverlaysOpen) Get.back();

        AuthService.to.logout();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  Future<void> showDeletionReasonsModal() async {
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut(() => SettingsController(_authRepo));
    }
    Get.find<SettingsController>().showDeletionReasonsModal();
  }

  Future<void> saveEditedProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      AppUtils.showError(AppStrings.enterFullName);
      return;
    }

    isSaving.value = true;
    try {
      final res = await _authRepo.updateProfile(
        name: name,
        profilePhoto: avatarFile.value,
      );

      if (res.success) {
        avatarFile.value = null;
        isSaving.value = false;
        resetLoaders();

        // Prefer the server-returned user model so any backend-normalised fields
        // (e.g. trimmed name, updated avatar URL) are reflected locally.
        try {
          if (res.data != null) {
            final updatedUser = UserModel.fromJson(res.data!);
            AuthService.to.updateUser(updatedUser);
          } else {
            // Fallback: patch just the name when the API returns no data body.
            final currentUser = AuthService.to.user;
            if (currentUser != null) {
              AuthService.to.updateUser(currentUser.copyWith(name: name));
            }
          }
        } catch (e) {
          debugPrint('Error updating local user data: $e');
        }

        // Ensure the dashboard lands on the Profile tab (index 3) after popping.
        try {
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().currentIndex.value = 3;
          }
        } catch (e) {
          debugPrint('DashboardController update error: $e');
        }

        Get.back();

        final msg = res.message.isNotEmpty ? res.message : AppStrings.profileUpdatedSuccess;
        AppUtils.showSuccess(msg);
      } else {
        AppUtils.showError(res.message);
      }
    } catch (e) {
      AppUtils.showError(e.toString());
    } finally {
      if (!isClosed) isSaving.value = false;
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    refreshProfile();
    nameController.addListener(_updateCanSave);
    // React to avatar changes without a listener on a non-Rx field.
    _avatarWorker = ever(avatarFile, (_) => _updateCanSave());
    // Keep form in sync if another screen updates AuthService (e.g. OTP verify).
    _userWorker = ever(AuthService.to.currentUser, (_) => _loadUserData());
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    _avatarWorker?.dispose();
    nameController.removeListener(_updateCanSave);
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
}
