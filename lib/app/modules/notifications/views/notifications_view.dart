import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/notification_model.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    AppStrings.markAllRead,
                    style: AppTextStyles.pXSmall
                        .copyWith(color: AppColors.primary),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) => const ShimmerListItem(),
          );
        }

        if (controller.notifications.isEmpty) {
          return EmptyStateWidget.notifications();
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingXl),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              return _NotificationCard(
                notification: notif,
                onTap: () => controller.markAsRead(notif.id),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  Color get _typeColor {
    switch (notification.type) {
      case 'payment':     return AppColors.success;
      case 'order':       return AppColors.statusNew;
      case 'announcement': return AppColors.warning;
      default:            return AppColors.navyMuted400;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case 'payment':     return Icons.account_balance_wallet_rounded;
      case 'order':       return Icons.local_shipping_rounded;
      case 'announcement': return Icons.campaign_rounded;
      default:            return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapXs,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.darkSurface
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: AppDecorations.cardDark.borderRadius,
          border: Border.all(
            color: notification.isRead
                ? AppColors.darkBorder
                : AppColors.primary.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppDimensions.avatarSm + 8,
              height: AppDimensions.avatarSm + 8,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(_typeIcon, color: _typeColor, size: AppDimensions.iconSm),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: notification.isRead
                              ? AppTextStyles.pSmallSemiBold
                              : AppTextStyles.pSmallSemiBold
                                  .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.gapXs),
                  Text(
                    notification.body,
                    style: AppTextStyles.pXSmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.gapSm),
                  Text(
                    AppUtils.timeAgo(notification.createdAt),
                    style: AppTextStyles.pXSmall
                        .copyWith(color: AppColors.navyMuted400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
