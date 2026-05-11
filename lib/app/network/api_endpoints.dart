class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ────────────────────────────────────────────────────────────────
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ─── Profile ─────────────────────────────────────────────────────────────
  static const String profile = '/driver/profile';
  static const String updateProfile = '/driver/profile/update';
  static const String uploadDocument = '/driver/documents/upload';
  static const String updateLocation = '/driver/location';
  static const String toggleOnline = '/driver/status/toggle';

  // ─── Orders ──────────────────────────────────────────────────────────────
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
  static const String supportTickets = '/driver/support/tickets';
  static const String createTicket = '/driver/support/tickets/create';
  static const String appConfig = '/app/config';
}
