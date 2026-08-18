import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../constants/app_strings.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/register_controller.dart';
import 'field_label.dart';

class BankDetailsStep extends StatelessWidget {
  final RegisterController controller;
  const BankDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(AppStrings.accountHolderName, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.accountHolderController,
          hint: AppStrings.enterAccountHolderName,
          fillColor: Colors.white,
          textColor: Colors.black,
          textCapitalization: TextCapitalization.words,
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 24),
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
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 24),
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
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 24),
        const FieldLabel(AppStrings.bankName, required: true),
        const SizedBox(height: 8),
        AppTextField(
          controller: controller.bankNameController,
          hint: AppStrings.enterBankName,
          fillColor: Colors.white,
          textColor: Colors.black,
          textCapitalization: TextCapitalization.words,
          hintStyle: AppTextStyles.build(
            size: 14,
            weight: FontWeight.w400,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
