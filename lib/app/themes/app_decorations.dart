import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_radius.dart';
import 'app_shadows.dart';

class AppDecorations {
  AppDecorations._();

  // ─── Cards ────────────────────────────────────────────────────────────────

  static BoxDecoration get cardLight => BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.cardDefault,
      );

  static BoxDecoration get cardDark => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      );

  static BoxDecoration get orderCardDark => BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.orderCardRadius,
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      );

  static BoxDecoration get surfaceElevatedDark => BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      );

  // ─── Inputs ───────────────────────────────────────────────────────────────

  static BoxDecoration get inputDark => BoxDecoration(
        color: AppColors.darkInputBg,
        borderRadius: AppRadius.inputRadius,
        border: Border.all(color: AppColors.darkBorder, width: 1),
      );

  static BoxDecoration inputFocused(bool focused) => BoxDecoration(
        color: AppColors.darkInputBg,
        borderRadius: AppRadius.inputRadius,
        border: Border.all(
          color: focused ? AppColors.primary : AppColors.darkBorder,
          width: focused ? 1.5 : 1,
        ),
      );

  // ─── Buttons ──────────────────────────────────────────────────────────────

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.buttonRadius,
        boxShadow: AppShadows.primaryButton,
      );

  static BoxDecoration get outlineButtonDecoration => BoxDecoration(
        borderRadius: AppRadius.buttonRadius,
        border: Border.all(color: AppColors.primary, width: 1.5),
      );

  // ─── Gradient cards ───────────────────────────────────────────────────────

  static BoxDecoration get gradientCard => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.primaryButton,
      );

  static BoxDecoration get headerGradient => BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(AppDimensions.radiusXxl),
          bottomRight: Radius.circular(AppDimensions.radiusXxl),
        ),
      );

  static BoxDecoration get darkNavyGradient => BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: AppRadius.cardRadius,
      );

  // ─── Badges ───────────────────────────────────────────────────────────────

  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chipRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      );
}
