import 'package:flutter/material.dart';
import 'app_dimensions.dart';

class AppRadius {
  AppRadius._();

  // ─── Scalar doubles (for const context if needed) ─────────────────────────
  static const double sm   = AppDimensions.radiusSm;    // 8
  static const double md   = AppDimensions.radiusMd;    // 12
  static const double lg   = AppDimensions.radiusLg;    // 16
  static const double xl   = AppDimensions.radiusXl;    // 20
  static const double full = AppDimensions.radiusFull;  // 100

  // ─── BorderRadius objects ─────────────────────────────────────────────────
  static BorderRadius get xs      => BorderRadius.circular(AppDimensions.radiusXs);
  static BorderRadius get small   => BorderRadius.circular(AppDimensions.radiusSm);
  static BorderRadius get medium  => BorderRadius.circular(AppDimensions.radiusMd);
  static BorderRadius get large   => BorderRadius.circular(AppDimensions.radiusLg);
  static BorderRadius get xlarge  => BorderRadius.circular(AppDimensions.radiusXl);
  static BorderRadius get xxlarge => BorderRadius.circular(AppDimensions.radiusXxl);
  static BorderRadius get circle  => BorderRadius.circular(AppDimensions.radiusFull);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static BorderRadius get cardRadius      => BorderRadius.circular(AppDimensions.radiusMd);
  static BorderRadius get inputRadius     => BorderRadius.circular(AppDimensions.radiusSm);
  static BorderRadius get buttonRadius    => BorderRadius.circular(AppDimensions.radiusLg);
  static BorderRadius get orderCardRadius => BorderRadius.circular(AppDimensions.radiusLg);
  static BorderRadius get badgeRadius     => BorderRadius.circular(AppDimensions.radiusSm);
  static BorderRadius get chipRadius      => BorderRadius.circular(AppDimensions.radiusFull);
  static BorderRadius get avatarRadius    => BorderRadius.circular(AppDimensions.radiusFull);

  static BorderRadius get sheetRadius => const BorderRadius.only(
    topLeft:  Radius.circular(AppDimensions.radiusXxl),
    topRight: Radius.circular(AppDimensions.radiusXxl),
  );
}
