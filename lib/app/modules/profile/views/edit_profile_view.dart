import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/app_loader.dart';
import '../controllers/profile_controller.dart';
import '../../../../generated/assets.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_picker_utils.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(
        title: AppStrings.editProfile,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: ShimmerEditProfile(),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildAvatar(),
              const SizedBox(height: 32),

              // ─── Full Name ───────────────────────────────────────────────────
              _buildLabel(AppStrings.fullName),
              const SizedBox(height: 8),
              AppTextField(
                controller: controller.nameController,
                hint: AppStrings.alexandarArnold,
                fillColor: AppColors.white,
                textColor: Colors.black,
                textCapitalization: TextCapitalization.words,
                hintStyle: AppTextStyles.build(
                  size: 14,
                  weight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // ─── Mobile Number ───────────────────────────────────────────────
              _buildLabel(AppStrings.mobileNumber),
              const SizedBox(height: 8),
              _buildPhoneField(),
              const SizedBox(height: 16),

              // ─── Email Address ───────────────────────────────────────────────
              _buildLabel(AppStrings.emailAddress),
              const SizedBox(height: 8),
              _buildEmailField(),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
        child: Obx(
          () => AppButton(
            label: AppStrings.update,
            isLoading: controller.isSaving.value,
            onPressed: controller.canSave.value
                ? controller.saveEditedProfile
                : null,
          ),
        ),
      ),
    );
  }

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
            Obx(() {
              final user = AuthService.to.user;
              final file = controller.avatarFile.value;
              return Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: file != null
                    ? ClipOval(
                        child: Image.file(
                          file,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    : (user?.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              user!.avatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 44,
                            color: Color(0xFF9CA3AF),
                          )),
              );
            }),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Assets.images.solarCameraBroken3x.image(
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Obx(() => PhoneTextField(
          label: null,
          controller: controller.phoneController,
          readOnly: true,
          fillColor: AppColors.white,
          textColor: Colors.black,
          countryCode: controller.dialCode,
          flagEmoji: controller.dialCode == '+44' ? '🇬🇧' : controller.flagEmoji,
          isoCode: controller.dialCode == '+44' ? 'GB' : controller.isoCode,
          onCountryTap: null,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionText(
                  AppStrings.change,
                  controller.startPhoneChange,
                  isLoading: controller.isPhoneSending.value,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildEmailField() {
    return Obx(() => AppTextField(
          label: null,
          controller: controller.emailController,
          readOnly: true,
          hint: AppStrings.emailHint,
          fillColor: AppColors.white,
          textColor: Colors.black,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionText(
                  AppStrings.change,
                  controller.startEmailChange,
                  isLoading: controller.isEmailSending.value,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildActionText(
    String text,
    VoidCallback onTap, {
    bool enabled = true,
    bool isLoading = false,
  }) {
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
                  color: enabled
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (isLoading) AppLoader.small(),
          ],
        ),
      ),
    );
  }
}
