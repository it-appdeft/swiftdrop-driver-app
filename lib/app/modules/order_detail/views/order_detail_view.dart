
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                OrderRequestCard(
                  order: order,
                  showActions: false,
                  countdownSeconds: order.isNew ? 30 : null,
                ),
                const SizedBox(height: AppDimensions.gapMd),
                _buildItemsCard(order),
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
    return Container(
      height: 188,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: Assets.images.deliveryLocationImage.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: [
                Assets.images.location.image(width: 20, height: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : 'Store Location',
                  style: AppTextStyles.build(
                    size: 14,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
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
              style: AppTextStyles.build(size: 13, weight: FontWeight.w400, color: AppColors.navy900),
            ),
          ),
          Text(
            'Note', // Placeholder for item notes
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

  Widget _buildEarningsBreakdown(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSm),
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
          _buildBreakdownRow('Items', '${order.items.length}'),
          SizedBox(height: 8,),
          _buildBreakdownRow('Delivery Amount', AppUtils.formatCurrency(order.earnings)),
          const Divider(height: 20, color: AppColors.stroke),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payout',
                style: AppTextStyles.build(size: 15, weight: FontWeight.w600, color: AppColors.navy900),
              ),
              Text(
                AppUtils.formatCurrency(order.earnings),
                style: AppTextStyles.build(
                  size: 24,
                  weight: FontWeight.w500,
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
            style: AppTextStyles.build(size: 13, weight: FontWeight.w400, color: AppColors.otpSubtitle),
          ),
          Text(
            value,
            style: AppTextStyles.build(size: 13, weight: FontWeight.w400, color: AppColors.navy900),
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
