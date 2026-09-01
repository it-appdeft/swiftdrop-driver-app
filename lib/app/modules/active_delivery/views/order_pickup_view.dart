import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../generated/assets.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';

import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../controllers/active_delivery_controller.dart';

class OrderPickupView extends GetView<ActiveDeliveryController> {
  const OrderPickupView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.offAllNamed(AppRoutes.dashboard);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(() {
          final order = controller.order.value;
          if (order == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildDropoffHeader(order),
                        const SizedBox(height: 16),
                        _buildStoreImage(order),
                        const SizedBox(height: 16),
                        _buildStoreInfoCard(order),
                        const SizedBox(height: 16),
                        _buildItemsSection(order),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButton(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDropoffHeader(OrderModel order) {
    final dropoffText = order.deliveryShortAddress.isNotEmpty
        ? order.deliveryShortAddress
        : (order.deliveryAddress.isNotEmpty ? order.deliveryAddress : 'Dropoff Location');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.offAllNamed(AppRoutes.dashboard),
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.arrow_back, color: AppColors.navy900, size: 24),
              ),
            ),
            Text(
              'Dropoff Location',
              style: AppTextStyles.build(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.otpSubtitle,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => controller.openHelpCenter(),
              icon: const Icon(Icons.help_outline_rounded, color: AppColors.navy900, size: 22),
              tooltip: 'Help / Support',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Assets.images.location.image(width: 20, height: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dropoffText,
                style: AppTextStyles.build(
                  size: 15,
                  weight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
      height: 200,
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      storeName.isNotEmpty ? storeName : 'Store Location',
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
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoCard(OrderModel order) {
    final storeName = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : (order.pickupShortAddress.isNotEmpty
            ? order.pickupShortAddress
            : (order.pickupAddress.isNotEmpty ? order.pickupAddress : 'Store Location'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: AppTextStyles.build(
                    size: 16,
                    weight: FontWeight.w500,
                    color: AppColors.navy900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.pickupAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    order.pickupAddress,
                    style: AppTextStyles.build(
                      size: 13,
                      color: AppColors.otpSubtitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Delivery ID',
                      style: AppTextStyles.build(
                        size: 12,
                        color: AppColors.otpSubtitle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF868AA5),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        order.displayOrderId,
                        style: AppTextStyles.build(
                          size: 9,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 40,
            width: 130, // Increased width to prevent overflow
            child: AppButton(
              label: 'Call Store',
              onPressed: () => controller.callStore(),
              prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: Colors.white),
              borderRadius: 8,
              backgroundColor: const Color(0xFF233A4E), // Using the requested hex color
              isFullWidth: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Items (${order.items.length})',
            style: AppTextStyles.build(
              size: 14,
              weight: FontWeight.w600,
              color: AppColors.navy900,
            ),
          ),
          const SizedBox(height: 12),
          if (order.items.isNotEmpty)
            ...order.items.map((item) => _buildItemRow(item))
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No item details provided',
                style: AppTextStyles.pSmall.copyWith(color: AppColors.otpSubtitle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity}x',
            style: AppTextStyles.build(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.build(
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.navy900,
                  ),
                ),
                if (item.options != null && item.options!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.options!,
                    style: AppTextStyles.build(
                      size: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.otpSubtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + MediaQuery.of(context).padding.bottom),
      child: AppButton(
        label: 'Confirm Pickup',
        onPressed: () => controller.goToPickupVerification(),
      ),
    );
  }
}
