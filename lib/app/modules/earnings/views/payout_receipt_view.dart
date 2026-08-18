import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_app_bar.dart';

class PayoutReceiptView extends StatelessWidget {
  const PayoutReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded static data for UI testing
    const String txId = 'T169842147924784';
    const String formattedDate = 'Apr 24, 2026';
    const double amount = 128.17;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        title: AppStrings.payoutReceipt,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AmountCard(amount: amount),
            const SizedBox(height: 16),
            const _InfoRow(label: AppStrings.date, value: formattedDate),
            const SizedBox(height: 12),
            const _InfoRow(label: AppStrings.transactionId, value: txId),
            const SizedBox(height: 16),
            const _BreakdownCard(amount: amount),
            const SizedBox(height: 16),
            _SupportCard(),
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final double amount;
  const _AmountCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Assets.images.payoutRecipt.image(
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.totalPayout,
            style: AppTextStyles.pMediumRegular.copyWith(
              color: AppColors.otpSubtitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '£$amount',
            textAlign: TextAlign.center,
            style: AppTextStyles.build(
              size: 32,
              weight: FontWeight.w700,
              color: const Color(0xFF198754),
              fontFamily: 'Helvetica Neue',
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.pSmallMedium.copyWith(
              color: AppColors.otpSubtitle,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.pSmallMedium.copyWith(
                color: AppColors.navy900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double amount;
  const _BreakdownCard({required this.amount});

  @override
  Widget build(BuildContext context) {
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
            AppStrings.earningBreakdown,
            style: AppTextStyles.pMediumMedium.copyWith(
              color: AppColors.navy900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalDeliveries,
                style: AppTextStyles.pSmallRegular.copyWith(
                  color: AppColors.otpSubtitle,
                ),
              ),
              Text(
                '1',
                style: AppTextStyles.pSmallSemiBold.copyWith(
                  color: AppColors.otpSubtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalPayout,
                style: AppTextStyles.pMediumRegular.copyWith(
                  color: AppColors.navy900,
                ),
              ),
              Text(
                '£$amount',
                style: AppTextStyles.pMediumSemiBold.copyWith(
                  color: AppColors.navy900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.04),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Assets.images.needHelp.image(
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.needHelpWithPayout,
                    style: AppTextStyles.pSmallSemiBold.copyWith(
                      color: AppColors.navy900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.contactSupportHint,
                    style: AppTextStyles.pXSmall.copyWith(
                      color: AppColors.otpSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.otpSubtitle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
