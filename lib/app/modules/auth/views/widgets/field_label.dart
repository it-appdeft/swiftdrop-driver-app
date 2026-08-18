import 'package:flutter/material.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' (');
    final mainText = parts[0];
    final subText = parts.length > 1 ? ' (${parts[1]}' : '';

    return RichText(
      text: TextSpan(
        style: AppTextStyles.build(
          size: 14,
          weight: FontWeight.w500,
          color: const Color(0xFF374151),
        ),
        children: [
          TextSpan(text: mainText),
          if (subText.isNotEmpty)
            TextSpan(
              text: subText,
              style: AppTextStyles.build(
                size: 14, // PS matches pSmall size
                height: 20,
                weight: FontWeight.w400,
                color: AppColors.otpSubtitle,
              ),
            ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
