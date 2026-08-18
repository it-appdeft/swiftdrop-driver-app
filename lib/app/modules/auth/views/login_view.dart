import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_picker_utils.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    const double footerReservedHeight = 72;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.65,
                child: Image.asset(
                  'assets/images/login_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: footerReservedHeight + bottomPad,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.52),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: Responsive.w(AppDimensions.sp16)),
                        padding: EdgeInsets.only(
                          top: Responsive.h(AppDimensions.sp20),
                          left: Responsive.w(AppDimensions.sp16),
                          right: Responsive.w(AppDimensions.sp16),
                          bottom: Responsive.h(AppDimensions.sp24),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: AppDimensions.shadowCardBlur,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeHeader(),
                            SizedBox(height: Responsive.h(24)),
                            _buildPhoneInput(),
                            SizedBox(height: Responsive.h(20)),
                            _buildOtpButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(
                top: 12,
                bottom: bottomPad + 16,
              ),
              child: _buildFooter(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Widget Functions ─────────────────────────────────────────────────────

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.build(
              size: 30,
              weight: FontWeight.w700,
              fontFamily: 'Helvetica Neue',
              color: const Color(0xFF1A1A2E),
            ),
            children: [
              TextSpan(
                text: AppStrings.welcome,
                style: AppTextStyles.build(
                  size: 30,
                  weight: FontWeight.w700,
                  fontFamily: 'Helvetica Neue',
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(text: AppStrings.back),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(20)),
        Divider(color: Colors.grey[100], thickness: 1.5),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Obx(
      () => PhoneTextField(
        controller: controller.phoneController,
        textColor: AppColors.black,
        labelColor: AppColors.phoneTitleColor,
        fillColor: AppColors.textOnPrimary,
        isRequired: true,
        enabled: !controller.isLoading.value,

        countryCode: controller.dialCode,
        flagEmoji: controller.dialCode == '+44' ? '🇬🇧' : controller.flagEmoji,
        isoCode: controller.dialCode == '+44' ? 'GB' : controller.isoCode,

        autovalidateMode: controller.showValidation.value
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,

        validator: controller.validatePhone,
        onChanged: controller.onPhoneChanged,

        onCountryTap: controller.isLoading.value ? null : _openCountryPicker,

        labelFontWeight: FontWeight.w500,
        countryCodeFontWeight: FontWeight.w400,
      ),
    );
  }

  void _openCountryPicker() {
    AppPickerUtils.openCountryPicker(onSelect: controller.onCountrySelected);
  }

  Widget _buildOtpButton() {
    return Obx(() {
      final len = controller.phoneLength.value;
      final enabled = !controller.isLoading.value && len >= 8 && len <= 12;
      return AppButton(
        label: AppStrings.getOtp,
        onPressed: enabled ? controller.sendOtp : null,
        isLoading: controller.isLoading.value,
        backgroundColor: enabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.5),
      );
    });
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.pSmallRegular.copyWith(
            color: AppColors.otpTitle,
          ),
          children: [
            const TextSpan(text: AppStrings.dontHaveAccount),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.toNamed(AppRoutes.register);
                },
                child: Text(
                  AppStrings.register,
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
