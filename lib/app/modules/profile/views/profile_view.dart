import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_loader.dart';
import '../../../widgets/info_row.dart';
import '../../../widgets/section_header.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: controller.navigateToEditProfile,
          ),
        ],
      ),
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) {
          return const Center(child: AppLoader());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingXl),
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: AppDimensions.gapMd),
              _StatsCard(user: user),
              const SizedBox(height: AppDimensions.gapMd),
              if (user.vehicleType != null || user.vehicleNumber != null) ...[
                _VehicleCard(user: user),
                const SizedBox(height: AppDimensions.gapMd),
              ],
              _MenuSection(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Profile header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXl),
      decoration: AppDecorations.headerGradient,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarLg / 2,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                backgroundImage: user.avatar != null
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'D',
                        style:
                            AppTextStyles.h3Bold.copyWith(color: AppColors.white),
                      )
                    : null,
              ),
              if (user.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.gapXs),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified,
                        color: AppColors.white, size: AppDimensions.iconXs),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.gapMd),
          Text(user.name,
              style: AppTextStyles.h5SemiBold.copyWith(color: AppColors.white)),
          const SizedBox(height: AppDimensions.gapXs),
          Text('+91 ${user.phone}',
              style: AppTextStyles.pSmallRegular
                  .copyWith(color: AppColors.white.withValues(alpha: 0.8))),
          if (user.email != null) ...[
            const SizedBox(height: AppDimensions.gapXs),
            Text(user.email!,
                style: AppTextStyles.pXSmall
                    .copyWith(color: AppColors.white.withValues(alpha: 0.7))),
          ],
          const SizedBox(height: AppDimensions.gapMd),
          _RatingRow(user: user),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final UserModel user;

  const _RatingRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (i) {
          final rating = user.rating ?? 0;
          return Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : i < rating
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            color: AppColors.warning,
            size: AppDimensions.iconSm,
          );
        }),
        const SizedBox(width: AppDimensions.gapXs),
        Text(
          '${(user.rating ?? 0).toStringAsFixed(1)} (${user.totalDeliveries} trips)',
          style: AppTextStyles.pXSmall
              .copyWith(color: AppColors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final UserModel user;

  const _StatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.cardDark,
        child: Row(
          children: [
            _StatItem(
              value: '${user.totalDeliveries}',
              label: 'Deliveries',
              icon: Icons.delivery_dining_rounded,
              color: AppColors.primary,
            ),
            _VerticalDivider(),
            _StatItem(
              value: (user.rating ?? 0).toStringAsFixed(1),
              label: 'Rating',
              icon: Icons.star_rounded,
              color: AppColors.warning,
            ),
            _VerticalDivider(),
            _StatItem(
              value: AppUtils.formatCurrency(user.walletBalance),
              label: 'Wallet',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: AppDimensions.sp40,
      color: AppColors.darkBorder,
    );
  }
}

// ─── Vehicle card ─────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final UserModel user;

  const _VehicleCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: AppDecorations.cardDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Vehicle Info'),
            const SizedBox(height: AppDimensions.gapLg),
            InfoRow(
              label: 'Vehicle Type',
              value: user.vehicleType?.toUpperCase() ?? '—',
              icon: Icons.two_wheeler_rounded,
            ),
            if (user.vehicleNumber != null)
              InfoRow(
                label: 'Vehicle Number',
                value: user.vehicleNumber!.toUpperCase(),
                icon: Icons.pin_rounded,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu section ─────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final ProfileController controller;

  const _MenuSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Container(
        decoration: AppDecorations.cardDark,
        child: Column(
          children: [
            _MenuItem(
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              onTap: controller.navigateToEditProfile,
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.notifications_rounded,
              label: 'Notifications',
              onTap: controller.navigateToNotifications,
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: controller.navigateToSettings,
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.headset_mic_rounded,
              label: 'Support',
              onTap: controller.navigateToSupport,
            ),
            _Divider(),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: AppColors.error,
              onTap: controller.logout,
              showChevron: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showChevron;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: AppDimensions.sp32,
        height: AppDimensions.sp32,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppDimensions.iconXs, color: c),
      ),
      title: Text(label, style: AppTextStyles.pSmallSemiBold.copyWith(color: c)),
      trailing: showChevron
          ? Icon(Icons.chevron_right_rounded,
              color: AppColors.navyMuted400, size: AppDimensions.iconSm)
          : null,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        color: AppColors.darkBorder, height: 0, thickness: 0.5,
        indent: AppDimensions.paddingXl + AppDimensions.paddingMd);
  }
}
