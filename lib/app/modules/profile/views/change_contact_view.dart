import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_picker_utils.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

class ChangeContactView extends GetView<ProfileController> {
  const ChangeContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final type = Get.arguments?['type'] ?? 'phone'; // 'phone' or 'email'
    final isPhone = type == 'phone';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(
        title: '',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
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
                  TextSpan(text: isPhone ? 'Change Phone ' : 'Add Your New '),
                  TextSpan(
                    text: isPhone ? 'Number' : 'Email',
                    style: AppTextStyles.build(
                      size: 32,
                      weight: FontWeight.w700,
                      fontFamily: 'Helvetica Neue',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isPhone
                  ? 'Enter your new Mobile number to receive a verification code'
                  : 'Enter your new email address to receive a verification code',
              style: AppTextStyles.pMedium.copyWith(
                color: AppColors.otpSubtitle,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPhone ? AppStrings.mobileNumber : AppStrings.emailAddress,
              style: AppTextStyles.build(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.phoneTitleColor,
              ),
            ),
            const SizedBox(height: 8),
            if (isPhone)
              Obx(() => PhoneTextField(
                    label: null,
                    controller: controller.newContactController,
                    fillColor: AppColors.white,
                    textColor: AppColors.navy900,
                    countryCode: controller.dialCode,
                    flagEmoji: controller.dialCode == '+44' ? '🇬🇧' : controller.flagEmoji,
                    isoCode: controller.dialCode == '+44' ? 'GB' : controller.isoCode,
                    onCountryTap: () => _openCountryPicker(controller),
                    onChanged: controller.onNewPhoneChanged,
                  ))
            else
              AppTextField(
                label: null,
                controller: controller.newContactController,
                hint: AppStrings.emailHint,
                fillColor: AppColors.white,
                textColor: AppColors.navy900,
                keyboardType: TextInputType.emailAddress,
                hintStyle: AppTextStyles.build(
                  size: 14,
                  weight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
              ),
            const Spacer(),
            Obx(() {
                  final isLoading = isPhone
                      ? controller.isPhoneSending.value
                      : controller.isEmailSending.value;
                  final len = controller.newPhoneLength.value;
                  final enabled = isPhone
                      ? (!isLoading && len >= 8 && len <= 12)
                      : !isLoading;
                  return AppButton(
                    label: AppStrings.getOtp,
                    isLoading: isLoading,
                    onPressed: enabled
                        ? () {
                            if (isPhone) {
                              controller.sendOtpToNewPhone(
                                  controller.newContactController.text);
                            } else {
                              controller.sendOtpToNewEmail(
                                  controller.newContactController.text);
                            }
                          }
                        : null,
                  );
                }),
            SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _openCountryPicker(ProfileController controller) {
    AppPickerUtils.openCountryPicker(onSelect: controller.onCountrySelected);
  }
}
