import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';

class VerificationPendingView extends StatelessWidget {
  const VerificationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Get.arguments?['mode'];
    final isDeleteSuccess = mode == 'delete_success';
    final isReviewUpdates = mode == 'review_updates';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isReviewUpdates 
          ? AppAppBar(
              title: '',
              onBack: () => Get.back(),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: isDeleteSuccess
                  ? const Icon(
                      Icons.check_rounded,
                      size: 74,
                      color: AppColors.primary,
                    )
                  : Assets.images.verificationPending.image(
                      width: 74,
                      height: 74,
                    ),
            ),
            const SizedBox(height: 16),

            if (isDeleteSuccess) ...[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.build(
                    size: 32,
                    height: 40,
                    weight: FontWeight.w500,
                    fontFamily: 'Helvetica Neue',
                  ),
                  children: [
                    const TextSpan(
                      text: 'Account ',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    const TextSpan(
                      text: 'Deleted\nSuccessfully',
                      style: TextStyle(color: Color(0xFF0B243A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.accountDeletedDesc,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.black,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (isReviewUpdates) ...[
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.build(
                    size: 32,
                    height: 40,
                    weight: FontWeight.w500,
                    fontFamily: 'Helvetica Neue',
                  ),
                  children: [
                    const TextSpan(
                      text: AppStrings.weAreReviewing,
                      style: TextStyle(color: AppColors.primary),
                    ),
                    const TextSpan(
                      text: '\n${AppStrings.yourUpdates}',
                      style: TextStyle(color: Color(0xFF0B243A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.reviewUpdatesDesc,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.black,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppStrings.documentVerification,
                  style: AppTextStyles.build(
                    size: 32,
                    height: 40,
                    weight: FontWeight.w500,
                    fontFamily: 'Helvetica Neue',
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                AppStrings.inProgress,
                style: AppTextStyles.build(
                  size: 32,
                  height: 40,
                  weight: FontWeight.w500,
                  fontFamily: 'Helvetica Neue',
                  color: const Color(0xFF0B243A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.verificationDesc,
                style: AppTextStyles.pSmall.copyWith(
                  color: AppColors.black,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const Spacer(flex: 2),

            AppButton(
              label: isDeleteSuccess ? AppStrings.done : AppStrings.goToHome,
              onPressed: () => Get.offAllNamed(
                isDeleteSuccess ? AppRoutes.login : AppRoutes.dashboard,
              ),
            ),
            SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
