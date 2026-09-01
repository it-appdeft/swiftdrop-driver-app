import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/connectivity_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';

class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onReload;
  final bool isFullScreen;

  const NetworkErrorView({
    super.key,
    this.onReload,
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ─── Concentric Circles with Wi-Fi Icon ─────────────────────────
            _buildRadarWifiGraphic(),

            const SizedBox(height: 36),

            // ─── Title & Subtitle ───────────────────────────────────────────
            Text(
              'No Internet Connection',
              style: AppTextStyles.build(
                size: 20,
                height: 28,
                weight: FontWeight.w700,
                color: AppColors.navy900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your network settings and\ntry again to continue your deliveries.',
              style: AppTextStyles.build(
                size: 14,
                height: 20,
                weight: FontWeight.w400,
                color: const Color(0xFF868AA5),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 3),

            // ─── Action Buttons ─────────────────────────────────────────────
            _buildReloadButton(),
            const SizedBox(height: 12),
            _buildContactSupportButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (!isFullScreen) {
      return Container(
        color: AppColors.white,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: content,
    );
  }

  Widget _buildRadarWifiGraphic() {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 175,
          height: 175,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.wifi_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          if (onReload != null) {
            onReload!();
            return;
          }

          if (Get.isRegistered<ConnectivityService>()) {
            final isOnline = await ConnectivityService.to.checkConnection();
            if (isOnline) {
              AppUtils.showSuccess('Connected to the internet');
              if (Get.key.currentState?.canPop() ?? false) {
                Get.back();
              }
            } else {
              AppUtils.showWarning('Still offline. Please check your Wi-Fi or Mobile Data.');
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: AppColors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Reload',
              style: AppTextStyles.build(
                size: 16,
                height: 22,
                weight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.toNamed(AppRoutes.support);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.stroke, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.headset_mic_outlined,
              size: 19,
              color: Color(0xFF868AA5),
            ),
            const SizedBox(width: 8),
            Text(
              'Contact Support',
              style: AppTextStyles.build(
                size: 15,
                height: 20,
                weight: FontWeight.w500,
                color: AppColors.navy900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
