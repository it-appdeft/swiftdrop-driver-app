import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import 'app_loader.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      AppButtonSize.small  => AppDimensions.buttonHeightXs,
      AppButtonSize.medium => AppDimensions.buttonHeightSm,
      AppButtonSize.large  => AppDimensions.buttonHeight,
    };

    final textStyle = switch (size) {
      AppButtonSize.small => AppTextStyles.buttonSmall,
      _                   => AppTextStyles.button,
    };

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.primary => _buildElevated(
            bg: AppColors.primary,
            fg: AppColors.white,
            shadow: AppColors.primary.withValues(alpha: 0.24),
            textStyle: textStyle,
          ),
        AppButtonVariant.secondary => _buildElevated(
            bg: AppColors.darkSurfaceElevated,
            fg: AppColors.textPrimary,
            shadow: Colors.transparent,
            textStyle: textStyle.copyWith(color: AppColors.textPrimary),
          ),
        AppButtonVariant.outline => _buildOutline(textStyle: textStyle),
        AppButtonVariant.ghost => TextButton(
            onPressed: isLoading ? null : onPressed,
            child: Text(
              label,
              style: textStyle.copyWith(color: AppColors.primary),
            ),
          ),
        AppButtonVariant.danger => _buildElevated(
            bg: AppColors.error,
            fg: AppColors.white,
            shadow: AppColors.error.withValues(alpha: 0.20),
            textStyle: textStyle,
          ),
      },
    );
  }

  Widget _buildElevated({
    required Color bg,
    required Color fg,
    required Color shadow,
    required TextStyle textStyle,
  }) {
    final disabled = onPressed == null && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: shadow,
                  blurRadius: AppDimensions.shadowButtonBlur,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColors.primaryLight500 : bg,
          foregroundColor: fg,
          disabledBackgroundColor: AppColors.primaryLight500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
        ),
        child: _content(textStyle: textStyle, fg: fg),
      ),
    );
  }

  Widget _buildOutline({required TextStyle textStyle}) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: onPressed == null
              ? AppColors.darkBorder
              : AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      ),
      child: _content(
        textStyle: textStyle.copyWith(color: AppColors.primary),
        fg: AppColors.primary,
      ),
    );
  }

  Widget _content({required TextStyle textStyle, required Color fg}) {
    if (isLoading) return AppLoader.small(color: fg);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: AppDimensions.gapSm),
        ],
        Text(label, style: textStyle),
        if (suffixIcon != null) ...[
          const SizedBox(width: AppDimensions.gapSm),
          suffixIcon!,
        ],
      ],
    );
  }
}
