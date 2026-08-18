import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/order_model.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_radius.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/connectivity_widget.dart';
import '../../../widgets/order_request_card.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/status_info_card.dart';
import '../../earnings/views/earnings_view.dart';
import '../../order_history/views/order_history_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    double finalBottomPadding;
    if (GetPlatform.isIOS && bottomPadding > 0) {
      finalBottomPadding = (bottomPadding - 8).clamp(0.0, double.infinity);
    } else {
      finalBottomPadding = bottomPadding > 0 ? bottomPadding + 12 : AppDimensions.gapMd;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBackPress();
      },
      child: Scaffold(
      extendBody: true,
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ConnectivityWidget(
          child: Stack(
            children: [
              Obx(
                () => IndexedStack(
                  index: controller.currentIndex.value,
                  children: const [
                    _HomeTab(),
                    OrderHistoryView(),
                    EarningsView(),
                    ProfileView(),
                  ],
                ),
              ),
              Positioned(
                left: AppDimensions.paddingMd,
                right: AppDimensions.paddingMd,
                bottom: finalBottomPadding + AppDimensions.bottomNavHeight + 28,
                child: Obx(() {
                  if (!controller.isOnDelivery.value) return const SizedBox.shrink();
                  return _buildFloatingDeliveryBar();
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => _BottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
     ) );
  }

  Widget _buildFloatingDeliveryBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to active delivery if needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF62C485), // Green color from image
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
              child: Assets.images.deliveryScooter.image(
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delivery in Progress',
                    style: AppTextStyles.pMediumSemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tap to return to your live delivery route',
                    style: AppTextStyles.pXSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
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

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate padding: for iOS (where bottomPadding > 0), we reduce it by 20px
    // to bring it down as requested. For Android (where it's "perfect"), we keep it as is.
    double finalBottomPadding;
    if (GetPlatform.isIOS && bottomPadding > 0) {
      finalBottomPadding = (bottomPadding - 8).clamp(0.0, double.infinity);
    } else {
      finalBottomPadding = bottomPadding > 0 ? bottomPadding + 12 : AppDimensions.gapMd;
    }

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.paddingMd,
          AppDimensions.gapSm,
          AppDimensions.paddingMd,
          finalBottomPadding,
        ),
        child: Container(
          height: AppDimensions.bottomNavHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1520),
            borderRadius: AppRadius.xlarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: _NavItem(
                  selectedImage: Assets.images.homeSelected,
                  unselectedImage: Assets.images.homeUnselected,
                  label: AppStrings.home,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  selectedImage: Assets.images.deliverySelected,
                  unselectedImage: Assets.images.truckUnselected,
                  label: AppStrings.delivery,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  selectedImage: Assets.images.walletSelected,
                  unselectedImage: Assets.images.walletUnselected,
                  label: AppStrings.earnings,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _NavItem(
                  selectedImage: Assets.images.profileSelected,
                  unselectedImage: Assets.images.profileUnselcetd,
                  label: AppStrings.profile,
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AssetGenImage selectedImage;
  final AssetGenImage unselectedImage;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.selectedImage,
    required this.unselectedImage,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (isActive ? selectedImage : unselectedImage).image(
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? AppColors.primary : AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Empty Tab ────────────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.white);
  }
}

// ─── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends GetView<DashboardController> {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.gapMd),
                _buildLocationHeader(context),
                const SizedBox(height: AppDimensions.gapMd),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.fetchDashboardData();
                await controller.refreshLocation(showDialog: false);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildOnlineToggleCard(),
                        const SizedBox(height: AppDimensions.gapLg),
                        _buildEarningsSummary(),
                        const SizedBox(height: AppDimensions.gapLg),
                        _buildDeliveryRequestsHeader(),
                        const SizedBox(height: AppDimensions.gapMd),
                        _buildDeliveryRequestsContent(),
                        const SizedBox(height: AppDimensions.paddingXl),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    
  }

  Widget _buildLocationHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLocationBottomSheet(context),
      onLongPress: () => controller.isOnDelivery.toggle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.liveLocation,
            style: AppTextStyles.pXSmallMedium.copyWith(
              color: AppColors.otpSubtitle,
            ),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Row(
            children: [
              Assets.images.location.image(
                width: AppDimensions.iconSm,
                height: AppDimensions.iconSm,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.gapXs),
              Flexible(
                child: Obx(
                  () => Text(
                    controller.currentLocationAddress.value,
                    style: AppTextStyles.pSmallMedium.copyWith(
                      color: AppColors.navy900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.navy900,
                size: AppDimensions.iconSm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.gapLg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.gapMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Location Details',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy900,
                      ),
                    ),
                    Text(
                      'Your current registered driver location',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.gapLg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.infoBoxBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT ADDRESS',
                    style: AppTextStyles.pXSmallMedium.copyWith(
                      color: AppColors.otpSubtitle,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      controller.currentLocationAddress.value,
                      style: AppTextStyles.pSmallMedium.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapSm),
                  Obx(
                    () => Text(
                      'Coordinates: ${controller.currentLat.value.toStringAsFixed(6)}, ${controller.currentLng.value.toStringAsFixed(6)}',
                      style: AppTextStyles.pXSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.gapLg),
            AppButton(
              label: 'Update Current Location',
              onPressed: () {
                Get.back();
                controller.onLocationHeaderTap();
              },
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Close',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOnlineToggleCard() {
    return Obx(() {
      final isOnline = controller.isOnline.value;
      return Container(
        height: 68,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.infoBoxBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isOnline
                        ? AppStrings.youAreOnline
                        : AppStrings.youAreOffline,
                    style: AppTextStyles.pXSmall.copyWith(
                      color: AppColors.otpSubtitle,
                    ),
                  ),
                  Text(
                    AppStrings.receiveDeliveryRequests,
                    style: AppTextStyles.pSmallMedium.copyWith(
                      color: AppColors.navy500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.offlineOnline,
                  style: AppTextStyles.pXSmall.copyWith(
                    color: AppColors.otpSubtitle,
                  ),
                ),
                const SizedBox(height: AppDimensions.gapXs),
                SizedBox(
                  height: 24,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isOnline,
                      onChanged: (_) => controller.toggleOnlineStatus(),
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: AppColors.white,
                      inactiveTrackColor: AppColors.otpSubtitle,
                      inactiveThumbColor: AppColors.white,
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.earningsSummary,
          style: AppTextStyles.pLargeMedium.copyWith(color: AppColors.navy900),
        ),
        const SizedBox(height: AppDimensions.gapMd),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLargeStatCard(),
            const SizedBox(width: AppDimensions.gapLg),
            Expanded(
              child: Column(
                children: [
                  Obx(
                    () => _buildSmallStatCard(
                      label: AppStrings.todaysDeliveries,
                      value: '${controller.totalDeliveries.value}',
                      image: Assets.images.deliveries,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapLg),
                  Obx(
                    () => _buildSmallStatCard(
                      label: AppStrings.timeOnline,
                      value: AppUtils.formatDuration(
                          controller.timeOnlineMinutes.value),
                      image: Assets.images.totalTime,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeStatCard() {
    return Container(
      width: 173,
      height: 152,
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.images.earning.image(width: 40, height: 40),
          const SizedBox(height: AppDimensions.gapMd),
          Text(
            AppStrings.todaysEarnings,
            style: AppTextStyles.pXSmall.copyWith(
              color: AppColors.navyMuted200,
            ),
          ),
          Obx(
            () => Text(
              AppUtils.formatCurrency(controller.todayEarnings.value),
              style: AppTextStyles.build(
                size: 20,
                height: 28,
                weight: FontWeight.w700,
                fontFamily: 'Helvetica Neue',
                color: AppColors.primaryDarker,
              ),
            ),
          ),
          const Spacer(),
          Text(
            AppStrings.startDeliveringOrders,
            style: AppTextStyles.pXSmall.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String label,
    required String value,
    required AssetGenImage image,
  }) {
    return Container(
      width: double.infinity,
      height: 68,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingSm,
        AppDimensions.paddingSm,
        4,
        AppDimensions.paddingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          image.image(width: 40, height: 40),
          const SizedBox(width: AppDimensions.gapXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.pXSmall.copyWith(
                    color: AppColors.navyMuted200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: AppTextStyles.pMediumMedium.copyWith(
                    color: AppColors.navy900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryRequestsHeader() {
    return Text(
      AppStrings.deliveryRequests,
      style: AppTextStyles.pLargeMedium.copyWith(color: AppColors.navy900),
    );
  }

  Widget _buildDeliveryRequestsContent() {
    return Obx(() {
      if (!controller.isOnline.value) {
        return _buildDashedStatusCard(StatusInfoType.offline);
      }

      if (controller.isOnDelivery.value) {
        return _buildDashedStatusCard(StatusInfoType.onDelivery);
      }

      if (controller.activeOrders.isEmpty) {
        return _buildDashedStatusCard(StatusInfoType.waitingForDeliveries);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.activeOrders.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.gapMd),
        itemBuilder: (context, index) {
          final order = controller.activeOrders[index];
          return OrderRequestCard(
            order: order,
            showActions: order.isNew,
            onAccept: () => controller.acceptOrder(order.id),
            onReject: () => controller.rejectOrder(order.id),
            onTap: () => Get.toNamed(AppRoutes.orderDetail, arguments: order),
            countdownSeconds: order.isNew ? 30 : null,
          );
        },
      );
    });
  }

  void _handleToggle(DashboardController controller) {
    controller.toggleOnlineStatus();
  }

  void _showTestOrderRequest() {
    if (controller.activeOrders.isNotEmpty) {
      Get.dialog(
        Dialog(
          alignment: Alignment.topCenter,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 60,
          ),
          backgroundColor: Colors.transparent,
          child: OrderRequestCard(
            order: controller.activeOrders.first,
            countdownSeconds: 30,
            onAccept: () {
              Get.back();
              controller.toggleOnlineStatus();
            },
            onReject: () => Get.back(),
          ),
        ),
      );
    } else {
      controller.toggleOnlineStatus();
    }
  }

  void _showVerificationPopup() {
    Get.dialog(
      Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 100),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: StatusInfoCard(
          type: StatusInfoType.verificationPending,
          onButtonPressed: () => Get.back(),
          showBackground: true,
          width: double.infinity,
        ),
      ),
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
            ? () => _handleToggle(controller)
            : null,
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
    for (final PathMetric metric in path.computeMetrics()) {
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
