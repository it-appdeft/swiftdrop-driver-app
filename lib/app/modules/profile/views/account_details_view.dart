import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_picker_utils.dart';
import '../../../widgets/app_app_bar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../auth/views/widgets/field_label.dart';
import '../controllers/account_details_controller.dart';

class AccountDetailsView extends GetView<AccountDetailsController> {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          onSurface: Color(0xFF1A1A2E),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(
          title: AppStrings.accountDetails,
          onBack: () => Get.back(),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Bank Details ──────────────────────────────────────────
                    _buildSectionHeader(AppStrings.bankDetails),
                    const SizedBox(height: 16),
                    const FieldLabel(AppStrings.accountHolderName, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.accountHolderController,
                      hint: AppStrings.enterAccountHolderName,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel(AppStrings.accountNumber, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.accountNumberController,
                      hint: AppStrings.enterAccountNumber,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      fillColor: Colors.white,
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel(AppStrings.sortCode, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.sortCodeController,
                      hint: AppStrings.sortCodeHint,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                        LengthLimitingTextInputFormatter(8),
                      ],
                      fillColor: Colors.white,
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 20),
                    const FieldLabel(AppStrings.bankName, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.bankNameController,
                      hint: AppStrings.enterBankName,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 32),
                    // ─── Vehicle Details ───────────────────────────────────────
                    _buildSectionHeader(AppStrings.vehicleDetails),
                    const SizedBox(height: 16),
                    
                    const FieldLabel(AppStrings.vehicleType, required: true),
                    const SizedBox(height: 8),
                    Obx(() {
                      final types = controller.vehicleTypesList;
                      final names = types.map((e) => e.name).toList();
                      return _DropdownField<String>(
                        value: controller.selectedVehicleType.value?.name,
                        hint: AppStrings.selectVehicleType,
                        items: names,
                        onChanged: (v) {
                          if (v == null) return;
                          try {
                            controller.selectedVehicleType.value =
                                types.firstWhere((e) => e.name == v);
                          } catch (_) {}
                        },
                      );
                    }),
                    const SizedBox(height: 20),

                    const FieldLabel(AppStrings.registrationNumber, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.registrationNumberController,
                      hint: AppStrings.vrnHint,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(AppStrings.vehicleMake, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.vehicleMakeController,
                      hint: AppStrings.selectManufacturer,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(AppStrings.vehicleModel, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.vehicleModelController,
                      hint: AppStrings.selectModel,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(AppStrings.vehicleColor, required: true),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: controller.vehicleColorController,
                      hint: AppStrings.typeVehicleColor,
                      fillColor: Colors.white,
                      textColor: Colors.black,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    const FieldLabel(AppStrings.yearOfManufacture, required: true),
                    const SizedBox(height: 8),
                    Obx(() => _DateField(
                      value: controller.yearOfManufacture.value,
                      hint: AppStrings.selectYear,
                      isYearOnly: true,
                      onTap: () => controller.pickDate(
                        context,
                        controller.yearOfManufacture,
                        lastDate: DateTime.now(),
                      ),
                    )),
                    const SizedBox(height: 20),

                    Obx(() {
                      if (!controller.requiresInsurance) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FieldLabel(AppStrings.insuranceType, required: true),
                          const SizedBox(height: 8),
                          _DropdownField<String>(
                            value: controller.insuranceTypeValue.value,
                            hint: AppStrings.selectInsuranceType,
                            items: const [
                              'Comprehensive',
                              'Third Party',
                              'Third Party, Fire & Theft',
                            ],
                            onChanged: (v) => controller.insuranceTypeValue.value = v,
                          ),
                          const SizedBox(height: 20),

                          const FieldLabel(AppStrings.insuranceExpiryDate, required: true),
                          const SizedBox(height: 8),
                          _DateField(
                            value: controller.insuranceExpiry.value,
                            hint: AppStrings.selectInsuranceExpiry,
                            onTap: () => controller.pickDate(
                              context,
                              controller.insuranceExpiry,
                              firstDate: DateTime.now(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const FieldLabel(AppStrings.motExpiryDate, required: false),
                          const SizedBox(height: 8),
                          _DateField(
                            value: controller.motExpiry.value,
                            hint: AppStrings.selectInsuranceExpiry,
                            onTap: () => controller.pickDate(
                              context,
                              controller.motExpiry,
                              firstDate: DateTime.now(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                    
                    const SizedBox(height: 20),
                    // ─── Document Section ──────────────────────────────────────
                    _buildSectionHeader('Documents'),
                    const SizedBox(height: 16),
                    Obx(() {
                      final reqLicence = controller.requiresDrivingLicence;
                      final reqInsurance = controller.requiresInsurance;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reqLicence) ...[
                            _buildDocumentItem(
                              context,
                              'licence_front',
                              'driving_licence_front',
                              'Driving License - Front',
                              controller.licenceFrontFile.value,
                            ),
                            const SizedBox(height: 12),
                            _buildDocumentItem(
                              context,
                              'licence_back',
                              'driving_licence_back',
                              'Driving License - Back',
                              controller.licenceBackFile.value,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _buildDocumentItem(
                            context,
                            'id_proof',
                            'id_proof',
                            'ID Proof',
                            controller.idProofFile.value,
                          ),
                          if (reqInsurance) ...[
                            const SizedBox(height: 12),
                            _buildDocumentItem(
                              context,
                              'insurance',
                              'insurance_certificate',
                              'Insurance Certificate',
                              controller.insuranceCertFile.value,
                            ),
                          ],
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: AppButton(
                label: AppStrings.update,
                onPressed: controller.updateDetails,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h6.copyWith(
        color: AppColors.navy900,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    String docKey,
    String apiDocType,
    String title,
    File? newFile,
  ) {
    if (newFile != null) {
      return _UploadBox(
        file: newFile,
        onRemove: () => controller.clearDocument(docKey),
      );
    }

    final uploadedDoc = controller.getUploadedDoc(apiDocType);
    if (uploadedDoc != null && uploadedDoc.fileUrl.isNotEmpty) {
      final uploadDate = uploadedDoc.createdAt != null && uploadedDoc.createdAt!.isNotEmpty
          ? DateFormat('MMM dd, yyyy').format(DateTime.tryParse(uploadedDoc.createdAt!) ?? DateTime.now())
          : 'Uploaded';

      return _DocumentCard(
        title: title,
        date: uploadDate,
        onView: () => _openImageViewer(context, uploadedDoc.fileUrl, title),
        onReupload: () {
          AppPickerUtils.showPicker(
            showDocument: docKey != 'licence_front' && docKey != 'licence_back',
            onFilePicked: (file) => controller.setDocument(docKey, file),
          );
        },
      );
    }

    return _UploadPromptBox(
      title: title,
      onUpload: () {
        AppPickerUtils.showPicker(
          showDocument: docKey != 'licence_front' && docKey != 'licence_back',
          onFilePicked: (file) => controller.setDocument(docKey, file),
        );
      },
    );
  }

  void _openImageViewer(BuildContext context, String imageUrl, String title) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Document image preview unavailable',
                          style: AppTextStyles.pSmallMedium.copyWith(color: AppColors.navy900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dropdown Field ──────────────────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownFlutter<T>(
      hintText: hint,
      items: items,
      initialItem: value,
      onChanged: onChanged,
      excludeSelected: false,
      decoration: CustomDropdownDecoration(
        closedFillColor: Colors.white,
        expandedFillColor: Colors.white,
        closedBorder: Border.all(color: AppColors.lightBorder, width: 1.0),
        expandedBorder: Border.all(color: AppColors.lightBorder, width: 1.0),
        closedBorderRadius: BorderRadius.circular(8),
        expandedBorderRadius: BorderRadius.circular(8),
        closedShadow: [],
        expandedShadow: [],
        headerStyle: AppTextStyles.pSmall.copyWith(color: AppColors.navy900),
        hintStyle: AppTextStyles.pSmall.copyWith(color: AppColors.otpSubtitle),
        listItemStyle: AppTextStyles.pSmall.copyWith(color: AppColors.navy900),
        closedSuffixIcon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.otpSubtitle),
        listItemDecoration: ListItemDecoration(
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: const Color(0xFFF9FAFB),
        ),
      ),
    );
  }
}

// ─── Date Field ──────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final bool isYearOnly;
  final VoidCallback onTap;

  const _DateField({
    required this.value,
    required this.hint,
    this.isYearOnly = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String formatted = hint;
    if (value != null) {
      formatted = isYearOnly ? value!.year.toString() : DateFormat('dd MMMM yyyy').format(value!);
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBorder, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatted,
              style: AppTextStyles.pSmall.copyWith(color: AppColors.navy900),
            ),
            Assets.images.datePicker.image(width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Document Card ───────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onView;
  final VoidCallback onReupload;

  const _DocumentCard({
    required this.title,
    required this.date,
    required this.onView,
    required this.onReupload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Assets.images.registrationImage.image(
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.pSmallMedium.copyWith(color: AppColors.navy900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Uploaded $date',
                      style: AppTextStyles.pXSmall.copyWith(
                        color: AppColors.otpSubtitle,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onView();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'View',
                      style: AppTextStyles.pSmallMedium.copyWith(color: AppColors.otpSubtitle),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                width: 98,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onReupload();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Re-upload',
                    style: AppTextStyles.pSmallMedium.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Upload Prompt Box (For Unuploaded Documents) ───────────────────────────

class _UploadPromptBox extends StatelessWidget {
  final String title;
  final VoidCallback onUpload;

  const _UploadPromptBox({
    required this.title,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.upload_file_rounded,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.pSmallMedium.copyWith(color: AppColors.navy900),
                ),
                const SizedBox(height: 2),
                Text(
                  'Not uploaded yet',
                  style: AppTextStyles.pXSmall.copyWith(
                    color: AppColors.deleteRed,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onUpload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Upload',
                style: AppTextStyles.pSmallMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upload Box (From Register Steps) ────────────────────────────────────────

class _UploadBox extends StatelessWidget {
  final File? file;
  final VoidCallback? onRemove;

  const _UploadBox({
    this.file,
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
        CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: uploaded ? AppColors.primary : const Color(0xFFE5E7EB),
            strokeWidth: 1.5,
            dashWidth: 5,
            dashSpace: 3,
            radius: AppDimensions.radiusMd,
          ),
          child: Container(
            width: double.infinity,
            height: 120, // Slightly shorter for account details view
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
                const Icon(
                  Icons.description_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  fileName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.build(
                    size: 14,
                    height: 20,
                    weight: FontWeight.w600,
                    color: AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'File uploaded successfully',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.build(
                    size: 12,
                    height: 16,
                    weight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
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
