// ─── Flutter & packages ────────────────────────────────────────────────────
export 'package:flutter/material.dart';
export 'package:get/get.dart' hide FormData, MultipartFile, Response;
export 'package:get_storage/get_storage.dart';
export 'package:dio/dio.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:shimmer/shimmer.dart';

// ─── Config ────────────────────────────────────────────────────────────────
export 'app/config/app_config.dart';

// ─── Constants ─────────────────────────────────────────────────────────────
export 'app/constants/app_constants.dart';
export 'app/constants/storage_keys.dart';

// ─── Base ──────────────────────────────────────────────────────────────────
export 'app/base/base_controller.dart';

// ─── Themes ────────────────────────────────────────────────────────────────
export 'app/themes/app_colors.dart';
export 'app/themes/app_dimensions.dart';
export 'app/themes/app_text_styles.dart';
export 'app/themes/app_theme.dart';
export 'app/themes/app_radius.dart';
export 'app/themes/app_shadows.dart';
export 'app/themes/app_decorations.dart';

// ─── Utils ─────────────────────────────────────────────────────────────────
export 'app/utils/responsive.dart';
export 'app/utils/app_utils.dart';
export 'app/utils/app_logger.dart';

// ─── Network ───────────────────────────────────────────────────────────────
export 'app/network/dio_client.dart';
export 'app/network/api_endpoints.dart';

// ─── Services ──────────────────────────────────────────────────────────────
export 'app/services/storage_service.dart';
export 'app/services/auth_service.dart';
export 'app/services/connectivity_service.dart';
export 'app/services/notification_service.dart';

// ─── Routes ────────────────────────────────────────────────────────────────
export 'app/routes/app_routes.dart';
export 'app/routes/app_pages.dart';

// ─── Bindings ──────────────────────────────────────────────────────────────
export 'app/bindings/initial_binding.dart';

// ─── Middlewares ───────────────────────────────────────────────────────────
export 'app/middleware/auth_middleware.dart';
export 'app/middleware/connectivity_middleware.dart';
export 'app/middleware/notification_middleware.dart';

// ─── Widgets ───────────────────────────────────────────────────────────────
export 'app/widgets/app_button.dart';
export 'app/widgets/app_text_field.dart';
export 'app/widgets/app_loader.dart';
export 'app/widgets/connectivity_widget.dart';
export 'app/widgets/empty_state_widget.dart';
export 'app/widgets/error_state_widget.dart';
export 'app/widgets/shimmer_widgets.dart';
export 'app/widgets/pagination_list.dart';
export 'app/widgets/status_badge.dart';
export 'app/widgets/info_row.dart';
export 'app/widgets/section_header.dart';

// ─── Data models ───────────────────────────────────────────────────────────
export 'data/models/api_response.dart';
export 'data/models/user_model.dart';
export 'data/models/order_model.dart';
export 'data/models/notification_model.dart';
export 'data/models/transaction_model.dart';

// ─── Repositories ──────────────────────────────────────────────────────────
export 'data/repositories/auth_repository.dart';
export 'data/repositories/order_repository.dart';
export 'data/repositories/earnings_repository.dart';
export 'data/repositories/notification_repository.dart';

// ─── Modules — Splash ─────────────────────────────────────────────────────
export 'app/modules/splash/bindings/splash_binding.dart';
export 'app/modules/splash/controllers/splash_controller.dart';
export 'app/modules/splash/views/splash_view.dart';

// ─── Modules — Onboarding ─────────────────────────────────────────────────
export 'app/modules/onboarding/bindings/onboarding_binding.dart';
export 'app/modules/onboarding/controllers/onboarding_controller.dart';
export 'app/modules/onboarding/views/onboarding_view.dart';

// ─── Modules — Auth ───────────────────────────────────────────────────────
export 'app/modules/auth/bindings/auth_binding.dart';
export 'app/modules/auth/bindings/register_binding.dart';
export 'app/modules/auth/controllers/auth_controller.dart';
export 'app/modules/auth/controllers/register_controller.dart';
export 'app/modules/auth/views/login_view.dart';
export 'app/modules/auth/views/otp_view.dart';
export 'app/modules/auth/views/register_view.dart';
export 'app/modules/auth/views/register_steps_view.dart';
export 'app/modules/auth/views/verification_pending_view.dart';

// ─── Modules — Dashboard ──────────────────────────────────────────────────
export 'app/modules/dashboard/bindings/dashboard_binding.dart';
export 'app/modules/dashboard/controllers/dashboard_controller.dart';
export 'app/modules/dashboard/views/dashboard_view.dart';

// ─── Modules — Order Detail ───────────────────────────────────────────────
export 'app/modules/order_detail/bindings/order_detail_binding.dart';
export 'app/modules/order_detail/controllers/order_detail_controller.dart';
export 'app/modules/order_detail/views/order_detail_view.dart';

// ─── Modules — Order History ──────────────────────────────────────────────
export 'app/modules/order_history/bindings/order_history_binding.dart';
export 'app/modules/order_history/controllers/order_history_controller.dart';
export 'app/modules/order_history/views/order_history_view.dart';

// ─── Modules — Earnings ───────────────────────────────────────────────────
export 'app/modules/earnings/bindings/earnings_binding.dart';
export 'app/modules/earnings/controllers/earnings_controller.dart';
export 'app/modules/earnings/views/earnings_view.dart';

// ─── Modules — Notifications ──────────────────────────────────────────────
export 'app/modules/notifications/bindings/notifications_binding.dart';
export 'app/modules/notifications/controllers/notifications_controller.dart';
export 'app/modules/notifications/views/notifications_view.dart';

// ─── Modules — Profile ────────────────────────────────────────────────────
export 'app/modules/profile/bindings/profile_binding.dart';
export 'app/modules/profile/controllers/profile_controller.dart';
export 'app/modules/profile/views/profile_view.dart';
export 'app/modules/profile/views/edit_profile_view.dart';

// ─── Modules — Settings ───────────────────────────────────────────────────
export 'app/modules/settings/bindings/settings_binding.dart';
export 'app/modules/settings/controllers/settings_controller.dart';
export 'app/modules/settings/views/settings_view.dart';
