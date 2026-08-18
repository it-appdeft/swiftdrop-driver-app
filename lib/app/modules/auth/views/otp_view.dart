import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/otp_input.dart';
import '../controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  dynamic get controller {
    final from = Get.arguments is Map ? Get.arguments['from'] : null;
    if (from == 'profile') return Get.find<ProfileController>();
    if (from == 'settings') return Get.find<SettingsController>();
    return Get.find<AuthController>();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final ctrl = controller;
    final isVerifyExisting = Get.arguments?['mode'] == 'verify-existing';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        title: isVerifyExisting
            ? AppStrings.verifyExistingAccount
            : AppStrings.otpVerification,
        onBack: () {
          ctrl.resetOtp();
          Get.back();
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      _buildSubtitle(ctrl),

                      const SizedBox(height: 18),

                      _buildOtpBoxes(ctrl),

                      const SizedBox(height: 16),

                      _buildResendButton(ctrl),

                      const Spacer(),

                      _buildVerifyButton(ctrl),
                      SizedBox(height: 24 + bottomPad),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubtitle(dynamic ctrl) {
    final mode = Get.arguments?['mode'];
    final type = Get.arguments?['type'];

    if (mode == 'verify-existing') {
      String value;
      if (type == 'phone') {
        final phone = Get.arguments?['phone'] ?? '';
        final cc = Get.arguments?['countryCode'] ?? '';
        value = cc.isNotEmpty ? '$cc-$phone' : phone;
      } else {
        value = Get.arguments?['email'] ?? Get.arguments?['phone'] ?? '';
      }
      return Text(
        'For Security, please verify your existing account information. OTP sent to $value',
        style: AppTextStyles.pMedium.copyWith(color: AppColors.otpSubtitle),
        textAlign: TextAlign.center,
      );
    }

    if (mode == 'delete-account') {
      final phone = Get.arguments?['phone'] as String? ?? '';
      final cc = Get.arguments?['countryCode'] as String? ?? '';
      final display = cc.isNotEmpty ? '$cc-$phone' : phone;
      return Text(
        '${AppStrings.otpSentTo}$display',
        style: AppTextStyles.pMedium.copyWith(color: AppColors.otpSubtitle),
        textAlign: TextAlign.center,
      );
    }

    if (mode == 'verify-new') {
      String value;
      if (type == 'phone') {
        final phone = Get.arguments?['phone'] ?? '';
        final cc = Get.arguments?['countryCode'] ?? '';
        value = cc.isNotEmpty ? '$cc-$phone' : phone;
      } else {
        value = Get.arguments?['email'] ?? Get.arguments?['phone'] ?? '';
      }
      return Text(
        'We have sent a verification code to $value',
        style: AppTextStyles.pMedium.copyWith(color: AppColors.otpSubtitle),
        textAlign: TextAlign.center,
      );
    }

    if (type == 'email') {
      final email = Get.arguments?['email'] ?? ctrl.phone;
      return Text(
        '${AppStrings.otpSentTo}$email',
        style: AppTextStyles.pMedium.copyWith(color: AppColors.otpSubtitle),
        textAlign: TextAlign.center,
      );
    }

    final cc = ctrl.otpCountryCode;
    final ccDigits = cc.replaceAll(RegExp(r'\D'), '');
    final digits = ctrl.phone.replaceAll(RegExp(r'\D'), '');

    String local = digits;
    if (digits.startsWith('0')) {
      local = digits.substring(1);
    } else if (ccDigits.isNotEmpty && digits.startsWith(ccDigits)) {
      local = digits.substring(ccDigits.length);
    }

    final formatted = local.length >= 10
        ? '${local.substring(0, 4)} ${local.substring(4)}'
        : local;

    final display = formatted.isEmpty ? cc : '$cc-$formatted';

    return Text(
      '${AppStrings.otpSentTo}$display',
      style: AppTextStyles.pMedium.copyWith(color: AppColors.otpSubtitle),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOtpBoxes(dynamic ctrl) {
    return OtpInput(
      controller: ctrl.otpController,
      focusNode: ctrl.otpFocusNode,
      length: AppConstants.otpLength,
      onChanged: ctrl.onOtpChanged,
      alignment: MainAxisAlignment.center,
      autofocus: true,
    );
  }

  Widget _buildResendButton(dynamic ctrl) {
    return Obx(() {
      final t = ctrl.resendTimer.value;
      final active = t == 0;
      final baseStyle = AppTextStyles.pSmallMedium;

      if (active) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            ctrl.resendOtp();
          },
          child: Text(
            AppStrings.resendOtp,
            style: baseStyle.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        );
      }

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: '${AppStrings.resendOtp} ',
              style: baseStyle.copyWith(color: AppColors.otpResendInactive),
            ),
            TextSpan(
              text: '($t)',
              style: baseStyle.copyWith(color: AppColors.phoneTitleColor),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVerifyButton(dynamic ctrl) {
    final isVerifyExisting = Get.arguments?['mode'] == 'verify-existing';
    return Obx(
      () => AppButton(
        label:  AppStrings.verifyButton,
        isLoading: ctrl.isLoading.value,
        onPressed: (!ctrl.isOtpComplete.value || ctrl.isLoading.value)
            ? null
            : ctrl.verifyOtp,
      ),
    );
  }
}
