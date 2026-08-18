import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_picker_utils.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/otp_input.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(title: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 24),
            _buildAvatar(),
            const SizedBox(height: 16),

            // ─── Full Name ───────────────────────────────────────────────────
            _buildLabel(AppStrings.fullName),
            const SizedBox(height: 8),
            Obx(() => AppTextField(
              controller: controller.nameController,
              hint: AppStrings.alexandarArnold,
              fillColor: Colors.white,
              textColor: Colors.black,
              enabled: !controller.isLoading.value,
              textCapitalization: TextCapitalization.words,
              hintStyle: AppTextStyles.build(
                size: 14,
                weight: FontWeight.w400,
                color: AppColors.textHint,
              ),
            )),
            const SizedBox(height: 16),

            // ─── Email Address ───────────────────────────────────────────────
            _buildLabel(AppStrings.emailAddress),
            const SizedBox(height: 8),
            _buildEmailField(),

            Obx(() => controller.showEmailOtp.value && !controller.emailVerified.value
                ? _buildOtpSection(
                    label: AppStrings.emailOtpSentDesc,
                    otpController: controller.emailOtpController,
                    otpFocusNode: controller.emailOtpFocusNode,
                    onChanged: controller.onEmailOtpChanged,
                    onVerify: controller.verifyEmailOtp,
                    resendTimer: controller.emailResendTimer,
                    isLoading: controller.isEmailVerifying.value,
                    isOtpComplete: controller.isEmailOtpComplete,
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 16),

            // ─── Mobile Number ───────────────────────────────────────────────
            _buildLabel(AppStrings.mobileNumber),
            const SizedBox(height: 8),
            _buildPhoneField(),

            Obx(() => controller.showPhoneOtp.value && !controller.phoneVerified.value
                ? _buildOtpSection(
                    label: AppStrings.phoneOtpSentDesc,
                    otpController: controller.phoneOtpController,
                    otpFocusNode: controller.phoneOtpFocusNode,
                    onChanged: controller.onPhoneOtpChanged,
                    onVerify: controller.verifyPhoneOtp,
                    resendTimer: controller.phoneResendTimer,
                    isLoading: controller.isPhoneVerifying.value,
                    isOtpComplete: controller.isPhoneOtpComplete,
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 24),

            // ─── Register Button ─────────────────────────────────────────────
            Obx(() {
              final enabled = controller.emailVerified.value && controller.phoneVerified.value;
              return AppButton(
                label: AppStrings.register,
                isLoading: controller.isLoading.value,
                onPressed: enabled ? controller.register : null,
                backgroundColor: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
              );
            }),
            const SizedBox(height: 24),

            // ─── Login Link ──────────────────────────────────────────────────
            _buildLoginLink(),
            SizedBox(height: bottomPad + 24),
          ],
        ),
      ),
    );
  }

  // ─── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.build(
              size: 32,
              weight: FontWeight.w700,
              fontFamily: 'Helvetica Neue',
              color: const Color(0xFF1A1A2E),
            ),
            children: [
              TextSpan(
                text: AppStrings.become,
                style: AppTextStyles.build(
                  size: 32,
                  weight: FontWeight.w700,
                  fontFamily: 'Helvetica Neue',
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(text: AppStrings.aDeliveryPartner),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Avatar ─────────────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          AppPickerUtils.showPicker(
            onFilePicked: (file) => controller.avatarFile.value = file,
          );
        },
        child: Stack(
          children: [
            Obx(
                  () => Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: controller.avatarFile.value != null
                    ? ClipOval(
                  child: Image.file(
                    controller.avatarFile.value!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 34,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Assets.images.solarCameraBroken3x.image(
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Label ──────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.build(
          size: 14,
          weight: FontWeight.w500,
          color: AppColors.phoneTitleColor,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  // ─── Email Field ────────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return Obx(() {
      final isVerified = controller.emailVerified.value;
      final isSent = controller.showEmailOtp.value;
      final isLoading = controller.isLoading.value;
      final isSending = controller.isEmailSending.value;

      return AppTextField(
        controller: controller.emailController,
        hint: AppStrings.emailHint,
        fillColor: Colors.white,
        textColor: Colors.black,
        readOnly: isVerified,
        enabled: !isLoading,
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        suffixIcon: SizedBox(
          width: isSent && !isVerified ? 132 : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isVerified)
                  _buildVerifiedBadge()
                else if (isSent)
                  _buildResendText(
                    controller.emailResendTimer,
                    controller.sendEmailOtp,
                    isLoading: isSending,
                  )
                else
                  _buildActionText(
                    AppStrings.getOtp,
                    controller.sendEmailOtp,
                    enabled: controller.isEmailValid.value && !isLoading && !isSending,
                    isLoading: isSending,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── Phone Field ────────────────────────────────────────────────────────────

  Widget _buildPhoneField() {
    return Obx(() {
      final isVerified = controller.phoneVerified.value;
      final isSent = controller.showPhoneOtp.value;
      final isLoading = controller.isLoading.value;
      final isSending = controller.isPhoneSending.value;

      return PhoneTextField(
        label: null,
        controller: controller.phoneController,
        fillColor: Colors.white,
        textColor: Colors.black,
        countryCode: controller.dialCode,
        flagEmoji: controller.dialCode == '+44' ? '🇬🇧' : controller.flagEmoji,
        isoCode: controller.dialCode == '+44' ? 'GB' : controller.isoCode,
        enabled: !isLoading,
        onCountryTap: (isVerified || isLoading) ? null : _openCountryPicker,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVerified)
                _buildVerifiedBadge()
              else if (isSent)
                _buildResendText(
                  controller.phoneResendTimer,
                  controller.sendPhoneOtp,
                  isLoading: isSending,
                )
              else
                _buildActionText(
                  AppStrings.getOtp,
                  controller.sendPhoneOtp,
                  enabled: controller.phoneLength.value >= 8 && controller.phoneLength.value <= 12 && !isLoading && !isSending,
                  isLoading: isSending,
                ),
            ],
          ),
        ),
      );
    });
  }

  void _openCountryPicker() {
    AppPickerUtils.openCountryPicker(onSelect: controller.onCountrySelected);
  }

  // ─── OTP Section ────────────────────────────────────────────────────────────

  Widget _buildOtpSection({
    required String label,
    required TextEditingController otpController,
    required FocusNode otpFocusNode,
    required ValueChanged<String> onChanged,
    required VoidCallback onVerify,
    required RxInt resendTimer,
    required RxBool isOtpComplete,
    bool isLoading = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.enterVerificationCode,
            style: AppTextStyles.build(
              size: 16,
              weight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.build(
              size: 13,
              weight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ).copyWith(height: 1.3),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              OtpInput(
                controller: otpController,
                focusNode: otpFocusNode,
                length: 4,
                onChanged: onChanged,
                alignment: MainAxisAlignment.start,
                boxSize: 44, // Reduced from 46 to save space
                showDashes: true,
                autofocus: true,
              ),
              const Spacer(), // Use Spacer instead of fixed 30px gap to handle different screen widths
              Obx(() {
                final enabled = isOtpComplete.value && !isLoading;
                return GestureDetector(
                  onTap: enabled ? onVerify : null,
                  child: Container(
                    height: 46, // Matches OTP box height
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: isLoading ? 0 : 1,
                          child: Text(
                            AppStrings.verify.toUpperCase(),
                            style: AppTextStyles.build(
                              size: 13,
                              weight: FontWeight.w700,
                              color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        if (isLoading) AppLoader.small(),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildVerifiedBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.verified,
          style: AppTextStyles.build(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.primaryDarkest,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.check_circle,
          color: AppColors.primaryDarkest,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildActionText(String text, VoidCallback onTap, {bool enabled = true, bool isLoading = false}) {
    return GestureDetector(
      onTap: (enabled && !isLoading)
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isLoading ? 0 : 1,
              child: Text(
                text,
                style: AppTextStyles.build(
                  size: 12,
                  weight: FontWeight.w600,
                  color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (isLoading) AppLoader.small(),
          ],
        ),
      ),
    );
  }

  Widget _buildResendText(RxInt timer, VoidCallback onResend, {bool isLoading = false}) {
    return Obx(() {
      return Container(
        height: 32,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isLoading ? 0 : 1,
              child: _buildResendContent(timer, onResend),
            ),
            if (isLoading) AppLoader.small(),
          ],
        ),
      );
    });
  }

  Widget _buildResendContent(RxInt timer, VoidCallback onResend) {
    final t = timer.value;
    if (t > 0) {
      return RichText(
        text: TextSpan(
          style: AppTextStyles.build(size: 12, weight: FontWeight.w500),
          children: [
            const TextSpan(
              text: '${AppStrings.resendOtp} ',
              style: TextStyle(color: AppColors.otpResendInactive),
            ),
            TextSpan(
              text: '($t)',
              style: const TextStyle(color: AppColors.phoneTitleColor),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onResend();
      },
      child: Text(
        AppStrings.resendOtp,
        style: AppTextStyles.build(
          size: 12,
          weight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.pSmallRegular.copyWith(
            color: AppColors.otpTitle,
          ),
          children: [
            const TextSpan(text: AppStrings.alreadyHaveAccount),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.toNamed(AppRoutes.login);
                },
                child: Text(
                  AppStrings.login,
                  style: AppTextStyles.pSmallMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
