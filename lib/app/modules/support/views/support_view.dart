import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../controllers/support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        title: controller.isContactSupport.value
            ? AppStrings.contactSupport
            : AppStrings.helpCenter,
        onBack: () => Get.back(),
      ),
      body: controller.isContactSupport.value
          ? _buildContactSupport()
          : _buildHelpCenter(),
      bottomNavigationBar: !controller.isContactSupport.value
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Obx(
                () => AppButton(
                  label: AppStrings.submit,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitHelpRequest,
                ),
              ),
            )
          : const SizedBox.shrink(),
    ));
  }

  Widget _buildContactSupport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        children: [
          _ContactCard(
            asset: Assets.images.supportCall,
            label: AppStrings.phone,
            value: '+44 XXX15 XXX65',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _ContactCard(
            asset: Assets.images.supportEmail,
            label: AppStrings.email,
            value: 'abcdfg@example.com',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCenter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.needHelpIntro,
            style: AppTextStyles.pSmallRegular.copyWith(
              color: AppColors.otpSubtitle,
              height: 1.5,
            ),
          ),
          AppTextField(
            label: 'Order Reference (Optional)',
            hint: 'e.g. SWT-0006',
            isRequired: false,
            controller: controller.orderReferenceController,
            fillColor: AppColors.white,
            textColor: AppColors.navy900,
            labelColor: AppColors.navy900,
            labelFontSize: 14,
            labelFontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.titleLabel,
            hint: AppStrings.titleHint,
            isRequired: true,
            controller: controller.titleController,
            fillColor: AppColors.white,
            textColor: AppColors.navy900,
            labelColor: AppColors.navy900,
            labelFontSize: 14,
            labelFontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: AppStrings.explainProblemLabel,
            hint: AppStrings.problemHint,
            isRequired: true,
            controller: controller.problemController,
            maxLines: 10,
            fillColor: AppColors.white,
            textColor: AppColors.navy900,
            labelColor: AppColors.navy900,
            labelFontSize: 14,
            labelFontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final AssetGenImage asset;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactCard({
    required this.asset,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.infoBoxBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            asset.image(
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.pSmall.copyWith(
                      color: AppColors.otpSubtitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.pMediumMedium.copyWith(
                      color: AppColors.navy900,
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
