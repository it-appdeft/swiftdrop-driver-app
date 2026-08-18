import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/deletion_reason_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_confirm_dialog.dart';

class SettingsController extends BaseController {
  final AuthRepository _authRepo;
  SettingsController(this._authRepo);

  final _storage = StorageService.to;

  final orderNotifications   = true.obs;
  final paymentNotifications = true.obs;
  final locationTracking     = true.obs;
  final deliveryUpdates      = true.obs;
  final notifications        = true.obs;

  // ─── Deletion Reasons State ────────────────────────────────────────────────
  final deletionReasons = <DeletionReasonModel>[].obs;
  final selectedReason = Rxn<DeletionReasonModel>();
  final otherReasonText = ''.obs;

  // ─── OTP State (delete-account flow) ──────────────────────────────────────
  final otpController  = TextEditingController();
  final otpFocusNode   = FocusNode();
  final resendTimer    = 0.obs;
  final isOtpComplete  = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  @override
  void onClose() {
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }

  // ─── Prefs ─────────────────────────────────────────────────────────────────

  void _loadPrefs() {
    orderNotifications.value   = _storage.read<bool>('pref_order_notif')      ?? true;
    paymentNotifications.value = _storage.read<bool>('pref_payment_notif')    ?? true;
    locationTracking.value     = _storage.read<bool>('pref_location')         ?? true;
    deliveryUpdates.value      = _storage.read<bool>('pref_delivery_updates') ?? true;
    notifications.value        = _storage.read<bool>('pref_notifications')    ?? true;
  }

  void setOrderNotifications(bool val) {
    orderNotifications.value = val;
    _storage.write('pref_order_notif', val);
  }

  void setPaymentNotifications(bool val) {
    paymentNotifications.value = val;
    _storage.write('pref_payment_notif', val);
  }

  void setLocationTracking(bool val) {
    locationTracking.value = val;
    _storage.write('pref_location', val);
  }

  void setDeliveryUpdates(bool val) {
    deliveryUpdates.value = val;
    _storage.write('pref_delivery_updates', val);
  }

  void setNotifications(bool val) {
    notifications.value = val;
    _storage.write('pref_notifications', val);
  }

  // ─── Delete Account Flow with Reasons ─────────────────────────────────────

  Future<void> showDeletionReasonsModal() async {
    await runAsync(() async {
      try {
        final res = await _authRepo.getDeletionReasons();
        if (res.success && res.data != null && res.data!.isNotEmpty) {
          deletionReasons.value = res.data!;
          selectedReason.value = res.data!.first;
        }
      } catch (_) {}
    });

    if (deletionReasons.isEmpty) {
      // Fallback default reasons if offline or API error
      deletionReasons.value = [
        DeletionReasonModel(id: 1, label: "I don't want to use Swiftdrop anymore", slug: 'not_using_anymore', isOther: false, sortOrder: 1),
        DeletionReasonModel(id: 2, label: "I'm using a different account", slug: 'different_account', isOther: false, sortOrder: 2),
        DeletionReasonModel(id: 3, label: "I'm worried about my privacy", slug: 'privacy_concern', isOther: false, sortOrder: 3),
        DeletionReasonModel(id: 4, label: "You're sending me too many notifications", slug: 'too_many_notifications', isOther: false, sortOrder: 4),
        DeletionReasonModel(id: 5, label: "The app is not working properly", slug: 'app_not_working', isOther: false, sortOrder: 5),
        DeletionReasonModel(id: 6, label: "Other", slug: 'other', isOther: true, sortOrder: 6),
      ];
      selectedReason.value = deletionReasons.first;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),
              Text(
                'Reason for Deleting Account',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please select a reason why you are leaving Swiftdrop.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),
              Obx(
                () => Column(
                  children: deletionReasons.map((reason) {
                    final isSelected = selectedReason.value?.id == reason.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppDimensions.gapSm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.infoBoxBg,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.stroke,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        child: RadioListTile<int>(
                          value: reason.id,
                          groupValue: selectedReason.value?.id,
                          onChanged: (_) {
                            selectedReason.value = reason;
                          },
                          title: Text(
                            reason.label,
                            style: AppTextStyles.pSmallMedium.copyWith(
                              color: AppColors.navy900,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Obx(() {
                if (selectedReason.value?.isOther == true) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.gapSm),
                    child: TextField(
                      onChanged: (val) => otherReasonText.value = val,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tell us more (optional)',
                        filled: true,
                        fillColor: AppColors.infoBoxBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          borderSide: const BorderSide(color: AppColors.stroke),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: AppDimensions.gapLg),
              AppButton(
                label: 'Continue Account Deletion',
                backgroundColor: AppColors.deleteRed,
                onPressed: () {
                  Get.back();
                  deleteAccount();
                },
              ),
              const SizedBox(height: AppDimensions.gapSm),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void deleteAccount() {
    AppConfirmDialog.show(
      isLogout: false,
      onConfirmAsync: _initiateDeleteAccount,
    );
  }

  Future<void> _initiateDeleteAccount() async {
    try {
      final result = await _authRepo.deleteAccountInitiate();
      if (!result.success) {
        AppUtils.showError(result.message);
        return;
      }
      _startResendTimer();
      final testCode = (result.data?['test_code'] as String?) ?? '';
      Get.back(); // close confirm dialog
      AppUtils.showSuccess(
        AppStrings.otpSentSuccess.replaceFirst('%s', testCode),
      );
      final user = AuthService.to.user;
      Get.toNamed(AppRoutes.otp, arguments: {
        'from': 'settings',
        'mode': 'delete-account',
        'phone': user?.phone ?? '',
        'countryCode': user?.countryCode ?? '+44',
      });
    } catch (e) {
      AppUtils.showError(e.toString());
    }
  }

  // ─── OTP Methods (used by OtpView) ────────────────────────────────────────

  void onOtpChanged(String value) {
    isOtpComplete.value = value.length == AppConstants.otpLength;
  }

  String get phone => Get.arguments?['phone'] ?? '';
  String get otpCountryCode => Get.arguments?['countryCode'] ?? '+44';

  void resetOtp() {
    otpController.clear();
    isOtpComplete.value = false;
    resendTimer.value = 0;
  }

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;
    try {
      final result = await _authRepo.deleteAccountInitiate();
      if (!result.success) {
        AppUtils.showError(result.message);
        return;
      }
      _startResendTimer();
      AppUtils.showSuccess(AppConstants.otpResent);
    } catch (e) {
      AppUtils.showError(e.toString());
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < AppConstants.otpLength) {
      AppUtils.showError(AppStrings.enterVerificationCode);
      return;
    }
    await runAsync(() async {
      final result = await _authRepo.deleteAccount(otpController.text);
      if (!result.success) throw Exception(result.message);
      
      AppUtils.hideKeyboard();
      otpFocusNode.unfocus();
      resetOtp();

      await Future.delayed(const Duration(milliseconds: 100));

      AuthService.to.logout();
      Get.offAllNamed(
        AppRoutes.verificationPending,
        arguments: {'mode': 'delete_success'},
      );
    });
  }

  void _startResendTimer() {
    resendTimer.value = AppConstants.otpResendTimer;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed || resendTimer.value <= 0) return false;
      resendTimer.value--;
      return resendTimer.value > 0;
    });
  }

  // ─── Other Settings & Legal ───────────────────────────────────────────────

  void clearCache() => AppUtils.showSuccess(AppConstants.cacheCleared);

  void openSupport() => AppUtils.showInfo('Support feature coming soon');

  void openPrivacyPolicy() => Get.toNamed(AppRoutes.privacyPolicy, arguments: {'mode': 'privacy'});

  void openTermsAndConditions() => Get.toNamed(AppRoutes.termsAndConditions, arguments: {'mode': 'terms'});

  String get appVersion => '1.0.0';
}
