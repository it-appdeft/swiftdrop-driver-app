import 'package:flutter/material.dart';
import '../../generated/assets.dart';
import '../constants/app_strings.dart';
import '../constants/app_constants.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import 'app_button.dart';

enum StatusInfoType {
  offline,
  verificationPending,
  waitingForDeliveries,
  onDelivery,
  noHistory,
}

class StatusInfoCard extends StatelessWidget {
  final StatusInfoType type;
  final VoidCallback? onButtonPressed;
  final double? width;
  final double? height;
  final bool showBackground;

  const StatusInfoCard({
    super.key,
    required this.type,
    this.onButtonPressed,
    this.width,
    this.height,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: BoxDecoration(
        color: showBackground ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          SizedBox(
            height: type == StatusInfoType.verificationPending
                ? AppDimensions.gapLg
                : AppDimensions.gapMd,
          ),
          Text(
            _getTitle(),
            textAlign: TextAlign.center,
            style: _getTitleStyle(),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Text(
            _getSubtitle(),
            textAlign: TextAlign.center,
            style: _getSubtitleStyle(),
          ),
          if (_hasButton()) ...[
            const SizedBox(height: AppDimensions.gapLg),
            AppButton(
              label: _getButtonLabel(),
              onPressed: onButtonPressed ?? () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case StatusInfoType.offline:
        return Assets.images.offline.image(
          width: 48,
          height: 48,
        );
      case StatusInfoType.verificationPending:
        return _buildCircularIcon(
          icon: Icons.access_time_rounded,
          color: AppColors.primary,
          size: 80,
        );
      case StatusInfoType.waitingForDeliveries:
        return _buildCircularIcon(
          icon: Icons.location_searching_rounded,
          color: AppColors.primary,
          size: 80,
        );
      case StatusInfoType.onDelivery:
        return Assets.images.deliveryHistory.image(
          height: 48,
          fit: BoxFit.contain,
        );
      case StatusInfoType.noHistory:
        return Assets.images.deliveryHistory.image(
          width: 48,
          height: 48,
        );
    }
  }

  Widget _buildCircularIcon({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: type == StatusInfoType.verificationPending
            ? const Color(0xFFC8F8DE)
            : color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: type == StatusInfoType.verificationPending
              ? const Color(0xFF10C981)
              : color,
          size: size * 0.45,
        ),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case StatusInfoType.offline:
        return AppStrings.currentlyOffline;
      case StatusInfoType.verificationPending:
        return 'Document Verification\nIn Progress';
      case StatusInfoType.waitingForDeliveries:
        return AppStrings.waitingForDeliveries;
      case StatusInfoType.onDelivery:
        return "You're Currently on a Delivery";
      case StatusInfoType.noHistory:
        return "No Delivery History Yet";
    }
  }

  TextStyle _getTitleStyle() {
    if (type == StatusInfoType.verificationPending) {
      return AppTextStyles.pMediumSemiBold.copyWith(
        color: const Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );
    }
    return AppTextStyles.pMediumSemiBold.copyWith(
      color: AppColors.otpDigit,
      fontSize: 16,
    );
  }

  String _getSubtitle() {
    switch (type) {
      case StatusInfoType.offline:
        return AppConstants.offlineMessage;
      case StatusInfoType.verificationPending:
        return AppStrings.verificationDesc;
      case StatusInfoType.waitingForDeliveries:
        return AppStrings.waitingForDeliveriesDesc;
      case StatusInfoType.onDelivery:
        return "You can't receive new delivery requests while completing an active Delivery.";
      case StatusInfoType.noHistory:
        return "Your completed deliveries will appear here once you start accepting and finishing orders.";
    }
  }

  TextStyle _getSubtitleStyle() {
    return AppTextStyles.pSmallRegular.copyWith(
      color: const Color(0xFF64748B),
      fontSize: 13,
      height: 1.4,
    );
  }

  bool _hasButton() =>
      type == StatusInfoType.offline ||
      type == StatusInfoType.verificationPending;

  String _getButtonLabel() {
    switch (type) {
      case StatusInfoType.offline:
        return AppStrings.goOnlineNow;
      case StatusInfoType.verificationPending:
        return AppStrings.close;
      default:
        return '';
    }
  }
}
