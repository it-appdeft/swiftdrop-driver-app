import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyStateWidget.orders({VoidCallback? onRefresh}) =>
      EmptyStateWidget(
        title: 'No active orders',
        subtitle: 'New delivery orders will appear here',
        icon: Icons.delivery_dining_rounded,
        actionLabel: onRefresh != null ? 'Refresh' : null,
        onAction: onRefresh,
      );

  factory EmptyStateWidget.history() => const EmptyStateWidget(
        title: 'No delivery history',
        subtitle: 'Completed orders will show up here',
        icon: Icons.history_rounded,
      );

  factory EmptyStateWidget.notifications() => const EmptyStateWidget(
        title: 'No notifications',
        subtitle: "You're all caught up!",
        icon: Icons.notifications_none_rounded,
      );

  factory EmptyStateWidget.search() => const EmptyStateWidget(
        title: 'No results found',
        subtitle: 'Try different search terms',
        icon: Icons.search_off_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.sp24),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.gapSm),
              Text(
                subtitle!,
                style: AppTextStyles.pSmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.sp24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
