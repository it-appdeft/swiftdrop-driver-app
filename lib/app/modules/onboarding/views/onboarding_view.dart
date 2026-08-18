import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMd,
                vertical: AppDimensions.gapSm,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Obx(
                  () => AnimatedOpacity(
                    opacity: controller.isLastPage ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: controller.skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navyMuted200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingXs,
                          vertical: AppDimensions.gapSm,
                        ),
                      ),
                      child: Text(
                        AppStrings.skip,
                        style: AppTextStyles.pSmallMedium
                            .copyWith(color: AppColors.navyMuted200),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (_, index) =>
                    _OnboardingPage(page: controller.pages[index]),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingLg,
                AppDimensions.sp16,
                AppDimensions.paddingLg,
                AppDimensions.sp32,
              ),
              child: Column(
                children: [
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.pages.length,
                        (i) => _Dot(
                          isActive: i == controller.currentPage.value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sp24),
                  Obx(
                    () => AppButton(
                      label: controller.isLastPage
                          ? AppStrings.getStarted
                          : AppStrings.continueText,
                      onPressed: controller.nextPage,
                      suffixIcon: Icon(
                        controller.isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPage page;
  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(page.icon, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.sp40),

          Text(
            page.title,
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.gapSm),
          Text(
            page.subtitle,
            style: AppTextStyles.pMediumSemiBold.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sp16),
          Text(
            page.description,
            style: AppTextStyles.pSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.gapXs),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.darkBorder,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}
