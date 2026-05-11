import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.arguments as UserModel?;
    final nameFocus    = FocusNode();
    final emailFocus   = FocusNode();
    final vehicleFocus = FocusNode();
    final plateHocus   = FocusNode();

    final nameCtrl    = TextEditingController(text: user?.name);
    final emailCtrl   = TextEditingController(text: user?.email);
    final vehicleCtrl = TextEditingController(text: user?.vehicleType);
    final plateCtrl   = TextEditingController(text: user?.vehicleNumber);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: AppDimensions.avatarLg / 2,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : 'D',
                      style: AppTextStyles.h3Bold
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: AppDimensions.sp32,
                      height: AppDimensions.sp32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.darkBackground, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: AppColors.white, size: AppDimensions.iconXs),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXl),

            // Personal info section
            _SectionLabel('Personal Information'),
            const SizedBox(height: AppDimensions.gapMd),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: AppDecorations.cardDark,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: nameCtrl,
                    focusNode: nameFocus,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.navyMuted300),
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(emailFocus),
                  ),
                  const SizedBox(height: AppDimensions.gapMd),
                  AppTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    controller: emailCtrl,
                    focusNode: emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.navyMuted300),
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(vehicleFocus),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.gapLg),

            // Vehicle info section
            _SectionLabel('Vehicle Information'),
            const SizedBox(height: AppDimensions.gapMd),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: AppDecorations.cardDark,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Vehicle Type',
                    hint: 'e.g. Bike, Scooter, Car',
                    controller: vehicleCtrl,
                    focusNode: vehicleFocus,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.two_wheeler_rounded,
                        color: AppColors.navyMuted300),
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(plateHocus),
                  ),
                  const SizedBox(height: AppDimensions.gapMd),
                  AppTextField(
                    label: 'Vehicle Number',
                    hint: 'e.g. MH12AB1234',
                    controller: plateCtrl,
                    focusNode: plateHocus,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.pin_rounded,
                        color: AppColors.navyMuted300),
                    onSubmitted: (_) =>
                        FocusScope.of(context).unfocus(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.sp32),

            // Save button
            Obx(
              () => AppButton(
                label: 'Save Changes',
                isLoading: controller.isLoading.value,
                onPressed: () => controller.saveEditedProfile(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty
                      ? null
                      : emailCtrl.text.trim(),
                  vehicleType: vehicleCtrl.text.trim().isEmpty
                      ? null
                      : vehicleCtrl.text.trim(),
                  vehicleNumber: plateCtrl.text.trim().isEmpty
                      ? null
                      : plateCtrl.text.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.sectionTitle);
  }
}
