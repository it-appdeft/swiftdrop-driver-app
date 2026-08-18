import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color phoneTitleColor  = Color(0xFF595D70);

  // ─── Auth / OTP ────────────────────────────────────────────────────────────
  static const Color otpTitle           = Color(0xFF3C4042);
  static const Color otpSubtitle        = Color(0xFF868AA5);
  static const Color otpDigit           = Color(0xFF0F191F);
  static const Color otpBoxBg           = Color(0xFFF3F4F6);
  static const Color otpResendInactive  = Color(0xFFE1E2E3);

  // ─── System tints ──────────────────────────────────────────────────────────
  static const Color tintBlue = Color(0xFF007AFF);
  // ─── Primary brand — Green ─────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1BC27D);
  static const Color primaryDark    = Color(0xFF169B64);
  static const Color primaryDarker  = Color(0xFF138858);
  static const Color primaryDarkest = Color(0xFF10744B);
  static const Color primaryLight   = Color(0xFF32C88A);
  static const Color primaryLight200 = Color(0xFF49CE97);
  static const Color primaryLight300 = Color(0xFF5FD4A4);
  static const Color primaryLight400 = Color(0xFF76DAB1);
  static const Color primaryLight500 = Color(0xFF8DE1BE);

  // ─── Navy dark theme ───────────────────────────────────────────────────────
  static const Color navy900 = Color(0xFF0B243A);
  static const Color navy800 = Color(0xFF0A2034);
  static const Color navy700 = Color(0xFF091D2E);
  static const Color navy600 = Color(0xFF081929);
  static const Color navy500 = Color(0xFF071623);

  static const Color navyMuted600 = Color(0xFF233A4E);
  static const Color navyMuted500 = Color(0xFF3C5061);
  static const Color navyMuted400 = Color(0xFF546675);
  static const Color navyMuted300 = Color(0xFF6D7C89);
  static const Color navyMuted200 = Color(0xFF85929D);

  // ─── Grayscale ─────────────────────────────────────────────────────────────
  static const Color gray50  = Color(0xFFF5F6EE);
  static const Color gray100 = Color(0xFFDDDDD6);
  static const Color gray200 = Color(0xFFC4C5BE);
  static const Color gray300 = Color(0xFFACACA7);
  static const Color gray400 = Color(0xFF93948F);
  static const Color gray500 = Color(0xFF7B7B77);
  static const Color gray600 = Color(0xFF62625F);
  static const Color gray700 = Color(0xFF4A4A47);
  static const Color gray800 = Color(0xFF313130);
  static const Color gray900 = Color(0xFF191918);

  // ─── Warm backgrounds ──────────────────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFFF5F6EE);
  static const Color bgSecondary = Color(0xFFF6F7F0);
  static const Color bgTertiary  = Color(0xFFF8F9F3);
  static const Color bgWarm      = Color(0xFFFCFCFA);
  static const Color bgWhite     = Color(0xFFFEFEFD);

  // ─── Dark theme surfaces ───────────────────────────────────────────────────
  static const Color darkBackground      = Color(0xFF121212);
  static const Color darkSurface         = Color(0xFF1E1E2E);
  static const Color darkSurfaceElevated = Color(0xFF252535);
  static const Color darkBorder          = Color(0xFF2E3A47);
  static const Color darkInputBg         = Color(0xFF1A2535);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF1BC27D);
  static const Color successLight = Color(0xFF8DE1BE);
  static const Color warning      = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error        = Color(0xFFE53935);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color deleteRed    = Color(0xFFDC3545);
  static const Color info         = navyMuted600;

  // ─── Neutral ───────────────────────────────────────────────────────────────
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color stroke      = Color(0xFFF2F2E9);

  // ─── Semantic aliases — dark-theme mapped ──────────────────────────────────
  static const Color background    = darkBackground;
  static const Color surface       = darkSurface;
  static const Color border        = darkBorder;
  static const Color divider       = darkBorder;
  static const Color textPrimary   = gray50;           // near-white on dark bg
  static const Color textSecondary = navyMuted200;
  static const Color textHint      = navyMuted300;
  static const Color textMuted     = navyMuted300;
  static const Color textDisabled  = navyMuted400;
  static const Color textOnPrimary = white;
  static const Color textOnDark    = white;

  // Dark shimmer (for skeleton loading on dark bg)
  static const Color shimmerBase      = darkSurface;
  static const Color shimmerHighlight = darkSurfaceElevated;

  // ─── Order status ──────────────────────────────────────────────────────────
  static const Color statusNew       = Color(0xFF3498DB);
  static const Color statusAccepted  = warning;
  static const Color statusPickedUp  = Color(0xFF9C27B0);
  static const Color statusDelivered = success;
  static const Color statusCancelled = error;

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0A2034), Color(0xFF1BC27D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [navy900, navy700],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color lightBorder    = Color(0xFFE5E7EB);
  static const Color inputHint      = Color(0xFF9CA3AF);
  static const Color inputText      = Color(0xFF1A1A2E);
  static const Color inputIcon      = Color(0xFF6B7280);
  static const Color inputBg        = Color(0xFFF3F4F6);
  static const Color infoBoxBg      = Color(0xFFF6F8FA);
  static const Color logoutBg       = Color(0xFFEDEEF1);
  static const Color profileBodyText = Color(0xFF434656);

  // ─── Compat aliases ────────────────────────────────────────────────────────
  static const Color secondary      = navyMuted600;
  static const Color secondaryLight = navyMuted500;
  static const Color accent         = primary;
  static const Color infoLight      = Color(0xFF1A2535);
  static const Color overlay        = Color(0x80000000);
  static const Color scrim          = Color(0xCC000000);
}
