class AppConstants {
  AppConstants._();

  static const String appVersion = '1.0.0';

  // Timings (ms)
  static const int splashDuration = 4000;
  static const int otpResendTimer = 60;
  static const int snackbarDuration = 3;

  // Auth
  static const int otpLength = 4;
  static const int phoneMinLength = 11;
  static const String defaultOtp = '9999';

  // Pagination
  static const int paginationLimit = 10;

  // Map
  static const double mapDefaultZoom = 15.0;
  static const double mapDriverZoom = 17.0;

  // UI
  static const double defaultRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double inputRadius = 10.0;

  // Onboarding
  static const int onboardingCount = 3;
}
