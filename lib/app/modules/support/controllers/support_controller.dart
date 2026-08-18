import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../base/base_controller.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';

class SupportController extends BaseController {
  final AuthRepository _authRepo;
  SupportController(this._authRepo);

  final orderReferenceController = TextEditingController();
  final titleController = TextEditingController();
  final problemController = TextEditingController();
  
  final RxBool isContactSupport = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Determine view mode from arguments
    final mode = Get.arguments?['mode'] ?? 'contact';
    isContactSupport.value = mode == 'contact';
  }

  @override
  void onClose() {
    orderReferenceController.dispose();
    titleController.dispose();
    problemController.dispose();
    super.onClose();
  }

  Future<void> submitHelpRequest() async {
    final title = titleController.text.trim();
    final problem = problemController.text.trim();
    final orderRef = orderReferenceController.text.trim();

    if (title.isEmpty) {
      AppUtils.showError('Please enter a title');
      return;
    }
    if (problem.isEmpty) {
      AppUtils.showError('Please explain the problem');
      return;
    }

    await runAsync(() async {
      final res = await _authRepo.createSupportTicket(
        subject: title,
        description: problem,
        orderReference: orderRef.isNotEmpty ? orderRef : null,
      );
      if (res.success) {
        final reference = res.data?['reference']?.toString() ?? '';
        final msg = res.message.isNotEmpty ? res.message : 'Support ticket submitted.';
        titleController.clear();
        problemController.clear();
        orderReferenceController.clear();
        _showSuccessDialog(reference, msg);
      } else {
        AppUtils.showError(
            res.message.isNotEmpty ? res.message : 'Failed to submit support ticket');
      }
    });
  }

  void _showSuccessDialog(String reference, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket Submitted!',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.infoBoxBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Text(
                    'Ticket #$reference',
                    style: AppTextStyles.pSmallSemiBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Your support ticket has been submitted. Our support team will review your inquiry and get back to you shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Done',
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Close support screen
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
