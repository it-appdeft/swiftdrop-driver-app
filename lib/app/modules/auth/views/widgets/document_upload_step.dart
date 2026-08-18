import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../generated/assets.dart';
import '../../../../constants/app_strings.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_dimensions.dart';
import '../../../../themes/app_text_styles.dart';
import '../../../../utils/app_picker_utils.dart';
import '../../controllers/register_controller.dart';
import 'field_label.dart';

class DocumentUploadStep extends StatelessWidget {
  final RegisterController controller;
  const DocumentUploadStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driving Licence — hidden when vehicle type doesn't require it
        Obx(() => !controller.requiresDrivingLicence
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel(AppStrings.drivingLicence, required: true),
                  const SizedBox(height: 12),
                  Obx(() => _UploadBox(
                        image: Assets.images.fontSide,
                        label: AppStrings.frontSide,
                        subtitle: AppStrings.uploadOrTakeAPhoto,
                        file: controller.licenceFrontFile.value,
                        onTap: () {
                          AppPickerUtils.showPicker(
                            showDocument: false,
                            onFilePicked: (file) =>
                                controller.setDocument('licence_front', file),
                          );
                        },
                        onRemove: () => controller.clearDocument('licence_front'),
                      )),
                  const SizedBox(height: 12),
                  Obx(() => _UploadBox(
                        image: Assets.images.backSide,
                        label: AppStrings.backSide,
                        subtitle: AppStrings.uploadOrTakeAPhoto,
                        file: controller.licenceBackFile.value,
                        onTap: () {
                          AppPickerUtils.showPicker(
                            showDocument: false,
                            onFilePicked: (file) =>
                                controller.setDocument('licence_back', file),
                          );
                        },
                        onRemove: () => controller.clearDocument('licence_back'),
                      )),
                  const SizedBox(height: 24),
                ],
              )),

        // ID Proof
        const FieldLabel(AppStrings.idProof, required: true),
        const SizedBox(height: 12),
        Obx(() => _UploadBox(
              image: Assets.images.iDProof,
              label: AppStrings.uploadIdProof,
              subtitle: AppStrings.pdfJpgOrPngMax5Mb,
              file: controller.idProofFile.value,
              onTap: () {
                AppPickerUtils.showPicker(
                  showDocument: true,
                  onFilePicked: (file) =>
                      controller.setDocument('id_proof', file),
                );
              },
              onRemove: () => controller.clearDocument('id_proof'),
            )),
        const SizedBox(height: 24),

        // Insurance Certificate — hidden when vehicle type doesn't require it
        Obx(() => !controller.requiresInsurance
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel(AppStrings.insuranceCertificate,
                      required: true),
                  const SizedBox(height: 12),
                  _UploadBox(
                    image: Assets.images.iDProof,
                    label: AppStrings.uploadCertificate,
                    subtitle: AppStrings.pdfJpgOrPngMax5Mb,
                    file: controller.insuranceCertFile.value,
                    onTap: () {
                      AppPickerUtils.showPicker(
                        showDocument: true,
                        onFilePicked: (file) =>
                            controller.setDocument('insurance', file),
                      );
                    },
                    onRemove: () => controller.clearDocument('insurance'),
                  ),
                  const SizedBox(height: 24),
                ],
              )),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  final AssetGenImage image;
  final String label;
  final String subtitle;
  final File? file;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _UploadBox({
    required this.image,
    required this.label,
    required this.subtitle,
    this.file,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool uploaded = file != null;
    final String rawName = file?.path.split('/').last ?? '';
    final String fileName = rawName
        .replaceFirst('image_cropper_', 'IMG_')
        .replaceFirst('image_picker_', 'IMG_');

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: CustomPaint(
            foregroundPainter: _DashedBorderPainter(
              color: uploaded ? AppColors.primary : const Color(0xFFE5E7EB),
              strokeWidth: 1.5,
              dashWidth: 5,
              dashSpace: 3,
              radius: AppDimensions.radiusMd,
            ),
            child: Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                color: uploaded
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (uploaded)
                    const Icon(
                      Icons.description_rounded,
                      size: 48,
                      color: AppColors.primary,
                    )
                  else
                    image.image(height: 48, fit: BoxFit.contain),
                  const SizedBox(height: 12),
                  Text(
                    uploaded ? fileName : label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.build(
                      size: 14,
                      height: 20,
                      weight: FontWeight.w600,
                      color: uploaded ? AppColors.navy900 : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    uploaded ? 'File uploaded successfully' : subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.build(
                      size: 12,
                      height: 16,
                      weight: FontWeight.w500,
                      color: uploaded ? AppColors.primary : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (uploaded) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change',
                      style: AppTextStyles.build(
                        size: 10,
                        weight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (uploaded && onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 14, color: AppColors.navy900),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromLTRBR(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth / 2,
      size.height - strokeWidth / 2,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rRect);

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.radius != radius;
  }
}
