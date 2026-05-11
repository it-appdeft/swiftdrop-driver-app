import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 2.5,
  });

  static Widget small({Color color = AppColors.primary}) =>
      AppLoader(color: color, size: 20, strokeWidth: 2);

  static Widget medium({Color color = AppColors.primary}) =>
      AppLoader(color: color, size: 32, strokeWidth: 3);

  static Widget page() => const _PageLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

class _PageLoader extends StatelessWidget {
  const _PageLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader(color: AppColors.primary, size: 48, strokeWidth: 3),
            const SizedBox(height: AppDimensions.gapLg),
            Text(
              'Loading...',
              style: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
