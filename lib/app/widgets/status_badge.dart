import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_decorations.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusBadge({super.key, required this.status, this.isLarge = false});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        return AppColors.statusNew;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'picked_up':
      case 'pickedup':
        return AppColors.statusPickedUp;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.navyMuted400;
    }
  }

  String get _label => status.toUpperCase().replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppDimensions.paddingSm : AppDimensions.gapSm,
        vertical: isLarge ? AppDimensions.gapXs + 2 : AppDimensions.gapXs,
      ),
      decoration: AppDecorations.statusBadge(_color),
      child: Text(
        _label,
        style: (isLarge ? AppTextStyles.pXSmallSemiBold : AppTextStyles.label)
            .copyWith(color: _color),
      ),
    );
  }
}
