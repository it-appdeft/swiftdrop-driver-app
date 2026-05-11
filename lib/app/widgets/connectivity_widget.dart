import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class ConnectivityWidget extends StatelessWidget {
  final Widget child;

  const ConnectivityWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final service = ConnectivityService.to;
          if (service.isConnected.value) return const SizedBox.shrink();
          return _OfflineBanner(connectionLabel: service.connectionLabel);
        }),
        Expanded(child: child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final String connectionLabel;

  const _OfflineBanner({required this.connectionLabel});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.gapXs,
        horizontal: AppDimensions.paddingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.white, size: 16),
          const SizedBox(width: AppDimensions.gapSm),
          Text(
            'No internet connection',
            style: AppTextStyles.pXSmall.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class OfflineOverlay extends StatelessWidget {
  final Widget child;
  final bool showWhenOffline;

  const OfflineOverlay({
    super.key,
    required this.child,
    this.showWhenOffline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isConnected = ConnectivityService.to.isConnected.value;
      if (!showWhenOffline || isConnected) return child;

      return Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.gapXs,
                  horizontal: AppDimensions.paddingMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.white, size: 14),
                    const SizedBox(width: AppDimensions.gapXs),
                    Text(
                      'Offline — some features unavailable',
                      style: AppTextStyles.pXSmall.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
