import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/status_badge.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Obx(() {
        final order = controller.order.value;
        if (controller.hasError.value && order == null) {
          return Scaffold(
            backgroundColor: AppColors.darkBackground,
            appBar: AppBar(title: const Text('Order Detail')),
            body: ErrorStateWidget.server(onRetry: () => Get.back()),
          );
        }
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.darkBackground,
            appBar: AppBar(title: const Text('Order Detail')),
            body: const Center(child: AppLoader()),
          );
        }
        return _OrderDetailContent(order: order, controller: controller);
      }),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  final OrderModel order;
  final OrderDetailController controller;

  const _OrderDetailContent({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(order),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _OrderProgressTracker(status: order.status),
                _MapPlaceholder(order: order),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  child: Column(
                    children: [
                      _RouteCard(order: order),
                      const SizedBox(height: AppDimensions.gapMd),
                      _CustomerCard(order: order, onCallTap: controller.callCustomer),
                      if (order.items.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.gapMd),
                        _ItemsCard(order: order),
                      ],
                      const SizedBox(height: AppDimensions.gapMd),
                      _EarningsCard(order: order),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(order: order, controller: controller),
    );
  }

  SliverAppBar _buildAppBar(OrderModel order) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.textPrimary,
      title: Text('#${order.orderId}', style: AppTextStyles.h6SemiBold),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.paddingMd),
          child: StatusBadge(status: order.status, isLarge: true),
        ),
      ],
    );
  }
}

// ─── Order progress tracker ───────────────────────────────────────────────────

class _OrderProgressTracker extends StatelessWidget {
  final String status;

  const _OrderProgressTracker({required this.status});

  static const _steps = ['new', 'accepted', 'picked_up', 'delivered'];
  static const _labels = ['Pending', 'Accepted', 'Picked Up', 'Delivered'];
  static const _icons = [
    Icons.receipt_long_rounded,
    Icons.check_circle_rounded,
    Icons.inventory_rounded,
    Icons.local_shipping_rounded,
  ];

  int get _currentStep {
    switch (status) {
      case 'accepted':     return 1;
      case 'picked_up':    return 2;
      case 'delivered':    return 3;
      case 'cancelled':    return -1;
      default:             return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        margin: const EdgeInsets.all(AppDimensions.paddingMd),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.cardDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.statusCancelled),
            const SizedBox(width: AppDimensions.gapSm),
            Text('Order Cancelled',
                style: AppTextStyles.pSmallSemiBold
                    .copyWith(color: AppColors.statusCancelled)),
          ],
        ),
      );
    }

    final current = _currentStep;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        0,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.cardDark,
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone    = i < current;
          final isActive  = i == current;
          final isFuture  = i > current;
          final color = isDone || isActive ? AppColors.primary : AppColors.navyMuted400;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? AppColors.primary : AppColors.darkBorder,
                        ),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.darkSurfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFuture ? AppColors.darkBorder : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(_icons[i],
                          size: AppDimensions.iconXs,
                          color: isActive ? AppColors.white : color),
                    ),
                    if (i < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? AppColors.primary : AppColors.darkBorder,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.gapXs),
                Text(
                  _labels[i],
                  style: AppTextStyles.pXSmall.copyWith(
                    color: isFuture ? AppColors.navyMuted400 : color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Map placeholder ──────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  final OrderModel order;

  const _MapPlaceholder({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.mapHeight,
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: AppDecorations.cardDark.borderRadius,
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Route line visual
          CustomPaint(
            size: const Size(double.infinity, AppDimensions.mapHeight),
            painter: _RoutePainter(),
          ),
          // Pickup marker
          Positioned(
            top: AppDimensions.sp32,
            left: AppDimensions.sp40,
            child: _MapPin(color: AppColors.primary, icon: Icons.trip_origin),
          ),
          // Delivery marker
          Positioned(
            bottom: AppDimensions.sp32,
            right: AppDimensions.sp40,
            child: _MapPin(color: AppColors.error, icon: Icons.location_on),
          ),
          // Overlay info
          Positioned(
            bottom: AppDimensions.gapSm,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.gapXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceElevated.withValues(alpha: 0.9),
                  borderRadius: AppDecorations.cardDark.borderRadius,
                  border: Border.all(color: AppColors.darkBorder, width: 0.5),
                ),
                child: Text(
                  '${order.distanceKm.toStringAsFixed(1)} km  •  ~${order.estimatedMinutes} min',
                  style: AppTextStyles.pXSmallSemiBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sp32,
      height: AppDimensions.sp32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: AppDimensions.sp8,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: AppDimensions.iconXs),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(56, 48)
      ..cubicTo(size.width * 0.3, size.height * 0.2, size.width * 0.7,
          size.height * 0.8, size.width - 56, size.height - 48);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Route card (pickup + delivery) ──────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  final OrderModel order;

  const _RouteCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final pickup   = order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : order.pickupAddress;
    final delivery = order.deliveryShortAddress.isNotEmpty ? order.deliveryShortAddress : order.deliveryAddress;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.cardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Route Details'),
          const SizedBox(height: AppDimensions.gapLg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: AppDimensions.sp16,
                    height: AppDimensions.sp16,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: AppDimensions.sp32,
                    color: AppColors.darkBorder,
                  ),
                  Container(
                    width: AppDimensions.sp16,
                    height: AppDimensions.sp16,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppDecorations.cardDark.borderRadius,
                    ),
                    child: const Icon(Icons.location_on,
                        color: AppColors.white, size: 10),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationLine(
                      label: 'Pickup',
                      address: pickup,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppDimensions.sp32),
                    _LocationLine(
                      label: 'Delivery',
                      address: delivery,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  final String label;
  final String address;
  final Color color;

  const _LocationLine({
    required this.label,
    required this.address,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimensions.gapXs),
        Text(address,
            style: AppTextStyles.pSmallSemiBold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ─── Customer card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCallTap;

  const _CustomerCard({required this.order, required this.onCallTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.cardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Customer'),
          const SizedBox(height: AppDimensions.gapLg),
          Row(
            children: [
              Container(
                width: AppDimensions.avatarMd,
                height: AppDimensions.avatarMd,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    order.customerName.isNotEmpty
                        ? order.customerName[0].toUpperCase()
                        : 'C',
                    style: AppTextStyles.h5SemiBold
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.customerName, style: AppTextStyles.pMediumSemiBold),
                    const SizedBox(height: AppDimensions.gapXs),
                    Text('+91 ${order.customerPhone}',
                        style: AppTextStyles.pSmallRegular
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCallTap,
                child: Container(
                  width: AppDimensions.sp40,
                  height: AppDimensions.sp40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.call_rounded,
                      color: AppColors.primary, size: AppDimensions.iconSm),
                ),
              ),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.gapMd),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSm),
              decoration: AppDecorations.surfaceElevatedDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: AppDimensions.iconXs,
                      color: AppColors.navyMuted300),
                  const SizedBox(width: AppDimensions.gapXs),
                  Expanded(
                    child: Text(order.notes!,
                        style: AppTextStyles.pXSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Items card ───────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final OrderModel order;

  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.cardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Order Items (${order.items.length})'),
          const SizedBox(height: AppDimensions.gapMd),
          ...order.items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == order.items.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: AppDimensions.sp24,
                      height: AppDimensions.sp24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppDecorations.cardDark.borderRadius,
                      ),
                      child: Center(
                        child: Text('${item.quantity}',
                            style: AppTextStyles.pXSmallSemiBold
                                .copyWith(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.gapSm),
                    Expanded(
                      child: Text(item.name,
                          style: AppTextStyles.pSmallRegular),
                    ),
                    Text(AppUtils.formatCurrency(item.price * item.quantity),
                        style: AppTextStyles.pSmallSemiBold
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.gapSm),
                    child: Divider(
                        color: AppColors.darkBorder, height: 0, thickness: 0.5),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Earnings card ────────────────────────────────────────────────────────────

class _EarningsCard extends StatelessWidget {
  final OrderModel order;

  const _EarningsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.gradientCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Earnings',
                    style: AppTextStyles.pXSmall
                        .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                const SizedBox(height: AppDimensions.gapXs),
                Text(
                  AppUtils.formatCurrency(order.earnings),
                  style: AppTextStyles.h4SemiBold
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _EarningMeta(
                icon: Icons.route_rounded,
                label: '${order.distanceKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(height: AppDimensions.gapXs),
              _EarningMeta(
                icon: Icons.access_time_rounded,
                label: '~${order.estimatedMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EarningMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: AppDimensions.iconXs,
            color: AppColors.white.withValues(alpha: 0.8)),
        const SizedBox(width: AppDimensions.gapXs),
        Text(label,
            style: AppTextStyles.pXSmall
                .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
      ],
    );
  }
}

// ─── Action bar ───────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final OrderModel order;
  final OrderDetailController controller;

  const _ActionBar({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.gapMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AppLoader());
        }
        return _buildActions();
      }),
    );
  }

  Widget _buildActions() {
    if (order.isNew) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Reject',
              variant: AppButtonVariant.danger,
              onPressed: controller.rejectOrder,
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Accept Order',
              onPressed: controller.acceptOrder,
            ),
          ),
        ],
      );
    }

    if (order.isAccepted) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Navigate',
              variant: AppButtonVariant.outline,
              prefixIcon: const Icon(Icons.navigation_rounded,
                  size: 18, color: AppColors.primary),
              onPressed: controller.openNavigation,
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Confirm Pickup',
              prefixIcon: const Icon(Icons.inventory_rounded,
                  size: 18, color: AppColors.white),
              onPressed: controller.confirmPickup,
            ),
          ),
        ],
      );
    }

    if (order.isPickedUp) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Navigate',
              variant: AppButtonVariant.outline,
              prefixIcon: const Icon(Icons.navigation_rounded,
                  size: 18, color: AppColors.primary),
              onPressed: controller.openNavigation,
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Confirm Delivery',
              prefixIcon: const Icon(Icons.local_shipping_rounded,
                  size: 18, color: AppColors.white),
              onPressed: controller.confirmDelivery,
            ),
          ),
        ],
      );
    }

    if (order.isDelivered) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSm),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: AppDecorations.cardDark.borderRadius,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: AppDimensions.iconSm),
            const SizedBox(width: AppDimensions.gapSm),
            Text('Order Delivered Successfully',
                style: AppTextStyles.pSmallSemiBold
                    .copyWith(color: AppColors.success)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
