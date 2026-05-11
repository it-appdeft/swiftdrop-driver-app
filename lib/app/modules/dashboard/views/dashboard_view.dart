import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/connectivity_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/section_header.dart';
import '../../earnings/views/earnings_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../order_history/views/order_history_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: ConnectivityWidget(
        child: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              _HomeTab(),
              OrderHistoryView(),
              EarningsView(),
              NotificationsView(),
              ProfileView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends GetView<DashboardController> {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingMd,
                AppDimensions.paddingLg,
                AppDimensions.paddingMd,
                AppDimensions.gapSm,
              ),
              child: SectionHeader(
                title: 'Active Orders',
                actionLabel: 'History',
                onAction: () => controller.changeTab(1),
              ),
            ),
          ),
          _buildOrdersList(),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingXl)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingMd,
        AppDimensions.paddingLg,
      ),
      decoration: AppDecorations.headerGradient,
      child: Row(
        children: [
          Obx(() {
            final user = controller.user;
            return Row(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarSm / 2,
                  backgroundColor: AppColors.white.withValues(alpha: 0.2),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'D',
                    style: AppTextStyles.pSmallSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: AppDimensions.gapSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'Driver'}!',
                      style: AppTextStyles.pMediumSemiBold
                          .copyWith(color: AppColors.white),
                    ),
                    Text(
                      'Ready to deliver?',
                      style: AppTextStyles.pXSmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const Spacer(),
          Obx(
            () => GestureDetector(
              onTap: controller.toggleOnlineStatus,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSm,
                  vertical: AppDimensions.gapSm,
                ),
                decoration: BoxDecoration(
                  color: controller.isOnline.value
                      ? AppColors.success
                      : AppColors.white.withValues(alpha: 0.2),
                  borderRadius:
                      AppDecorations.cardDark.borderRadius,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: AppDimensions.gapSm,
                      height: AppDimensions.gapSm,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.gapXs),
                    Text(
                      controller.isOnline.value ? 'Online' : 'Offline',
                      style: AppTextStyles.pXSmallSemiBold
                          .copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _StatCard(
                label: "Today's Earnings",
                value: AppUtils.formatCurrency(controller.todayEarnings.value),
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Obx(
              () => _StatCard(
                label: 'Rating',
                value: controller.rating.value > 0
                    ? controller.rating.value.toStringAsFixed(1)
                    : 'N/A',
                icon: Icons.star_rounded,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Obx(
              () => _StatCard(
                label: 'Deliveries',
                value: '${controller.totalDeliveries.value}',
                icon: Icons.delivery_dining_rounded,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const ShimmerOrderCard(),
            childCount: 4,
          ),
        );
      }

      if (controller.activeOrders.isEmpty) {
        return SliverFillRemaining(
          child: EmptyStateWidget.orders(
            onRefresh: controller.loadActiveOrders,
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _OrderCard(order: controller.activeOrders[index]),
          childCount: controller.activeOrders.length,
        ),
      );
    });
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends GetView<DashboardController> {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapXs,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.orderCardDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(status: order.status),
                const Spacer(),
                Text(
                  AppUtils.formatCurrency(order.earnings),
                  style:
                      AppTextStyles.h6SemiBold.copyWith(color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Text('#${order.orderId}',
                style: AppTextStyles.pSmallSemiBold),
            const SizedBox(height: AppDimensions.gapSm),
            _AddressRow(
              icon: Icons.trip_origin,
              iconColor: AppColors.primary,
              label: order.pickupShortAddress.isNotEmpty
                  ? order.pickupShortAddress
                  : order.pickupAddress,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: AppDimensions.gapSm + AppDimensions.gapXs),
              child: SizedBox(
                height: AppDimensions.sp12,
                child: VerticalDivider(
                  color: AppColors.darkBorder,
                  thickness: 1.5,
                  width: 1,
                ),
              ),
            ),
            _AddressRow(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: order.deliveryShortAddress.isNotEmpty
                  ? order.deliveryShortAddress
                  : order.deliveryAddress,
            ),
            const SizedBox(height: AppDimensions.gapMd),
            Row(
              children: [
                const Icon(Icons.route_rounded,
                    size: AppDimensions.iconXs,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.gapXs),
                Text(
                  '${order.distanceKm.toStringAsFixed(1)} km  •  ~${order.estimatedMinutes} min',
                  style: AppTextStyles.pXSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (order.isNew) ...[
                  _ActionButton(
                    label: 'Reject',
                    color: AppColors.error,
                    onTap: () => controller.rejectOrder(order.id),
                    isOutline: true,
                  ),
                  const SizedBox(width: AppDimensions.gapSm),
                  _ActionButton(
                    label: 'Accept',
                    color: AppColors.success,
                    onTap: () => controller.acceptOrder(order.id),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconXs + 2, color: iconColor),
        const SizedBox(width: AppDimensions.gapSm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.pXSmall.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isOutline;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.gapSm,
        ),
        decoration: BoxDecoration(
          color: isOutline ? AppColors.transparent : color,
          borderRadius: AppDecorations.cardDark.borderRadius,
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: AppTextStyles.pXSmallSemiBold.copyWith(
            color: isOutline ? color : AppColors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
      decoration: AppDecorations.cardDark,
      child: Column(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSm),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            value,
            style: AppTextStyles.pSmallSemiBold.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            label,
            style: AppTextStyles.pXSmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
