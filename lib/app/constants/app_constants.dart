class AppConstants {
  AppConstants._();

  static const String appVersion = '1.0.0';

  // Timings (ms)
  static const int splashDuration = 5800;
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

  // Alerts & Messages
  static const String enterValidEmail = 'Please enter a valid email address';
  static const String codeSentTo = 'Code sent to ';
  static const String emailVerified = 'Email verified!';
  static const String enterMobileNumber = 'Please enter your mobile number';
  static const String otpSentTo = 'OTP sent to ';
  static const String phoneVerified = 'Phone number verified!';
  static const String enterFullName = 'Please enter your full name';
  static const String verifyEmailFirst = 'Please verify your email address';
  static const String verifyPhoneFirst = 'Please verify your mobile number';
  static const String enterCompleteOtp = 'Please enter the complete OTP';
  static const String invalidOtp = 'Invalid OTP. Please enter the correct code.';
  static const String otpResent = 'OTP resent successfully';
  static const String profileUpdated = 'Profile updated!';
  static const String orderAccepted = 'Order accepted!';
  static const String orderRejected = 'Order rejected';
  static const String pickupConfirmed = 'Pickup confirmed!';
  static const String deliveryConfirmed = 'Delivery confirmed! Great job!';
  static const String cacheCleared = 'Cache cleared successfully';
  static const String offlineMessage = 'Go online to start receiving nearby delivery requests and begin accepting orders.';
  static const String fillAllFields = 'Please fill all required fields';
}
