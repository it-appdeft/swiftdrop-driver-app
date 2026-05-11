import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get cardDefault => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: AppDimensions.shadowCardBlur,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardSubtle => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.04),
          blurRadius: AppDimensions.sp8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardElevated => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.12),
          blurRadius: AppDimensions.shadowElevatedBlur,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primaryButton => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.24),
          blurRadius: AppDimensions.shadowButtonBlur,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get none => const [];
}
