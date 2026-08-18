import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../generated/assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../controllers/delivery_verification_controller.dart';

class DeliveryVerificationView extends GetView<DeliveryVerificationController> {
  const DeliveryVerificationView({super.key});

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
      ),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) return const Center(child: Text('Order not found'));

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(order),
                    const SizedBox(height: 16),
                    _buildInputLabel(),
                    const SizedBox(height: 16),
                    _buildOTPField(context),
                    if (controller.hasError.value) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Wrong verification code. Please try again.',
                          style: AppTextStyles.build(
                            size: 14,
                            weight: FontWeight.w400,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.type.value == VerificationType.pickup
                              ? 'Ask the restaurant for their unique verification code to finalize the delivery'
                              : 'Ask the customer for their unique verification code to finalize the delivery',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.build(
                            size: 13,
                            color: AppColors.otpSubtitle.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(OrderModel order) {
    final isPickup = controller.type.value == VerificationType.pickup;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isPickup
                    ? Text(
                        order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : 'Urban Grind Coffee House',
                        style: AppTextStyles.build(
                          size: 18,
                          weight: FontWeight.w600,
                          color: AppColors.navy900,
                        ),
                      )
                    : Text(
                        AppUtils.formatCurrency(order.earnings),
                        style: AppTextStyles.build(
                          size: 24,
                          weight: FontWeight.w700,
                          fontFamily: 'Helvetica Neue',
                          color: AppColors.navy900,
                        ),
                      ),
              ),
              _buildBadge('${order.items.length} Items'),
            ],
          ),
          const SizedBox(height: 4),
          if (isPickup)
            Text(
              order.pickupAddress,
              style: AppTextStyles.build(
                size: 13,
                color: AppColors.otpSubtitle,
              ),
            ),
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
              const SizedBox(width: 8),
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF868AA5).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${order.orderId}',
                  style: AppTextStyles.build(
                    size: 10,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isPickup)
            ...order.items.map((item) => _buildItemRow(item))
          else
            _buildLocationSummary(order),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1728),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.build(
          size: 12,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
            child: Text(
              item.name,
              style: AppTextStyles.build(
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.navy900,
              ),
            ),
          ),
          Text(
            'Large, Oat Milk',
            style: AppTextStyles.build(
              size: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.otpSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSummary(OrderModel order) {
    return Column(
      children: [
        _buildLocationRow(
          leading: Assets.images.pickupFoodImage.image(width: 20, height: 20),
          title: order.pickupShortAddress.isNotEmpty ? order.pickupShortAddress : 'Urban Grind Coffee House',
          subtitle: '1x latte, 1x Croissant',
        ),
        const SizedBox(height: 16),
        _buildLocationRow(
          leading: Assets.images.dropFoodLocationImage.image(width: 20, height: 20),
          title: order.deliveryShortAddress.isNotEmpty ? order.deliveryShortAddress : 'Grand Central Station, Gate 4',
          subtitle: 'Gate 4',
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required Widget leading,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.build(
                  size: 15,
                  weight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.build(
                  size: 12,
                  color: AppColors.otpSubtitle.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          controller.type.value == VerificationType.pickup
              ? 'Enter Restaurant Code'
              : 'Enter Delivery Code',
          style: AppTextStyles.build(
            size: 16,
            weight: FontWeight.w500,
            color: AppColors.navy900,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF868AA5).withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Assets.images.helpAndCenter.image(width: 16, height: 16),
              const SizedBox(width: 4),
              Text(
                'Help Center',
                style: AppTextStyles.build(
                  size: 12,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final otp = controller.otp.value;
          final isError = controller.hasError.value;
          final hasFocus = controller.focusNode.hasFocus;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              if (!controller.focusNode.hasFocus) {
                controller.focusNode.requestFocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: isError ? const Color(0xFFFFF1F1) : const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isError ? const Color(0xFFE53935) : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    String char = '';
                    bool isEmpty = true;
                    if (otp.length > index) {
                      char = otp[index];
                      isEmpty = false;
                    }
                    
                    final isNextToFill = index == otp.length;
                    final showCursor = hasFocus && isNextToFill;

                    return Container(
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isEmpty)
                            Positioned(
                              bottom: 12,
                              child: Container(
                                width: 20,
                                height: 2,
                                color: AppColors.otpSubtitle.withOpacity(0.4),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                char,
                                style: AppTextStyles.build(
                                  size: 24,
                                  weight: FontWeight.w400,
                                  fontFamily: 'Helvetica Neue',
                                  color: AppColors.navy900,
                                ),
                              ),
                            ),
                          if (showCursor)
                            const _BlinkingCursor(),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        }),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller.otpController,
              focusNode: controller.focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              showCursor: false,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 20 + MediaQuery.of(context).padding.bottom),
      child: AppButton(
        label: controller.type.value == VerificationType.pickup ? 'Confirm OTP' : 'Confirm Delivery',
        onPressed: () => controller.confirm(),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
