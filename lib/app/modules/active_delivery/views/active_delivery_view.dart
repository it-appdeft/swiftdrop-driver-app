import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../generated/assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../controllers/active_delivery_controller.dart';

class ActiveDeliveryView extends GetView<ActiveDeliveryController> {
  const ActiveDeliveryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map
          Obx(() {
            final order = controller.order.value;
            if (order == null) return const Center(child: CircularProgressIndicator());

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(order.pickupLat, order.pickupLng),
                zoom: 14,
              ),
              onMapCreated: controller.onMapCreated,
              markers: controller.markers,
              polylines: controller.polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            );
          }),

          // Top Instruction Bar (SS1 style)
          Obx(() => !controller.isHeadingToDropoff.value
              ? _buildTopInstruction()
              : const SizedBox.shrink()),

          // Bottom Sheet / Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(() {
              final order = controller.order.value;
              if (order == null) return const SizedBox.shrink();
              
              return controller.isHeadingToDropoff.value
                  ? _buildHeadingToDropoffCard(order)
                  : _buildHeadingToPickupCard(order);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInstruction() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.navy900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.turn_left, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TURN LEFT IN 200M',
                    style: AppTextStyles.build(
                      size: 12,
                      weight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Church Street',
                    style: AppTextStyles.build(
                      size: 18,
                      weight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildHeadingToPickupCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4), // 16 (padding) + 4 = 20 leading
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Church Street to Pickup',
                      style: AppTextStyles.build(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ETA 4 min',
                  style: AppTextStyles.build(
                    size: 12,
                    weight: FontWeight.w400,
                    color: AppColors.navy900.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Assets.images.deliveryCartImage.image(width: 40, height: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : 'Urban Grind Coffee House',
                        style: AppTextStyles.build(
                          size: 16,
                          weight: FontWeight.w600,
                          color: AppColors.navy900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Delivery ID',
                            style: AppTextStyles.build(
                              size: 12,
                              color: AppColors.otpSubtitle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF868AA5),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '#${order.orderId}',
                              style: AppTextStyles.build(
                                size: 9,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.items.length} Items',
                        style: AppTextStyles.build(
                          size: 12,
                          color: AppColors.otpSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.callStore();
                  },
                  child: Assets.images.phoneImage.image(width: 40, height: 40),
                ),
              ],
            ),
          ),
          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: AppButton(
              label: 'Reached Pickup Location',
              onPressed: () => controller.reachedPickup(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingToDropoffCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(left: 16,right: 16,bottom: 40),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 4), // 16 + 4 = 20 leading
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delivery Picked',
                      style: AppTextStyles.build(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ETA 4 min',
                  style: AppTextStyles.build(
                    size: 12,
                    weight: FontWeight.w400,
                    color: AppColors.navy900.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Route Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRoutePoint(
                  label: 'PICKUP',
                  labelColor: AppColors.primary,
                  address: order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : 'Urban Grind Coffee House',
                  subAddress: order.pickupAddress,
                  icon: Assets.images.pickupLocation.image(width: 20, height: 20),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildRoutePoint(
                        label: 'DROPOFF',
                        labelColor: AppColors.tintBlue,
                        address: order.deliveryShortAddress.isNotEmpty ? order.deliveryShortAddress : 'Grand Central Station, Gate 4',
                        subAddress: order.deliveryAddress,
                        icon: Assets.images.dropOffLocation.image(width: 20, height: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.callCustomer();
                      },
                      child: Assets.images.phoneImage.image(width: 40, height: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: AppButton(
              label: 'Confirm Reached Dropoff',
              onPressed: () => controller.reachedDropoff(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint({
    required String label,
    required Color labelColor,
    required String address,
    required String subAddress,
    required Widget icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.build(
                  size: 11,
                  weight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTextStyles.build(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subAddress,
                style: AppTextStyles.build(
                  size: 12,
                  color: AppColors.otpSubtitle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
