import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import '../utils/responsive.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final AppButtonVariant variant;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.width,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = AppButtonVariant.primary,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = backgroundColor ?? AppColors.primary;
        fg = textColor ?? Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = backgroundColor ?? AppColors.darkSurfaceElevated;
        fg = textColor ?? AppColors.textPrimary;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = textColor ?? AppColors.primary;
        border = BorderSide(color: fg, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bg = backgroundColor ?? AppColors.error;
        fg = textColor ?? Colors.white;
        break;
    }

    return SizedBox(
      width: isFullWidth ? (width ?? double.infinity) : width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null)
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withOpacity(0.5),
          foregroundColor: fg,
          elevation: 0,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusSm),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
        ),
        child: isLoading
            ? SizedBox(
                width: Responsive.w(22),
                height: Responsive.w(22),
                child: CircularProgressIndicator(
                  color: fg,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: AppDimensions.gapSm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.pSmall.copyWith(color: fg),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: AppDimensions.gapSm),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
