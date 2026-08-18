import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ─── Dark theme (primary / design-first) ───────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // ─── Light theme (kept for compatibility) ──────────────────────────────────
  // Redirects to darkTheme — all design tokens are dark-first.
  static ThemeData get lightTheme => darkTheme;

  static ThemeData _buildTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.white,
          secondary: AppColors.navyMuted600,
          onSecondary: AppColors.white,
          error: AppColors.error,
          onError: AppColors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,

        // ── Typography (Inter) ────────────────────────────────────────────────
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.copyWith(
                displayLarge: AppTextStyles.h1,
                displayMedium: AppTextStyles.h2,
                displaySmall: AppTextStyles.h3,
                headlineLarge: AppTextStyles.h3,
                headlineMedium: AppTextStyles.h4,
                headlineSmall: AppTextStyles.h5,
                titleLarge: AppTextStyles.h6,
                titleMedium: AppTextStyles.pLargeMedium,
                titleSmall: AppTextStyles.pMediumMedium,
                bodyLarge: AppTextStyles.pMedium,
                bodyMedium: AppTextStyles.pSmall,
                bodySmall: AppTextStyles.pXSmall,
                labelLarge: AppTextStyles.pSmallSemiBold,
                labelMedium: AppTextStyles.pXSmallMedium,
                labelSmall: AppTextStyles.label,
              ),
        ),

        // ── AppBar ────────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          toolbarHeight: AppDimensions.appBarHeight,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.darkBackground,
          ),
          titleTextStyle: AppTextStyles.h6.copyWith(fontSize: 18),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          surfaceTintColor: Colors.transparent,
        ),

        // ── ElevatedButton ────────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.primaryLight500,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            elevation: 0,
            shadowColor: AppColors.transparent,
            textStyle: AppTextStyles.button,
          ),
        ),

        // ── OutlinedButton ────────────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),

        // ── TextButton ────────────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.pSmallSemiBold.copyWith(color: AppColors.primary),
          ),
        ),

        // ── Input ─────────────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkInputBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.inputPadding,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: AppTextStyles.pMedium.copyWith(color: AppColors.textHint),
          labelStyle: AppTextStyles.pSmall.copyWith(color: AppColors.textSecondary),
          errorStyle: AppTextStyles.pXSmall.copyWith(color: AppColors.error),
          prefixIconColor: AppColors.navyMuted300,
          suffixIconColor: AppColors.navyMuted300,
        ),

        // ── Card ──────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Divider ───────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 0,
        ),

        // ── Bottom navigation ─────────────────────────────────────────────────
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.navyMuted300,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTextStyles.pXSmallMedium,
          unselectedLabelStyle: AppTextStyles.pXSmallMedium,
        ),

        // ── Chip ──────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          labelStyle: AppTextStyles.pXSmallMedium,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXs,
            vertical: AppDimensions.gapXs,
          ),
        ),

        // ── SnackBar ──────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          contentTextStyle: AppTextStyles.pSmall.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),

        // ── Switch ────────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.navyMuted400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.3);
            }
            return AppColors.darkBorder;
          }),
        ),

        // ── Checkbox ──────────────────────────────────────────────────────────
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.white),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          ),
        ),

        // ── Progress indicator ────────────────────────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),

        // ── ListTile ──────────────────────────────────────────────────────────
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          iconColor: AppColors.navyMuted300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      );
}
