import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/connectivity_middleware.dart';
import '../middleware/notification_middleware.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/register_steps_view.dart';
import '../modules/auth/views/verification_pending_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/earnings/bindings/earnings_binding.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/earnings/views/transaction_history_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/order_detail/bindings/order_detail_binding.dart';
import '../modules/order_detail/views/order_detail_view.dart';
import '../modules/order_history/bindings/order_history_binding.dart';
import '../modules/order_history/views/order_history_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/bindings/account_details_binding.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/change_contact_view.dart';
import '../modules/profile/views/account_details_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/account_settings_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/active_delivery/bindings/active_delivery_binding.dart';
import '../modules/active_delivery/bindings/delivery_verification_binding.dart';
import '../modules/active_delivery/views/active_delivery_view.dart';
import '../modules/active_delivery/views/order_pickup_view.dart';
import '../modules/active_delivery/views/delivery_verification_view.dart';
import '../modules/earnings/views/payout_receipt_view.dart';
import '../modules/settings/bindings/legal_binding.dart';
import '../modules/settings/views/legal_view.dart';
import '../modules/support/bindings/support_binding.dart';
import '../modules/support/views/support_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.registerSteps,
      page: () => const RegisterStepsView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.verificationPending,
      page: () => const VerificationPendingView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        ConnectivityMiddleware(),
        NotificationMiddleware(),
      ],
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: AppRoutes.orderHistory,
    //   page: () => const OrderHistoryView(),
    //   binding: OrderHistoryBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),
    GetPage(
      name: AppRoutes.earnings,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.transactionHistory,
      page: () => const TransactionHistoryView(),
      binding: EarningsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const AccountSettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.changePhone,
      page: () => const ChangeContactView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.changeEmail,
      page: () => const ChangeContactView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.accountDetails,
      page: () => const AccountDetailsView(),
      binding: AccountDetailsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.activeDelivery,
      page: () => const ActiveDeliveryView(),
      binding: ActiveDeliveryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderPickup,
      page: () => const OrderPickupView(),
      binding: ActiveDeliveryBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.deliveryVerification,
      page: () => const DeliveryVerificationView(),
      binding: DeliveryVerificationBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.payoutReceipt,
      page: () => const PayoutReceiptView(),
      binding: EarningsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const LegalView(),
      binding: LegalBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const LegalView(),
      binding: LegalBinding(),
    ),
  ];
}
