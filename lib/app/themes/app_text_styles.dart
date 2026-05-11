import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Helper ────────────────────────────────────────────────────────────────
  static TextStyle _inter({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ─── Headings ──────────────────────────────────────────────────────────────
  // H1 — 48 / 96 / w700
  static TextStyle get h1 => _inter(size: 48, height: 96, weight: FontWeight.w700);
  static TextStyle get h1Regular => _inter(size: 48, height: 96);

  // H2 — 40 / 48 / w700
  static TextStyle get h2 => _inter(size: 40, height: 48, weight: FontWeight.w700);
  static TextStyle get h2SemiBold => _inter(size: 40, height: 48, weight: FontWeight.w600);

  // H3 — 32 / 40 / w700
  static TextStyle get h3 => _inter(size: 32, height: 40, weight: FontWeight.w700);
  static TextStyle get h3SemiBold => _inter(size: 32, height: 40, weight: FontWeight.w600);

  // H4 — 28 / 36 / w600
  static TextStyle get h4 => _inter(size: 28, height: 36, weight: FontWeight.w600);
  static TextStyle get h4Bold => _inter(size: 28, height: 36, weight: FontWeight.w700);

  // H5 — 24 / 32 / w600
  static TextStyle get h5 => _inter(size: 24, height: 32, weight: FontWeight.w600);
  static TextStyle get h5Bold => _inter(size: 24, height: 32, weight: FontWeight.w700);

  // H6 — 20 / 28 / w600
  static TextStyle get h6 => _inter(size: 20, height: 28, weight: FontWeight.w600);
  static TextStyle get h6Bold => _inter(size: 20, height: 28, weight: FontWeight.w700);

  // ─── Body ──────────────────────────────────────────────────────────────────
  // P Large — 18 / 28
  static TextStyle get pLarge => _inter(size: 18, height: 28);
  static TextStyle get pLargeMedium => _inter(size: 18, height: 28, weight: FontWeight.w500);
  static TextStyle get pLargeSemiBold => _inter(size: 18, height: 28, weight: FontWeight.w600);

  // P Medium (default body) — 16 / 24
  static TextStyle get pMedium => _inter(size: 16, height: 24);
  static TextStyle get pMediumMedium => _inter(size: 16, height: 24, weight: FontWeight.w500);
  static TextStyle get pMediumSemiBold => _inter(size: 16, height: 24, weight: FontWeight.w600);
  static TextStyle get pMediumBold => _inter(size: 16, height: 24, weight: FontWeight.w700);

  // P Small — 14 / 20
  static TextStyle get pSmall => _inter(size: 14, height: 20);
  static TextStyle get pSmallMedium => _inter(size: 14, height: 20, weight: FontWeight.w500);
  static TextStyle get pSmallSemiBold => _inter(size: 14, height: 20, weight: FontWeight.w600);

  // P XSmall — 12 / 16
  static TextStyle get pXSmall => _inter(size: 12, height: 16);
  static TextStyle get pXSmallMedium => _inter(size: 12, height: 16, weight: FontWeight.w500);
  static TextStyle get pXSmallSemiBold => _inter(size: 12, height: 16, weight: FontWeight.w600);

  // ─── Special ───────────────────────────────────────────────────────────────
  static TextStyle get label => _inter(size: 12, height: 16, weight: FontWeight.w600, letterSpacing: 0.5);
  static TextStyle get overline => _inter(size: 10, height: 14, weight: FontWeight.w500, letterSpacing: 1.5);
  static TextStyle get caption => _inter(size: 11, height: 14, color: AppColors.textHint);

  static TextStyle get amount => _inter(size: 22, height: 28, weight: FontWeight.w700, color: AppColors.success);
  static TextStyle get amountLarge => _inter(size: 32, height: 40, weight: FontWeight.w700, color: AppColors.success);

  static TextStyle get button => _inter(size: 16, height: 24, weight: FontWeight.w600, color: AppColors.white);
  static TextStyle get buttonSmall => _inter(size: 14, height: 20, weight: FontWeight.w600, color: AppColors.white);

  // ─── Spec aliases (h1Bold, pMediumRegular, etc.) ─────────────────────────
  static TextStyle get h1Bold       => h1;
  static TextStyle get h2Bold       => h2;
  static TextStyle get h3Bold       => h3;
  static TextStyle get h4SemiBold   => h4;
  static TextStyle get h5SemiBold   => h5;
  static TextStyle get h6SemiBold   => h6;

  static TextStyle get pLargeRegular  => pLarge;
  static TextStyle get pMediumRegular => pMedium;
  static TextStyle get pSmallRegular  => pSmall;
  static TextStyle get pXsRegular     => pXSmall;

  static TextStyle get buttonLabel   => button;
  static TextStyle get buttonLabelSm => buttonSmall;

  static TextStyle get cardTitle    => h6;
  static TextStyle get cardSubtitle => pSmall.copyWith(color: AppColors.textSecondary);
  static TextStyle get sectionTitle => pMediumSemiBold;
  static TextStyle get priceText    => amount;

  // ─── Backward-compatible static aliases ────────────────────────────────────
  static TextStyle get displayLarge    => h1;
  static TextStyle get displayMedium   => h2;
  static TextStyle get headlineLarge   => h3;
  static TextStyle get headlineMedium  => h4;
  static TextStyle get headlineSmall   => h5;
  static TextStyle get titleLarge      => h6;
  static TextStyle get titleMedium     => pLargeMedium;
  static TextStyle get titleSmall      => pMediumMedium;
  static TextStyle get bodyLarge       => pMedium;
  static TextStyle get bodyMedium      => pSmall.copyWith(color: AppColors.textSecondary);
  static TextStyle get bodySmall       => pXSmall.copyWith(color: AppColors.textSecondary);
  static TextStyle get labelLarge      => pSmallSemiBold;
  static TextStyle get labelMedium     => pXSmallMedium.copyWith(color: AppColors.textSecondary);
  static TextStyle get labelSmall      => _inter(size: 11, height: 14, weight: FontWeight.w500, color: AppColors.textSecondary);
}
