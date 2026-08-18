class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String registerDriver = '/auth/register/driver';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ─── Vehicle Types ────────────────────────────────────────────────────────
  static const String vehicleTypes = '/vehicle-types';

  // ─── Profile ─────────────────────────────────────────────────────────────
  static const String profile = '/driver/profile';
  static const String profileSetup = '/driver/profile/setup';
  static const String completeSetup = '/driver/profile/account-details';
  static const String updateProfile = '/driver/profile';
  static const String uploadDocument = '/driver/documents/upload';
  static const String deleteAccountInitiate = '/driver/profile/delete/initiate';
  static const String updateLocation = '/driver/location';
  static const String driverDashboard = '/driver/dashboard';
  static const String driverAvailability = '/driver/availability';

  // ─── Orders ──────────────────────────────────────────────────────────────
  static const String deliveryRequests = '/driver/delivery-requests';
  static const String activeOrders = '/driver/orders/active';
  static const String orderHistory = '/driver/orders/history';
  static String orderDetail(String id) => '/driver/orders/$id';
  static const String acceptOrder = '/driver/orders/accept';
  static const String rejectOrder = '/driver/orders/reject';
  static const String updateOrderStatus = '/driver/orders/status';
  static const String confirmPickup = '/driver/orders/pickup';
  static const String confirmDelivery = '/driver/orders/deliver';

  // ─── Earnings ────────────────────────────────────────────────────────────
  static const String earnings = '/driver/earnings';
  static const String earningsSummary = '/driver/earnings/summary';
  static const String withdrawRequest = '/driver/earnings/withdraw';
  static const String transactionHistory = '/driver/transactions';

  // ─── Notifications ───────────────────────────────────────────────────────
  static const String notifications = '/driver/notifications';
  static const String markNotificationRead = '/driver/notifications/read';
  static const String registerFcmToken = '/driver/fcm-token';

  // ─── Support ─────────────────────────────────────────────────────────────
  static const String createTicket = '/support-tickets';

  // ─── Legal & Account Deletion ─────────────────────────────────────────────
  static const String termsAndConditions = '/legal/terms-and-conditions';
  static const String privacyPolicy = '/legal/privacy-policy';
  static const String deletionReasons = '/deletion-reasons';
  static const String appConfig = '/app/config';
}
