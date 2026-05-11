import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _EarningsShimmer();
        }
        return RefreshIndicator(
          onRefresh: controller.loadAll,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _BalanceCard(controller: controller),
                    _StatsRow(controller: controller),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingMd,
                        AppDimensions.paddingMd,
                        AppDimensions.paddingMd,
                        AppDimensions.gapSm,
                      ),
                      child: SectionHeader(
                        title: 'Transaction History',
                        actionLabel: 'See All',
                        onAction: () {},
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.transactions.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No transactions yet',
                    subtitle: 'Complete deliveries to see your transactions',
                    icon: Icons.receipt_long_rounded,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.transactions.length) {
                        return _TxLoadMoreFooter(controller: controller);
                      }
                      return _TransactionCard(
                          tx: controller.transactions[index]);
                    },
                    childCount: controller.transactions.length + 1,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Balance card ─────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final EarningsController controller;

  const _BalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: AppDecorations.gradientCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Balance',
            style:
                AppTextStyles.pSmallRegular.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: AppDimensions.gapSm),
          Obx(
            () => Text(
              AppUtils.formatCurrency(controller.totalBalance.value),
              style: AppTextStyles.h2Bold.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),
          Row(
            children: [
              _BalancePill(
                label: 'Today',
                amount: controller.todayEarnings.value,
              ),
              const SizedBox(width: AppDimensions.gapMd),
              _BalancePill(
                label: 'This Week',
                amount: controller.weekEarnings.value,
              ),
              const SizedBox(width: AppDimensions.gapMd),
              _BalancePill(
                label: 'This Month',
                amount: controller.monthEarnings.value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label;
  final double amount;

  const _BalancePill({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.gapSm,
          vertical: AppDimensions.gapXs,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: AppDecorations.cardDark.borderRadius,
        ),
        child: Column(
          children: [
            Text(AppUtils.formatCurrency(amount),
                style: AppTextStyles.pXSmallSemiBold
                    .copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppDimensions.gapXs),
            Text(label,
                style: AppTextStyles.pXSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final EarningsController controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Obx(
        () => Row(
          children: [
            _StatTile(
              label: "Today's Trips",
              value: '${controller.todayDeliveries.value}',
              icon: Icons.delivery_dining_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.gapMd),
            _StatTile(
              label: "Week's Trips",
              value: '${controller.weekDeliveries.value}',
              icon: Icons.calendar_today_rounded,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppDimensions.gapMd),
            _StatTile(
              label: 'Avg / Order',
              value: controller.weekDeliveries.value > 0
                  ? AppUtils.formatCurrency(controller.weekEarnings.value /
                      controller.weekDeliveries.value)
                  : '₹0',
              icon: Icons.trending_up_rounded,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.cardDark,
        child: Column(
          children: [
            Icon(icon, color: color, size: AppDimensions.iconSm),
            const SizedBox(height: AppDimensions.gapXs),
            Text(value,
                style: AppTextStyles.pSmallSemiBold.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppDimensions.gapXs),
            Text(label,
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction card ─────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const _TransactionCard({required this.tx});

  Color get _typeColor {
    if (!tx.isCredit) return AppColors.error;
    if (tx.isBonus) return AppColors.warning;
    return AppColors.success;
  }

  IconData get _typeIcon {
    if (!tx.isCredit) return Icons.remove_circle_rounded;
    if (tx.isBonus) return Icons.star_rounded;
    return Icons.local_shipping_rounded;
  }

  String get _typeLabel => tx.type.toUpperCase().replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.gapXs,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: AppDecorations.cardDark,
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarSm + 8,
            height: AppDimensions.avatarSm + 8,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon, color: _typeColor, size: AppDimensions.iconSm),
          ),
          const SizedBox(width: AppDimensions.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeLabel, style: AppTextStyles.pSmallSemiBold),
                const SizedBox(height: AppDimensions.gapXs),
                Text(
                  tx.note ?? '#${tx.orderId}',
                  style: AppTextStyles.pXSmall
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.gapXs),
                Text(
                  AppUtils.timeAgo(tx.createdAt),
                  style: AppTextStyles.pXSmall
                      .copyWith(color: AppColors.navyMuted400),
                ),
              ],
            ),
          ),
          Text(
            '${tx.isCredit ? '+' : '-'}${AppUtils.formatCurrency(tx.amount)}',
            style: AppTextStyles.pMediumSemiBold.copyWith(color: _typeColor),
          ),
        ],
      ),
    );
  }
}

class _TxLoadMoreFooter extends StatelessWidget {
  final EarningsController controller;

  const _TxLoadMoreFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
          child: Center(child: AppLoader()),
        );
      }
      return const SizedBox(height: AppDimensions.paddingXl);
    });
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class _EarningsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const ShimmerBanner(),
        const SizedBox(height: AppDimensions.gapMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
          child: Row(
            children: const [
              Expanded(child: ShimmerGridItem()),
              SizedBox(width: AppDimensions.gapMd),
              Expanded(child: ShimmerGridItem()),
              SizedBox(width: AppDimensions.gapMd),
              Expanded(child: ShimmerGridItem()),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.gapLg),
        ...List.generate(5, (_) => const ShimmerListItem()),
      ],
    );
  }
}
