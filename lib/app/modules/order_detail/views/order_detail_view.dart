import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/order_model.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/error_state_widget.dart';
import '../../../widgets/order_request_card.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Delivery Details',
          style: AppTextStyles.build(size: 16, weight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final order = controller.order.value;
        if (controller.hasError.value && order == null) {
          return ErrorStateWidget.server(onRetry: () => controller.loadOrderDetail());
        }
        if (order == null) {
          return const Center(child: AppLoader());
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
    final hasItems = order.items.isNotEmpty;
    final hasReview = (order.review != null && order.review!.isNotEmpty) || order.rating > 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreImage(order),
                const SizedBox(height: AppDimensions.gapMd),
                _buildAmountAndRouteCard(order),
                if (hasItems) ...[
                  const SizedBox(height: AppDimensions.gapMd),
                  _buildItemsCard(order),
                ],
                if (hasReview) ...[
                  const SizedBox(height: AppDimensions.gapMd),
                  _buildCustomerReview(order),
                ],
                const SizedBox(height: AppDimensions.gapMd),
                _buildEarningsBreakdown(order),
                const SizedBox(height: AppDimensions.paddingXl),
              ],
            ),
          ),
        ),
        if (order.isNew) _buildBottomActions(context),
      ],
    );
  }

  Widget _buildStoreImage(OrderModel order) {
    final storeName = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : (order.pickupShortAddress.isNotEmpty
            ? order.pickupShortAddress
            : (order.pickupAddress.isNotEmpty ? order.pickupAddress : ''));

    final imageUrl = AppUtils.getImageUrl(order.restaurantImage);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.infoBoxBg,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Assets.images.deliveryLocationImage.image(fit: BoxFit.cover),
            )
          else
            Assets.images.deliveryLocationImage.image(fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          if (storeName.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      storeName,
                      style: AppTextStyles.build(
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountAndRouteCard(OrderModel order) {
    final symbol = order.currency == 'GBP' ? '£' : (order.currency == 'USD' ? '\$' : '£');
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

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppUtils.formatCurrency(order.earnings, symbol: symbol),
                    style: AppTextStyles.build(
                      size: 22,
                      height: 28,
                      weight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'Helvetica Neue',
                    ),
                  ),
                  if (order.displayOrderId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppStrings.deliveryId,
                          style: AppTextStyles.pXSmall.copyWith(color: AppColors.otpSubtitle),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF868AA5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.displayOrderId,
                            style: AppTextStyles.overline.copyWith(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (hasMetrics)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x4DFFE083),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
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
          ),
          const SizedBox(height: 14),
          _buildRouteTimeline(order),
        ],
      ),
    );
  }

  Widget _buildRouteTimeline(OrderModel order) {
    final pickupName = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : (order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : '');
    final pickupAddress = order.pickupAddress.isNotEmpty ? order.pickupAddress : pickupName;
    final dropoffAddress = order.deliveryAddress;

    final hasPickup = pickupName.isNotEmpty || pickupAddress.isNotEmpty;
    final hasDropoff = dropoffAddress.isNotEmpty;

    if (!hasPickup && !hasDropoff) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPickup)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 14),
                    ),
                  ),
                  if (hasDropoff)
                    Container(
                      width: 2,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: CustomPaint(
                        painter: _VerticalDottedLinePainter(color: AppColors.stroke),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP',
                      style: AppTextStyles.build(
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (pickupName.isNotEmpty)
                      Text(
                        pickupName,
                        style: AppTextStyles.build(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.navy900,
                        ),
                      ),
                    if (pickupAddress.isNotEmpty && pickupAddress != pickupName) ...[
                      const SizedBox(height: 2),
                      Text(
                        pickupAddress,
                        style: AppTextStyles.build(
                          size: 12,
                          weight: FontWeight.w400,
                          color: AppColors.otpSubtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        if (hasDropoff)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROPOFF',
                      style: AppTextStyles.build(
                        size: 11,
                        weight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dropoffAddress,
                      style: AppTextStyles.build(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.navy900,
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

  Widget _buildItemsCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Items (${order.items.length})',
            style: AppTextStyles.build(size: 14, weight: FontWeight.w600, color: AppColors.navy900),
          ),
          const SizedBox(height: AppDimensions.gapMd),
          ...order.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${item.quantity}x',
            style: AppTextStyles.build(size: 13, weight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.build(size: 13, weight: FontWeight.w500, color: AppColors.navy900),
            ),
          ),
          if (item.options != null && item.options!.isNotEmpty)
            Text(
              item.options!,
              style: AppTextStyles.build(
                size: 12,
                weight: FontWeight.w400,
                color: AppColors.otpSubtitle,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerReview(OrderModel order) {
    final date = order.reviewDate ?? order.deliveredAt;
    final dateStr = date != null ? DateFormat('MMM dd, yyyy').format(date) : '';
    final reviewText = order.review ?? '';
    final rating = order.rating;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Review',
                style: AppTextStyles.build(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
              ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: AppTextStyles.build(
                    size: 12,
                    weight: FontWeight.w400,
                    color: AppColors.otpSubtitle,
                  ),
                ),
            ],
          ),
          if (rating > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final isFilled = index < rating.floor();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFilled ? const Color(0xFFFFB800) : const Color(0xFFD1D5DB),
                    size: 20,
                  ),
                );
              }),
            ),
          ],
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$reviewText"',
                style: AppTextStyles.build(
                  size: 13,
                  weight: FontWeight.w400,
                  color: AppColors.navy500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(OrderModel order) {
    final symbol = order.currency == 'GBP' ? '£' : (order.currency == 'USD' ? '\$' : '£');

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earning Breakdown',
            style: AppTextStyles.build(size: 14, weight: FontWeight.w600, color: AppColors.navy900),
          ),
          const SizedBox(height: AppDimensions.gapMd),
          if (order.items.isNotEmpty) ...[
            _buildBreakdownRow('Items', '${order.items.length}'),
            const SizedBox(height: 4),
          ],
          _buildBreakdownRow(
              'Delivery Amount', AppUtils.formatCurrency(order.earnings, symbol: symbol)),
          const Divider(height: 20, color: AppColors.stroke),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payout',
                style: AppTextStyles.build(
                    size: 15, weight: FontWeight.w600, color: AppColors.navy900),
              ),
              Text(
                AppUtils.formatCurrency(order.earnings, symbol: symbol),
                style: AppTextStyles.build(
                  size: 22,
                  weight: FontWeight.w700,
                  fontFamily: 'Helvetica Neue',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.build(
                size: 13, weight: FontWeight.w400, color: AppColors.otpSubtitle),
          ),
          Text(
            value,
            style: AppTextStyles.build(
                size: 13, weight: FontWeight.w500, color: AppColors.navy900),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SwipeToAcceptButton(
              onCompleted: () => controller.acceptOrder(),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            height: 48,
            child: AppButton(
              label: AppStrings.reject,
              variant: AppButtonVariant.danger,
              borderRadius: 10,
              onPressed: () => controller.rejectOrder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _VerticalDottedLinePainter({
    required this.color,
    this.dotRadius = 1.5,
    this.spacing = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawCircle(Offset(size.width / 2, startY + dotRadius), dotRadius, paint);
      startY += dotRadius * 2 + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
