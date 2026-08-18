import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMd,
                AppDimensions.gapSm,
                AppDimensions.paddingMd,
                0,
              ),
              child: Text(
                AppStrings.profile,
                style: AppTextStyles.h4.copyWith(color: AppColors.navy900),
              ),
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.paddingMd,
                      0,
                      AppDimensions.paddingMd,
                      AppDimensions.paddingMd,
                    ),
                    child: ShimmerProfilePage(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.refreshProfile,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingMd,
                      0,
                      AppDimensions.paddingMd,
                      AppDimensions.paddingMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(controller.user, controller.navigateToEditProfile),
                        const SizedBox(height: AppDimensions.gapXl),
                        _buildQuickActions(),
                        const SizedBox(height: AppDimensions.gapXl),
                        _buildMenuList(),
                        //const SizedBox(height: AppDimensions.gapXl),
                        AppButton(
                          label: AppStrings.logout,
                          backgroundColor: AppColors.logoutBg,
                          textColor: AppColors.primary,
                          prefixIcon: Assets.images.logout.image(
                            width: AppDimensions.iconMd,
                            height: AppDimensions.iconMd,
                            color: AppColors.primary,
                          ),
                          onPressed: controller.logout,
                        ),
                        const SizedBox(height: AppDimensions.gapMd),
                        AppButton(
                          label: AppStrings.deleteAccount,
                          backgroundColor: AppColors.errorLight,
                          textColor: AppColors.deleteRed,
                          prefixIcon: Assets.images.deleteaccount.image(
                            width: AppDimensions.iconSm,
                            height: AppDimensions.iconSm,
                            color: AppColors.deleteRed,
                          ),
                          onPressed: controller.showDeletionReasonsModal,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserModel? user, VoidCallback onEdit) {
    final String name  = user?.name ?? 'User';
    final String phone = '${user?.countryCode ?? ''}-${user?.phone ?? ''}';

    final String email = user?.email ?? '';
    final String? avatar = user?.avatar;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoBoxBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight500.withValues(alpha: 0.3),
                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || avatar.isEmpty)
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                        ),
                        style: AppTextStyles.build(
                          size: 20,
                          weight: FontWeight.w500,
                          fontFamily: 'Helvetica Neue',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: AppTextStyles.pSmall.copyWith(
                          color: AppColors.profileBodyText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTextStyles.pSmall.copyWith(
                          color: AppColors.profileBodyText,
                          fontWeight: FontWeight.w400,
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
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onEdit,
            child: Assets.images.editProfile.image(
              height: 40,
              width: 40,
              color: AppColors.navy900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            Assets.images.contactSupport,
            AppStrings.contactSupportProfile,
            controller.navigateToSupport,
          ),
        ),
        const SizedBox(width: AppDimensions.gapLg),
        Expanded(
          child: _buildQuickActionCard(
            Assets.images.helpCenter,
            AppStrings.helpCenterProfile,
            controller.navigateToHelpCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    AssetGenImage assetImage,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.infoBoxBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetImage.image(width: 24, height: 24, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.navy900,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final items = [
      (Assets.images.accountDetails,  AppStrings.accountDetails,    controller.navigateToAccountDetails),
      (Assets.images.accountSettings, AppStrings.accountSettings,   controller.navigateToSettings),
      (Assets.images.privacypolicy,   AppStrings.privacyPolicy,     controller.navigateToPrivacyPolicy),
      (Assets.images.termsConditions, AppStrings.termsAndConditions, controller.navigateToTermsAndConditions),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.lightBorder,
      ),
      itemBuilder: (_, i) => _buildMenuItem(items[i].$1, items[i].$2, items[i].$3 as VoidCallback?),
    );
  }

  Widget _buildMenuItem(AssetGenImage assetImage, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            assetImage.image(width: 40, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.pSmall.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.navy900,
                ),
              ),
            ),
            Assets.images.rightArrow.image(width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
