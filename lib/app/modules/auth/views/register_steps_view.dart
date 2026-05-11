import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../controllers/register_controller.dart';

class RegisterStepsView extends GetView<RegisterController> {
  const RegisterStepsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF1A1A2E)),
          onPressed: () {
            if (controller.currentStep.value > 1) {
              controller.currentStep.value--;
            } else {
              Get.back();
            }
          },
        ),
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: switch (step) {
                  1 => _BankDetailsStep(controller: controller),
                  2 => _VehicleDetailsStep(controller: controller),
                  3 => _DocumentUploadStep(controller: controller),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Step header ──────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  const _StepHeader({required this.step});

  static const _titles = ['Bank Details', 'Vehicle Details', 'Document Upload'];
  static const _percents = ['33% Complete', '66% Complete', '100% Complete'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP $step OF 3',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titles[step - 1],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                _percents[step - 1],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: step / 3,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Bank Details ─────────────────────────────────────────────────────

class _BankDetailsStep extends StatelessWidget {
  final RegisterController controller;
  const _BankDetailsStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Account Holder Name', required: true),
        _UnderlineField(
          controller: controller.accountHolderController,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 24),
        _FieldLabel('Account Number', required: true),
        _UnderlineField(
          controller: controller.accountNumberController,
          hint: 'Enter your account number',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _FieldLabel('Sort Code', required: true),
        _UnderlineField(
          controller: controller.sortCodeController,
          hint: 'e.g. 12-34-56',
        ),
        const SizedBox(height: 24),
        _FieldLabel('Bank Name', required: true),
        _UnderlineField(
          controller: controller.bankNameController,
          hint: 'Enter your bank name',
        ),
        const SizedBox(height: 40),
        Obx(() => _GreenButton(
              label: 'Continue',
              isLoading: controller.isLoading.value,
              onPressed: controller.isLoading.value
                  ? null
                  : controller.continueBankDetails,
            )),
      ],
    );
  }
}

// ─── Step 2: Vehicle Details ──────────────────────────────────────────────────

class _VehicleDetailsStep extends StatelessWidget {
  final RegisterController controller;
  const _VehicleDetailsStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Vehicle Type', required: true),
        Obx(() => _DropdownField<String>(
              value: controller.vehicleType.value,
              hint: 'Select your vehicle type',
              items: RegisterController.vehicleTypes,
              onChanged: (v) => controller.vehicleType.value = v,
            )),
        const SizedBox(height: 24),

        _FieldLabel('Registration Number (VRN)', required: true),
        _UnderlineField(
          controller: controller.registrationNumberController,
          hint: 'e.g. AB12 CDE',
        ),
        const SizedBox(height: 24),

        _FieldLabel('Vehicle Make', required: true),
        Obx(() => _DropdownField<String>(
              value: controller.vehicleMake.value,
              hint: 'Select vehicle manufacturer',
              items: RegisterController.vehicleMakes,
              onChanged: (v) => controller.vehicleMake.value = v,
            )),
        const SizedBox(height: 24),

        _FieldLabel('Vehicle Model', required: true),
        Obx(() => _DropdownField<String>(
              value: controller.vehicleModel.value,
              hint: 'Select model',
              items: RegisterController.vehicleModels,
              onChanged: (v) => controller.vehicleModel.value = v,
            )),
        const SizedBox(height: 24),

        _FieldLabel('Vehicle Color', required: true),
        _UnderlineField(
          controller: controller.vehicleColorController,
          hint: 'Type your vehicle color',
        ),
        const SizedBox(height: 24),

        _FieldLabel('Year of Manufacture', required: true),
        Obx(() => _DateField(
              value: controller.yearOfManufacture.value,
              hint: 'Select the year of manufacture',
              onTap: () => controller.pickDate(context, controller.yearOfManufacture),
            )),
        const SizedBox(height: 24),

        _FieldLabel('Insurance Type', required: true),
        Obx(() => _DropdownField<String>(
              value: controller.insuranceType.value,
              hint: 'Select insurance type',
              items: RegisterController.insuranceTypes,
              onChanged: (v) => controller.insuranceType.value = v,
            )),
        const SizedBox(height: 24),

        _FieldLabel('Insurance Expiry Date', required: true),
        Obx(() => _DateField(
              value: controller.insuranceExpiry.value,
              hint: 'Select insurance expiry date',
              onTap: () => controller.pickDate(context, controller.insuranceExpiry),
            )),
        const SizedBox(height: 24),

        _FieldLabel('MOT Expiry Date (if vehicle is over 3 years old)', required: false),
        Obx(() => _DateField(
              value: controller.motExpiry.value,
              hint: 'Select insurance expiry date',
              onTap: () => controller.pickDate(context, controller.motExpiry),
            )),
        const SizedBox(height: 24),

        // Info note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ensure your vehicle registration matches the documents you will upload in the next step.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Obx(() => _GreenButton(
              label: 'Continue',
              isLoading: controller.isLoading.value,
              onPressed: controller.isLoading.value
                  ? null
                  : controller.continueVehicleDetails,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Step 3: Document Upload ──────────────────────────────────────────────────

class _DocumentUploadStep extends StatelessWidget {
  final RegisterController controller;
  const _DocumentUploadStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driving Licence
        const _SectionTitle('Driving Licence'),
        const SizedBox(height: 12),
        Obx(() => _UploadBox(
              icon: Icons.camera_alt_rounded,
              label: 'FRONT SIDE',
              subtitle: 'Upload or take a photo',
              uploaded: controller.licenceFrontUploaded.value,
              onTap: () => controller.toggleUpload('licence_front'),
            )),
        const SizedBox(height: 12),
        Obx(() => _UploadBox(
              icon: Icons.camera_alt_rounded,
              label: 'BACK SIDE',
              subtitle: 'Upload or take a photo',
              uploaded: controller.licenceBackUploaded.value,
              onTap: () => controller.toggleUpload('licence_back'),
            )),
        const SizedBox(height: 24),

        // ID Proof
        const _SectionTitle('ID Proof'),
        const SizedBox(height: 12),
        Obx(() => _UploadBox(
              icon: Icons.badge_outlined,
              label: 'UPLOAD ID PROOF',
              subtitle: 'PDF, JPG or PNG (Max 5MB)',
              uploaded: controller.idProofUploaded.value,
              onTap: () => controller.toggleUpload('id_proof'),
            )),
        const SizedBox(height: 24),

        // Insurance Certificate
        const _SectionTitle('Insurance Certificate'),
        const SizedBox(height: 12),
        Obx(() => _UploadBox(
              icon: Icons.description_outlined,
              label: 'UPLOAD CERTIFICATE',
              subtitle: 'PDF, JPG or PNG (Max 5MB)',
              uploaded: controller.insuranceCertUploaded.value,
              onTap: () => controller.toggleUpload('insurance'),
            )),
        const SizedBox(height: 36),

        Obx(() => _GreenButton(
              label: 'Submit for Verification',
              isLoading: controller.isLoading.value,
              onPressed:
                  controller.isLoading.value ? null : controller.submitDocuments,
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          children: [
            TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      );
}

class _UploadBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool uploaded;
  final VoidCallback onTap;

  const _UploadBox({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(
            color: uploaded ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: uploaded
              ? AppColors.primary.withValues(alpha: 0.04)
              : Colors.white,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: uploaded
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                uploaded ? Icons.check_rounded : icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: uploaded ? AppColors.primary : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              uploaded ? 'Uploaded successfully' : subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151)),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                  text: ' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _UnderlineField(
      {required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

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
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      items: items
          .map((e) => DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)))))
          .toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          size: 20, color: Colors.grey[500]),
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      dropdownColor: Colors.white,
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DateField(
      {required this.value, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                  : hint,
              style: TextStyle(
                fontSize: 14,
                color: value != null ? const Color(0xFF1A1A2E) : Colors.grey[400],
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GreenButton(
      {required this.label, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
