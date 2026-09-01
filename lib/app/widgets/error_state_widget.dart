import 'package:swiftdrop_driver_app/export.dart';

import '../modules/network_error/views/network_error_view.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isCompact;
  final bool isNetwork;

  const ErrorStateWidget({
    super.key,
    this.message,
    this.onRetry,
    this.isCompact = false,
    this.isNetwork = false,
  });

  factory ErrorStateWidget.network({VoidCallback? onRetry}) => ErrorStateWidget(
        message: 'No internet connection.\nPlease check your network.',
        onRetry: onRetry,
        isNetwork: true,
      );

  factory ErrorStateWidget.server({VoidCallback? onRetry}) => ErrorStateWidget(
        message: 'Something went wrong.\nPlease try again.',
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    if (isNetwork && !isCompact) {
      return NetworkErrorView(
        onReload: onRetry,
        isFullScreen: false,
      );
    }
    return isCompact ? _compact() : _full();
  }

  Widget _full() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withOpacity(0.15),
                ),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppColors.error.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.sp24),
            Text(
              'Oops!',
              style: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Text(
              message ?? 'Something went wrong. Please try again.',
              style: AppTextStyles.pSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.sp24),
              AppButton(
                label: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                prefixIcon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _compact() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.gapMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppDimensions.gapSm),
          Expanded(
            child: Text(
              message ?? 'Something went wrong.',
              style:
                  AppTextStyles.pXSmall.copyWith(color: AppColors.error),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 32),
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.pXSmallSemiBold
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
