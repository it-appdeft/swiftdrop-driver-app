import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAction!();
            },
            child: Text(
              actionLabel!,
              style: AppTextStyles.pXSmall.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.gapSm),
      child: Divider(color: AppColors.darkBorder, thickness: 0.5, height: 0),
    );
  }
}
