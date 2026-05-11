class AppDimensions {
  AppDimensions._();

  // ─── 4px Grid ──────────────────────────────────────────────────────────────
  static const double sp4  = 4;
  static const double sp8  = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp40 = 40;

  // ─── Padding ───────────────────────────────────────────────────────────────
  static const double paddingXs = 8;
  static const double paddingSm = 12;
  static const double paddingMd = 16;
  static const double paddingLg = 20;
  static const double paddingXl = 24;

  // ─── Gaps ──────────────────────────────────────────────────────────────────
  static const double gapXs = 4;
  static const double gapSm = 8;
  static const double gapMd = 12;
  static const double gapLg = 16;
  static const double gapXl = 24;

  // ─── Component heights ─────────────────────────────────────────────────────
  static const double inputHeight     = 52;
  static const double buttonHeight    = 52;
  static const double buttonHeightLg  = 56;
  static const double bottomNavHeight = 64;
  static const double appBarHeight    = 56;

  // ─── Border radius ─────────────────────────────────────────────────────────
  // xs=4  sm=8(inputs)  md=12(cards)  lg=16(buttons)  xl=20  xxl=24  full=100
  static const double radiusXs   = 4;
  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusXl   = 20;
  static const double radiusXxl  = 24;
  static const double radiusFull = 100;

  // ─── Shadow radii / opacities (use in BoxShadow) ──────────────────────────
  // Card shadow: blurRadius 16, offset (0,4), opacity 8%
  // Elevated shadow: blurRadius 24, offset (0,8), opacity 12%
  // Primary button shadow: green 24% opacity, blurRadius 16, offset (0,6)
  static const double shadowCardBlur     = 16;
  static const double shadowElevatedBlur = 24;
  static const double shadowButtonBlur   = 16;

  // ─── Backward-compatible aliases ───────────────────────────────────────────
  static const double xs   = radiusXs;
  static const double sm   = radiusSm;
  static const double md   = radiusMd;
  static const double lg   = radiusLg;
  static const double xl   = radiusXl;
  static const double xxl  = radiusXxl;
  static const double full = radiusFull;
  static const double xxxl = 64;

  static const double pagePadding  = paddingLg;
  static const double cardPadding  = paddingMd;
  static const double inputPadding = 14;

  static const double buttonHeightSm = 40;
  static const double buttonHeightXs = 32;

  static const double iconXs = 14;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 72;
  static const double avatarXl = 96;

  static const double elevationSm = 2;
  static const double elevationMd = 4;
  static const double elevationLg = 8;

  static const double mapHeight = 280;
}
