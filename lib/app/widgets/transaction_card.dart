import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../generated/assets.dart';
import '../routes/app_routes.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const TransactionCard({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(AppRoutes.payoutReceipt, arguments: tx);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Assets.images.transactionHistory.image(
              width: 44,
              height: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount Received',
                    style: AppTextStyles.pMediumRegular.copyWith(
                      color: AppColors.navy900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Apr 24, 2026 • 09:15 AM',
                    style: AppTextStyles.pSmallRegular.copyWith(
                      color: AppColors.otpSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '£${tx.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.build(
                    size: 20,
                    weight: FontWeight.w500,
                    color: const Color(0xFF198754),
                    fontFamily: 'Helvetica Neue',
                    height: 28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PAYOUT',
                  style: AppTextStyles.build(
                    size: 10,
                    weight: FontWeight.w400,
                    color: AppColors.otpSubtitle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
