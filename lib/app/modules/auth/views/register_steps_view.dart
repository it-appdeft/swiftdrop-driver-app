import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../controllers/register_controller.dart';
import 'widgets/bank_details_step.dart';
import 'widgets/document_upload_step.dart';
import 'widgets/vehicle_details_step.dart';

class RegisterStepsView extends GetView<RegisterController> {
  const RegisterStepsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => AppAppBar(
          title: '',
          showBack: controller.currentStep.value > controller.initialStep,
          onBack: () => controller.currentStep.value--,
        )),
      ),
      body: Obx(() {
        final step = controller.currentStep.value;
        return Column(
          children: [
            // ─── Step header ──────────────────────────────────────────────
            _StepHeader(step: step),

            // ─── Step content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(AppDimensions.sp16),
                  vertical: Responsive.h(AppDimensions.sp24),
                ),
                child: _buildStepContent(step),
              ),
            ),

            // ─── Bottom Button ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(AppDimensions.sp16),
                Responsive.h(16),
                Responsive.w(AppDimensions.sp16),
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: AppButton(
                label: step == 3
                    ? AppStrings.submitForVerification
                    : AppStrings.continueText,
                isLoading: controller.isLoading.value,
                onPressed: controller.isLoading.value
                    ? null
                    : () => _handleContinue(step),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return BankDetailsStep(controller: controller);
      case 2:
        return VehicleDetailsStep(controller: controller);
      case 3:
        return DocumentUploadStep(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleContinue(int step) {
    switch (step) {
      case 1:
        controller.continueBankDetails();
        break;
      case 2:
        controller.continueVehicleDetails();
        break;
      case 3:
        controller.submitDocuments();
        break;
    }
  }
}

// ─── Step header ──────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  const _StepHeader({required this.step});

  static const _titles = [
    AppStrings.bankDetails,
    AppStrings.vehicleDetails,
    AppStrings.documentUpload
  ];
  static const _percents = [
    '33% ${AppStrings.completeSuffix}',
    '66% ${AppStrings.completeSuffix}',
    '100% ${AppStrings.completeSuffix}'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(AppDimensions.sp16),
        0,
        Responsive.w(AppDimensions.sp16),
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.stepPrefix} $step ${AppStrings.stepOf}',
            style: AppTextStyles.build(
              size: 12,
              weight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
              height: 16,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titles[step - 1],
                style: AppTextStyles.build(
                  size: 18,
                  weight: FontWeight.w500,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: 0,
                ),
              ),
              Text(
                _percents[step - 1],
                style: AppTextStyles.build(
                  size: 12,
                  weight: FontWeight.w500,
                  color: AppColors.primary,
                  height: 16,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: step / 3,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          SizedBox(height: Responsive.h(AppDimensions.sp24)),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.stroke,
          ),
        ],
      ),
    );
  }
}
