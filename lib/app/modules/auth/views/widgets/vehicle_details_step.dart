import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import '../../../../../generated/assets.dart';
import '../../../../constants/app_strings.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/register_controller.dart';
import 'field_label.dart';

class VehicleDetailsStep extends StatelessWidget {
  final RegisterController controller;
  const VehicleDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        cardColor: Colors.white,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: Colors.white,
          onSurface: Color(0xFF1A1A2E),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.0),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              final idx = int.tryParse(v);
              if (idx != null && idx >= 1 && idx <= types.length) {
                controller.selectedVehicleType.value = types[idx - 1];
              } else {
                try {
                  controller.selectedVehicleType.value =
                      types.firstWhere((e) => e.name == v);
                } catch (_) {}
              }
            },
          );
        }),
        const SizedBox(height: 24),

        const FieldLabel(AppStrings.registrationNumber, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.registrationNumberController,
          hint: AppStrings.vrnHint,
          fillColor: Colors.white,
          textColor: AppColors.inputText,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
          ],
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.inputHint,
          ),
        ),
        const SizedBox(height: 24),

        const FieldLabel(AppStrings.vehicleMake, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.vehicleMakeController,
          hint: AppStrings.selectManufacturer,
          fillColor: Colors.white,
          textColor: AppColors.inputText,
          textCapitalization: TextCapitalization.words,
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.inputHint,
          ),
        ),
        const SizedBox(height: 24),

        const FieldLabel(AppStrings.vehicleModel, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.vehicleModelController,
          hint: AppStrings.selectModel,
          fillColor: Colors.white,
          textColor: AppColors.inputText,
          textCapitalization: TextCapitalization.words,
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.inputHint,
          ),
        ),
        const SizedBox(height: 24),

        const FieldLabel(AppStrings.vehicleColor, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.vehicleColorController,
          hint: AppStrings.typeVehicleColor,
          fillColor: Colors.white,
          textColor: AppColors.inputText,
          textCapitalization: TextCapitalization.words,
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.inputHint,
          ),
        ),
        const SizedBox(height: 24),

        const FieldLabel(AppStrings.yearOfManufacture, required: true),
        const SizedBox(height: 8),
        Obx(() => _DateField(
              value: controller.yearOfManufacture.value,
              hint: AppStrings.selectYear,
              onTap: () => controller.pickDate(
                context,
                controller.yearOfManufacture,
                lastDate: DateTime.now(),
              ),
            )),
        const SizedBox(height: 24),

        Obx(() => !controller.requiresInsurance
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel(AppStrings.insuranceType, required: true),
                  const SizedBox(height: 8),
                  Obx(() => _DropdownField<String>(
                        value: controller.insuranceTypeValue.value,
                        hint: AppStrings.selectInsuranceType,
                        items: RegisterController.insuranceTypes,
                        onChanged: (v) {
                          if (v == null) return;
                          final idx = int.tryParse(v);
                          controller.insuranceTypeValue.value = (idx != null &&
                                  idx >= 1 &&
                                  idx <= RegisterController.insuranceTypes.length)
                              ? RegisterController.insuranceTypes[idx - 1]
                              : v;
                        },
                      )),
                  const SizedBox(height: 24),
                  const FieldLabel(AppStrings.insuranceExpiryDate,
                      required: true),
                  const SizedBox(height: 8),
                  Obx(() => _DateField(
                        value: controller.insuranceExpiry.value,
                        hint: AppStrings.selectInsuranceExpiry,
                        onTap: () => controller.pickDate(
                          context,
                          controller.insuranceExpiry,
                          firstDate: DateTime.now(),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
              )),

        const FieldLabel(AppStrings.motExpiryDate, required: false),
        const SizedBox(height: 8),
        Obx(() => _DateField(
              value: controller.motExpiry.value,
              hint: AppStrings.selectInsuranceExpiry,
              onTap: () => controller.pickDate(
                context,
                controller.motExpiry,
                firstDate: DateTime.now(),
              ),
            )),
        const SizedBox(height: 24),

        // Info note
        Container(
          height: 82,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoBoxBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.vehicleDocNote,
                  style: AppTextStyles.build(
                    size: 12,
                    color: AppColors.otpSubtitle,
                    height: 16.8, // 1.4 * 12
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
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
    return DropdownFlutter<T>(
      hintText: hint,
      items: items,
      initialItem: value,
      onChanged: onChanged,
      excludeSelected: false,

      decoration: CustomDropdownDecoration(
        closedFillColor: Colors.white,
        expandedFillColor: Colors.white,

        closedBorder: Border.all(
          color: AppColors.lightBorder,
          width: 1.0,
        ),

        expandedBorder: Border.all(
          color: AppColors.lightBorder,
          width: 1.0,
        ),

        closedBorderRadius: BorderRadius.circular(8),
        expandedBorderRadius: BorderRadius.circular(8),

        closedShadow: [],
        expandedShadow: [],

        headerStyle: AppTextStyles.build(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.inputText,
        ),

        hintStyle: AppTextStyles.build(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.inputHint,
        ),

        listItemStyle: AppTextStyles.build(
          size: 14,
          color: AppColors.inputText,
        ),

        closedSuffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
          color: AppColors.inputIcon,
        ),

        listItemDecoration: ListItemDecoration(
          selectedColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: const Color(0xFFF9FAFB),
        ),
      ),
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
              value != null
                  ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                  : hint,
              style: AppTextStyles.build(
                size: 14,
                weight: FontWeight.w400,
                color: value != null
                    ? AppColors.inputText
                    : AppColors.inputHint,
              ),
            ),
            Assets.images.datePicker.image(
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
