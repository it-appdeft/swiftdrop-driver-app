import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _FilterChips(controller: controller),
          Expanded(child: _HistoryList(controller: controller)),
        ],
      ),
    );
  }
}

// ─── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final OrderHistoryController controller;

  const _FilterChips({required this.controller});

  static const _filters = [
    ('all', 'All'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.gapSm,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
      ),
      child: Obx(
        () => Row(
          children: _filters.map((f) {
            final isSelected = controller.selectedFilter.value == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.gapSm),
              child: GestureDetector(
                onTap: () => controller.setFilter(f.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMd,
                    vertical: AppDimensions.gapSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.darkSurfaceElevated,
                    borderRadius: AppRadius.chipRadius,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.darkBorder,
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: AppTextStyles.pXSmallSemiBold.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── History list ─────────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  final OrderHistoryController controller;

  const _HistoryList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) => const ShimmerOrderCard(),
        );
      }

      if (controller.hasError.value && controller.orders.isEmpty) {
        return ErrorStateWidget.server(onRetry: controller.loadHistory);
      }

      if (controller.orders.isEmpty) {
        return EmptyStateWidget.history();
      }

      return RefreshIndicator(
        onRefresh: controller.loadHistory,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingXl),
          itemCount: controller.orders.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.orders.length) {
              return _LoadMoreFooter(controller: controller);
            }
            return _HistoryCard(
              order: controller.orders[index],
              onTap: () => controller.viewDetail(controller.orders[index]),
            );
          },
        ),
      );
    });
  }
}

// ─── History card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _HistoryCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapXs,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.orderCardDark,
        child: Row(
          children: [
            // Left: status icon
            Container(
              width: AppDimensions.avatarSm + 8,
              height: AppDimensions.avatarSm + 8,
              decoration: BoxDecoration(
                color: AppUtils.orderStatusColor(order.status)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                order.isDelivered
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: AppUtils.orderStatusColor(order.status),
                size: AppDimensions.iconSm,
              ),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            // Middle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${order.orderId}',
                          style: AppTextStyles.pSmallSemiBold),
                      const Spacer(),
                      StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.gapXs),
                  Text(
                    order.deliveryShortAddress.isNotEmpty
                        ? order.deliveryShortAddress
                        : order.deliveryAddress,
                    style: AppTextStyles.pXSmall
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.gapXs),
                  Row(
                    children: [
                      Text(
                        AppUtils.formatDateTime(order.createdAt),
                        style: AppTextStyles.pXSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        AppUtils.formatCurrency(order.earnings),
                        style: AppTextStyles.pSmallSemiBold
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.gapSm),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.navyMuted400, size: AppDimensions.iconSm),
          ],
        ),
      ),
    );
  }
}

// ─── Load more footer ─────────────────────────────────────────────────────────

class _LoadMoreFooter extends StatelessWidget {
  final OrderHistoryController controller;

  const _LoadMoreFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
          child: Center(child: AppLoader()),
        );
      }
      if (!controller.hasMore.value) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Center(
            child: Text('All deliveries loaded',
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
        );
      }
      return GestureDetector(
        onTap: controller.loadMore,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Center(
            child: Text('Load more',
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.primary)),
          ),
        ),
      );
    });
  }
}
