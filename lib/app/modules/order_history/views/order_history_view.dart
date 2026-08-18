import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../export.dart';
import '../../../widgets/order_request_card.dart';
import '../../../widgets/status_info_card.dart';

// Tab switcher reactive state — file-scoped so the widget stays stateless
final _selectedDeliveryTab = 0.obs;
// Mock online status for UI check
final _isOnlineMock = true.obs;
// Mock active delivery status
final _isOnDeliveryMock = false.obs;

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: _buildHeader(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Get.find<OrderHistoryController>().loadHistory(),
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
                      _buildStatsRow(),
                      const SizedBox(height: AppDimensions.gapLg),
                      _buildTabSwitcher(),
                      const SizedBox(height: AppDimensions.gapLg),
                      Obx(() => _selectedDeliveryTab.value == 0
                          ? _buildAvailableSection()
                          : _buildHistorySection()),
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

  Widget _buildHeader() {
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
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSm,
            vertical: AppDimensions.paddingXs,
          ),
          decoration: BoxDecoration(
            color: _isOnlineMock.value 
                ? AppColors.primaryLight500.withValues(alpha: 0.5)
                : AppColors.logoutBg,
            border: Border.all(color: _isOnlineMock.value ? AppColors.primary : AppColors.otpSubtitle),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _isOnlineMock.value ? AppColors.primary : AppColors.otpSubtitle,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.gapSm),
              Text(
                _isOnlineMock.value ? AppStrings.online : AppStrings.offline,
                style: AppTextStyles.build(
                  size: 12,
                  height: 16,
                  color: _isOnlineMock.value ? AppColors.primaryDarkest : AppColors.otpSubtitle,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          icon: Icons.local_shipping_outlined,
          label: AppStrings.todaysDeliveries,
          value: '12',
        ),
        const SizedBox(width: AppDimensions.gapLg),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_outlined,
            label: AppStrings.timeOnline,
            value: '1h 00m',
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
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
                onTap: () => _selectedDeliveryTab.value = 0,
              ),
            ),
            const SizedBox(width: AppDimensions.gapSm),
            Expanded(
              child: _TabItem(
                label: AppStrings.history,
                isSelected: _selectedDeliveryTab.value == 1,
                onTap: () => _selectedDeliveryTab.value = 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSection() {
    final controller = Get.find<DashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(AppStrings.availableOpportunities),
        const SizedBox(height: AppDimensions.gapLg),
        Obx(() {
          if (!controller.isOnline.value) {
            return _buildDashedStatusCard(StatusInfoType.offline);
          }
          if (controller.isOnDelivery.value) {
            return _buildDashedStatusCard(StatusInfoType.onDelivery);
          }
          return _buildOrderCards();
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.build(
            size: 18,
            height: 28,
            weight: FontWeight.w500,
            color: AppColors.navy900,
          ),
        ),
        if (_selectedDeliveryTab.value == 0 && _isOnlineMock.value && !_isOnDeliveryMock.value)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.navy900,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
            child: Text(
              '3 ${AppStrings.newBadge}',
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
  }

  Widget _buildOrderCards() {
    // Mock data for OrderRequestCard
    final mockOrders = [
      OrderModel(
        id: '1',
        orderId: 'CON13420',
        earnings: 16.00,
        distanceKm: 4.2,
        estimatedMinutes: 24,
        pickupAddress: '742 Evergreen Terrace',
        pickupShortAddress: 'Urban Grind Coffee House',
        deliveryAddress: 'Grand Central Station, Gate 4',
        deliveryShortAddress: 'Grand Central Station, Gate 4',
        status: 'new',
        customerName: 'Homer Simpson',
        customerPhone: '555-0123',
        pickupLat: 51.5074,
        pickupLng: -0.1278,
        deliveryLat: 51.5084,
        deliveryLng: -0.1288,
        createdAt: DateTime.now(),
      ),
      OrderModel(
        id: '2',
        orderId: 'CON13421',
        earnings: 20.00,
        distanceKm: 4.2,
        estimatedMinutes: 24,
        pickupAddress: '742 Evergreen Terrace',
        pickupShortAddress: 'Urban Grind Coffee House',
        deliveryAddress: 'Grand Central Station, Gate 4',
        deliveryShortAddress: 'Grand Central Station, Gate 4',
        status: 'new',
        customerName: 'Marge Simpson',
        customerPhone: '555-0124',
        pickupLat: 51.5074,
        pickupLng: -0.1278,
        deliveryLat: 51.5084,
        deliveryLng: -0.1288,
        createdAt: DateTime.now(),
      ),
      OrderModel(
        id: '3',
        orderId: 'CON13422',
        earnings: 32.00,
        distanceKm: 8.2,
        estimatedMinutes: 45,
        pickupAddress: '742 Evergreen Terrace',
        pickupShortAddress: 'Urban Grind Coffee House',
        deliveryAddress: 'Grand Central Station, Gate 4',
        deliveryShortAddress: 'Grand Central Station, Gate 4',
        status: 'new',
        customerName: 'Bart Simpson',
        customerPhone: '555-0125',
        pickupLat: 51.5074,
        pickupLng: -0.1278,
        deliveryLat: 51.5084,
        deliveryLng: -0.1288,
        createdAt: DateTime.now(),
      ),
    ];

    return Column(
      children: [
        OrderRequestCard(
          order: mockOrders[0],
          countdownSeconds: 20,
        ),
        const SizedBox(height: AppDimensions.gapLg),
        OrderRequestCard(
          order: mockOrders[1],
          countdownSeconds: 30,
        ),
        const SizedBox(height: AppDimensions.gapLg),
        OrderRequestCard(
          order: mockOrders[2],
          countdownSeconds: 30,
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final mockHistory = [
      (name: 'Urban Grind Coffee House', id: 'CON13420', earnings: 16.00, info: '24min (2.2MI) total'),
      (name: 'Sarah Cafe', id: 'CON13420', earnings: 20.00, info: '30min (3.2MI) total'),
      (name: 'MacDonalds', id: 'CON13420', earnings: 32.00, info: '45min (6.1MI) total'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(AppStrings.deliveryHistory),
        const SizedBox(height: AppDimensions.gapLg),
        ...mockHistory.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.gapLg),
              child: _HistoryCard(
                name: item.name,
                deliveryId: item.id,
                earnings: item.earnings,
                info: item.info,
              ),
            )),
      ],
    );
  }

  Widget _buildDashedStatusCard(StatusInfoType type) {
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
        height: type == StatusInfoType.onDelivery ? 200 : 260,
        onButtonPressed: type == StatusInfoType.offline
            ? () => _isOnlineMock.value = true
            : null,
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
    required this.name,
    required this.deliveryId,
    required this.earnings,
    required this.info,
  });

  final String name;
  final String deliveryId;
  final double earnings;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Get.toNamed(
            AppRoutes.orderDetail,
            arguments: OrderModel(
              id: deliveryId,
              orderId: deliveryId,
              earnings: earnings,
              distanceKm: 2.2,
              estimatedMinutes: 24,
              pickupAddress: '742 Evergreen Terrace',
              pickupShortAddress: name,
              deliveryAddress: 'Grand Central Station, Gate 4',
              deliveryShortAddress: 'Grand Central Station, Gate 4',
              status: 'delivered',
              customerName: 'Customer Name',
              customerPhone: '555-0123',
              pickupLat: 51.5074,
              pickupLng: -0.1278,
              deliveryLat: 51.5084,
              deliveryLng: -0.1288,
              createdAt: DateTime.now(),
              deliveredAt: DateTime.now(),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.pSmall.copyWith(
                    color: AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 6),
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
                        color: AppColors.navyMuted200,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        '#$deliveryId',
                        style: AppTextStyles.build(
                          size: 10,
                          height: 14,
                          color: AppColors.infoBoxBg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '+ ${AppUtils.formatCurrency(earnings)}',
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
                  info,
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
