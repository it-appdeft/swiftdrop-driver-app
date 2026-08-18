import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../controllers/legal_controller.dart';

class LegalView extends GetView<LegalController> {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.title.value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final content = controller.legalContent.value;
        final paragraphs = content?.paragraphs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (paragraphs.isNotEmpty) ...[
                ...paragraphs.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.gapMd),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingMd),
                      decoration: BoxDecoration(
                        color: AppColors.infoBoxBg,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Text(
                        p,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.navy900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (content?.html.isNotEmpty ?? false) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.infoBoxBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Text(
                    content!.html.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.navy900,
                      height: 1.5,
                    ),
                  ),
                ),
              ] else ...[
                const Center(
                  child: Text('No content available'),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
