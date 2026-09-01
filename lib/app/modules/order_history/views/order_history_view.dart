import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/order_request_card.dart';
import '../../../widgets/status_info_card.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/order_history_controller.dart';

// Tab switcher reactive state — file-scoped so the widget stays stateless
final _selectedDeliveryTab = 0.obs;

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashController = Get.find<DashboardController>();
    final historyController = Get.find<OrderHistoryController>();
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMd,
                AppDimensions.paddingMd,
                AppDimensions.paddingMd,
                0,
              ),
              child: _buildHeader(dashController),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    historyController.loadHistory(),
                    dashController.loadDeliveryRequests(),
                    dashController.fetchDashboardData(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingMd,
                    AppDimensions.gapLg,
                    AppDimensions.paddingMd,
                    AppDimensions.paddingXl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(dashController),
                      const SizedBox(height: AppDimensions.gapLg),
                      _buildTabSwitcher(dashController, historyController),
                      const SizedBox(height: AppDimensions.gapLg),
                      Obx(() => _selectedDeliveryTab.value == 0
                          ? _buildAvailableSection(dashController)
                          : _buildHistorySection(historyController)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.delivery,
            style: AppTextStyles.build(
              size: 28,
              height: 36,
              weight: FontWeight.w600,
              color: AppColors.navy900,
            ),
          ),
        ),
        Obx(() {
          final isOnline = controller.isOnline.value;
          final isToggling = controller.isTogglingOnline.value;
          return GestureDetector(
            onTap: isToggling ? null : () => controller.toggleOnlineStatus(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.paddingXs,
              ),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.primaryLight500.withValues(alpha: 0.5)
                    : AppColors.logoutBg,
                border: Border.all(
                  color: isOnline ? AppColors.primary : AppColors.otpSubtitle,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.primary : AppColors.otpSubtitle,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.gapSm),
                  Text(
                    isOnline ? AppStrings.online : AppStrings.offline,
                    style: AppTextStyles.build(
                      size: 12,
                      height: 16,
                      weight: FontWeight.w500,
                      color: isOnline ? AppColors.primaryDarkest : AppColors.otpSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsRow(DashboardController controller) {
    return Obx(() {
      final deliveriesCount = controller.totalDeliveries.value > 0
          ? '${controller.totalDeliveries.value}'
          : '${controller.user?.totalDeliveries ?? 0}';

      final minutes = controller.timeOnlineMinutes.value;
      final timeFormatted = minutes > 0
          ? '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m'
          : '0m';

      return Row(
        children: [
          _StatCard(
            icon: Icons.local_shipping_outlined,
            label: AppStrings.todaysDeliveries,
            value: deliveriesCount,
          ),
          const SizedBox(width: AppDimensions.gapLg),
          Expanded(
            child: _StatCard(
              icon: Icons.access_time_outlined,
              label: AppStrings.timeOnline,
              value: timeFormatted,
              isExpanded: true,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabSwitcher(DashboardController controller, OrderHistoryController historyController) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXs),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _TabItem(
                label: AppStrings.available,
                isSelected: _selectedDeliveryTab.value == 0,
                onTap: () {
                  _selectedDeliveryTab.value = 0;
                  if (controller.approvalStatus.value.toLowerCase() == 'approved' && controller.isOnline.value) {
                    controller.loadDeliveryRequests();
                  }
                },
              ),
            ),
            const SizedBox(width: AppDimensions.gapSm),
            Expanded(
              child: _TabItem(
                label: AppStrings.history,
                isSelected: _selectedDeliveryTab.value == 1,
                onTap: () {
                  _selectedDeliveryTab.value = 1;
                  historyController.loadHistory();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSection(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final count = controller.activeOrders.length;
          final showBadge = controller.isOnline.value &&
              !controller.isOnDelivery.value &&
              count > 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.availableOpportunities,
                style: AppTextStyles.build(
                  size: 18,
                  height: 28,
                  weight: FontWeight.w500,
                  color: AppColors.navy900,
                ),
              ),
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy900,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                  child: Text(
                    '$count ${AppStrings.newBadge}',
                    style: AppTextStyles.build(
                      size: 12,
                      height: 16,
                      weight: FontWeight.w600,
                      color: AppColors.infoBoxBg,
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: AppDimensions.gapLg),
        Obx(() {
          if (!controller.isOnline.value) {
            return _buildDashedStatusCard(
              StatusInfoType.offline,
              onButtonPressed: () => controller.toggleOnlineStatus(),
            );
          }
          if (controller.isOnDelivery.value) {
            return _buildDashedStatusCard(
              StatusInfoType.onDelivery,
              onButtonPressed: () {
                if (controller.currentActiveOrder.value != null) {
                  Get.toNamed(
                    AppRoutes.activeDelivery,
                    arguments: controller.currentActiveOrder.value,
                  );
                }
              },
            );
          }
          if (controller.activeOrders.isEmpty) {
            return _buildDashedStatusCard(StatusInfoType.waitingForDeliveries);
          }
          return Column(
            children: controller.activeOrders.map((order) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.gapLg),
                child: OrderRequestCard(
                  order: order,
                  showActions: true,
                  countdownSeconds: order.isNew
                      ? controller.deliveryRequestTimeoutSeconds.value
                      : null,
                  onAccept: () => controller.acceptOrder(order.id),
                  onReject: () => controller.rejectOrder(order.id),
                  onTimeout: () => controller.onOrderTimeout(order.id),
                  onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildHistorySection(OrderHistoryController controller) {
    return Obx(() {
      if (controller.orders.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.deliveryHistory,
              style: AppTextStyles.build(
                size: 18,
                height: 28,
                weight: FontWeight.w500,
                color: AppColors.navy900,
              ),
            ),
            const SizedBox(height: AppDimensions.gapLg),
            _buildDashedStatusCard(StatusInfoType.noHistory),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.deliveryHistory,
            style: AppTextStyles.build(
              size: 18,
              height: 28,
              weight: FontWeight.w500,
              color: AppColors.navy900,
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),
          ...controller.orders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.gapLg),
                child: _HistoryCard(order: order),
              )),
        ],
      );
    });
  }

  Widget _buildDashedStatusCard(StatusInfoType type, {VoidCallback? onButtonPressed}) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.stroke,
        strokeWidth: 2,
        dashWidth: 6,
        dashSpace: 4,
        radius: AppDimensions.radiusMd,
      ),
      child: StatusInfoCard(
        type: type,
        minHeight: type == StatusInfoType.onDelivery ? 180 : 220,
        onButtonPressed: onButtonPressed,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isExpanded = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(141, 225, 190, 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppDimensions.iconMd),
          ),
          const SizedBox(width: AppDimensions.gapSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.build(
                  size: 12,
                  height: 16,
                  color: AppColors.navyMuted200,
                ),
              ),
              const SizedBox(height: AppDimensions.gapXs),
              Text(
                value,
                style: AppTextStyles.build(
                  size: 16,
                  height: 24,
                  weight: FontWeight.w500,
                  color: AppColors.navy500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab switcher item
// ─────────────────────────────────────────────────────────────────────────────

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 4)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.build(
              size: 14,
              height: 20,
              weight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.white : AppColors.navyMuted200,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Card
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.order,
  });

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final title = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : (order.pickupShortAddress.isNotEmpty
            ? order.pickupShortAddress
            : (order.pickupAddress.isNotEmpty ? order.pickupAddress : ''));

    final miles = order.distanceMiles > 0
        ? order.distanceMiles
        : (order.distanceKm > 0 ? order.distanceKm * 0.621371 : 0.0);
    final duration = order.estimatedMinutes;
    final hasMetrics = duration > 0 || miles > 0;

    String infoText = '';
    if (duration > 0 && miles > 0) {
      infoText = '${duration}min (${miles.toStringAsFixed(1)}Mi) total';
    } else if (duration > 0) {
      infoText = '${duration}min total';
    } else if (miles > 0) {
      infoText = '${miles.toStringAsFixed(1)}Mi total';
    }

    final symbol = order.currency == 'GBP' ? '£' : (order.currency == 'USD' ? '\$' : '£');

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(AppRoutes.orderDetail, arguments: order);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: AppTextStyles.pSmall.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  if (order.displayOrderId.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          AppStrings.deliveryId,
                          style: AppTextStyles.pSmall.copyWith(
                            color: AppColors.navyMuted200,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.gapXs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF868AA5),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            order.displayOrderId,
                            style: AppTextStyles.build(
                              size: 10,
                              height: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '+ ${AppUtils.formatCurrency(order.earnings, symbol: symbol)}',
                    style: AppTextStyles.build(
                      size: 20,
                      height: 28,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Helvetica Neue',
                    ),
                  ),
                ],
              ),
            ),
            if (hasMetrics) ...[
              const SizedBox(width: AppDimensions.gapMd),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0x4DFFE083),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: Color(0xFFB7950B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      infoText,
                      style: AppTextStyles.build(
                        size: 11,
                        weight: FontWeight.w500,
                        color: const Color(0xFFB7950B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromLTRBR(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth / 2,
      size.height - strokeWidth / 2,
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rRect);

    final Path dashedPath = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.radius != radius;
  }
}
