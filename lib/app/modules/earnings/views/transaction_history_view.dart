import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/transaction_card.dart';
import '../controllers/earnings_controller.dart';

class TransactionHistoryView extends GetView<EarningsController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.transactionHistory,
          style: AppTextStyles.pLargeMedium.copyWith(
            color: AppColors.navy900,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.transactions.isEmpty) {
          return const Center(child: Text(AppStrings.noTransactionsYet));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
          itemCount: controller.transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            return TransactionCard(tx: tx);
          },
        );
      }),
    );
  }
}
