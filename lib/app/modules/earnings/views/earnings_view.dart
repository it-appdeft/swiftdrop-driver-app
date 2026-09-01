import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/transaction_card.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(() {
          // If no transactions and no balance, show empty state (optional)
          // For the requested view, we show data.
          if (controller.transactions.isEmpty &&
              controller.totalBalance.value == 0 &&
              !controller.isLoading.value) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  AppStrings.earnings,
                  style: AppTextStyles.build(
                    size: 28,
                    weight: FontWeight.w700,
                    color: AppColors.navy900,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEarningsChartCard(),
                        const SizedBox(height: 24),
                        _buildTransactionHistoryHeader(),
                        const SizedBox(height: 16),
                        _buildTransactionList(),
                        const SizedBox(height: 100), // Bottom nav space
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEarningsChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: AppTextStyles.pMediumRegular.copyWith(
                  color: AppColors.otpSubtitle,
                ),
              ),
              _buildPeriodDropdown(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppUtils.formatCurrency(controller.totalBalance.value),
            style: AppTextStyles.build(
              size: 32,
              weight: FontWeight.w700,
              color: const Color(0xFF198754),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: AppTextStyles.build(
                  size: 10,
                  weight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 150,
                interval: 50,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: AppColors.stroke.withValues(alpha: 0.5),
                ),
                labelFormat: '£{value}',
                labelStyle: AppTextStyles.build(
                  size: 10,
                  weight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
              series: <CartesianSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: controller.chartData,
                  xValueMapper: (ChartData data, _) => data.day,
                  yValueMapper: (ChartData data, _) => data.amount,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  width: 0.4,
                  pointColorMapper: (ChartData data, _) =>
                      data.isHighlighted ? AppColors.primary : AppColors.navy900,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        controller.selectedPeriod.value = value;
      },
      color: const Color(0xFFEDEEF1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      constraints: const BoxConstraints(minWidth: 98),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'Today',
          height: 40,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              'Today',
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.otpSubtitle,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 1,
            color: AppColors.otpSubtitle.withValues(alpha: 0.1),
          ),
        ),
        PopupMenuItem<String>(
          value: 'This Week',
          height: 40,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              'This Week',
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.otpSubtitle,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.selectedPeriod.value,
              style: AppTextStyles.build(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.otpSubtitle,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.otpSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.transactionHistory,
            style: AppTextStyles.pLargeMedium.copyWith(
              color: AppColors.navy900,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.transactionHistory);
            },
            child: Text(
              'View All',
              style: AppTextStyles.pSmallSemiBold.copyWith(
                color: const Color(0xFF198754),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: controller.transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = controller.transactions[index];
        return TransactionCard(tx: tx);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.noEarningData.image(
            height: 128,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.noEarningsYet,
            style: AppTextStyles.pMediumMedium.copyWith(
              color: AppColors.navy900,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppStrings.earningsEmptyDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.pSmall.copyWith(
                color: AppColors.otpSubtitle,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AppButton(
              label: AppStrings.goOnline,
              onPressed: () {
                final dashCtrl = Get.find<DashboardController>();
                dashCtrl.toggleOnlineStatus();
                dashCtrl.currentIndex.value = 0;
              },
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
