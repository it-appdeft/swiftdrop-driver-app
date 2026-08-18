import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../generated/assets.dart';
import '../constants/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import '../utils/app_utils.dart';
import 'app_button.dart';

class OrderRequestCard extends StatefulWidget {
  final OrderModel order;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTimeout;
  final VoidCallback? onTap;
  final int? countdownSeconds;

  const OrderRequestCard({
    super.key,
    required this.order,
    this.showActions = true,
    this.onAccept,
    this.onReject,
    this.onTimeout,
    this.onTap,
    this.countdownSeconds,
  });

  @override
  State<OrderRequestCard> createState() => _OrderRequestCardState();
}

class _OrderRequestCardState extends State<OrderRequestCard> {
  Timer? _timer;
  late int _remaining;
  late final int _total;

  @override
  void initState() {
    super.initState();
    _total = widget.countdownSeconds ?? 30;
    _remaining = _total;
    if (widget.countdownSeconds != null) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _remaining = 0;
          _timer?.cancel();
          widget.onTimeout?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.infoBoxBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.gapMd),
            const Divider(height: 1, color: AppColors.stroke),
            const SizedBox(height: AppDimensions.gapMd),
            _buildLocationSection(),
            if (widget.showActions) ...[
              const SizedBox(height: AppDimensions.gapLg),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppUtils.formatCurrency(widget.order.earnings),
                style: AppTextStyles.build(
                  size: 20,
                  height: 28,
                  weight: FontWeight.w700,
                  color: AppColors.black,
                  fontFamily: 'Helvetica Neue',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    AppStrings.deliveryId,
                    style: AppTextStyles.pXSmall.copyWith(color: AppColors.otpSubtitle),
                  ),
                  const SizedBox(width: AppDimensions.gapXs),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF868AA5).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#${widget.order.orderId}',
                        style: AppTextStyles.overline.copyWith(color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildTimeDistBox(),
      ],
    );
  }

  Widget _buildTimeDistBox() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x4DFFE083),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFB7950B)),
          const SizedBox(width: 4),
          Text(
            '${widget.order.estimatedMinutes}min (${widget.order.distanceKm.toStringAsFixed(1)}MI) total',
            style: AppTextStyles.build(
              size: 11,
              weight: FontWeight.w500,
              color: const Color(0xFFB7950B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Left: Icons & Dotted Line ───────────────────────────────────────
        Column(
          children: [
            const SizedBox(height: 2), // Align with label text
            Assets.images.pickupLocation.image(width: 14, height: 14),
            _buildDottedLine(height: 78),
            Assets.images.dropOffLocation.image(width: 14, height: 14),
          ],
        ),
        const SizedBox(width: 10),

        // ─── Right: All text data + Timer ────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationInfo(
                label: AppStrings.pickupLabel,
                labelColor: AppColors.primary,
                title: widget.order.pickupShortAddress.isNotEmpty
                    ? widget.order.pickupShortAddress
                    : 'Pickup Location',
                address: widget.order.pickupAddress,
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildLocationInfo(
                      label: AppStrings.dropoffLabel,
                      labelColor: AppColors.tintBlue,
                      title: widget.order.deliveryShortAddress.isNotEmpty
                          ? widget.order.deliveryShortAddress
                          : 'Dropoff Location',
                      address: widget.order.deliveryAddress,
                    ),
                  ),
                  if (widget.countdownSeconds != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: _buildCountdown(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedLine({required double height}) {
    return SizedBox(
      height: height,
      child: Column(
        children: List.generate(
          (height / 6).floor(),
          (index) => Container(
            width: 1,
            height: 3,
            color: AppColors.otpSubtitle.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(vertical: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo({
    required String label,
    required Color labelColor,
    required String title,
    required String address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.pSmallSemiBold.copyWith(color: labelColor),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.build(
            size: 15,
            weight: FontWeight.w600,
            color: AppColors.navy900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          address,
          style: AppTextStyles.pXSmall.copyWith(color: AppColors.otpSubtitle),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    final progress = _total > 0 ? _remaining / _total : 0.0;
    final isUrgent = _remaining <= 10;
    final color = isUrgent ? AppColors.error : AppColors.primary.withOpacity(0.6);

    return Container(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scaleX: -1,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 1.0,
              color: color,
              backgroundColor: AppColors.stroke,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_remaining',
                style: AppTextStyles.pXSmallMedium.copyWith(
                  color: isUrgent ? AppColors.error : AppColors.otpSubtitle,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppStrings.sec,
                style: AppTextStyles.pXSmallMedium.copyWith(
                  color: isUrgent ? AppColors.error : AppColors.otpSubtitle,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SwipeToAcceptButton(
            onCompleted: widget.onAccept ?? () {},
          ),
        ),
        const SizedBox(width: AppDimensions.gapMd),
        SizedBox(
          width: 90,
          height: 48,
          child: AppButton(
            label: AppStrings.reject,
            variant: AppButtonVariant.danger,
            borderRadius: 10,
            onPressed: widget.onReject ?? () {},
          ),
        ),
      ],
    );
  }
}

class SwipeToAcceptButton extends StatefulWidget {
  final VoidCallback onCompleted;

  const SwipeToAcceptButton({super.key, required this.onCompleted});

  @override
  State<SwipeToAcceptButton> createState() => _SwipeToAcceptButtonState();
}

class _SwipeToAcceptButtonState extends State<SwipeToAcceptButton> {
  double _dragValue = 0.0;
  final double _handleWidth = 36.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - _handleWidth - 16;

        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF142030),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    AppStrings.swipeToAccept,
                    style: AppTextStyles.pSmallRegular.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _dragValue + 8,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragValue += details.delta.dx;
                      if (_dragValue < 0) _dragValue = 0;
                      if (_dragValue > maxDrag) _dragValue = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragValue > maxDrag * 0.8) {
                      setState(() => _dragValue = maxDrag);
                      widget.onCompleted();
                    } else {
                      setState(() => _dragValue = 0);
                    }
                  },
                  child: Container(
                    width: _handleWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Assets.images.swipeFrame.image(
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
