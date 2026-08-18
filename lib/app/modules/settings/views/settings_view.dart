import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_decorations.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          // Notifications section
          _SectionLabel(AppStrings.notifications),
          const SizedBox(height: AppDimensions.gapSm),
          Container(
            decoration: AppDecorations.cardDark,
            child: Column(
              children: [
                Obx(
                  () => _ToggleTile(
                    icon: Icons.local_shipping_rounded,
                    label: AppStrings.orderNotifications,
                    subtitle: AppStrings.orderNotificationsDesc,
                    value: controller.orderNotifications.value,
                    onChanged: controller.setOrderNotifications,
                  ),
                ),
                _SettingsDivider(),
                Obx(
                  () => _ToggleTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: AppStrings.paymentNotifications,
                    subtitle: AppStrings.paymentNotificationsDesc,
                    value: controller.paymentNotifications.value,
                    onChanged: controller.setPaymentNotifications,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),

          // Privacy section
          _SectionLabel(AppStrings.privacyAndLocation),
          const SizedBox(height: AppDimensions.gapSm),
          Container(
            decoration: AppDecorations.cardDark,
            child: Column(
              children: [
                Obx(
                  () => _ToggleTile(
                    icon: Icons.location_on_rounded,
                    label: AppStrings.locationTracking,
                    subtitle: AppStrings.locationTrackingDesc,
                    value: controller.locationTracking.value,
                    onChanged: controller.setLocationTracking,
                  ),
                ),
                _SettingsDivider(),
                _ActionTile(
                  icon: Icons.privacy_tip_rounded,
                  label: AppStrings.privacyPolicy,
                  onTap: controller.openPrivacyPolicy,
                ),
                _SettingsDivider(),
                _ActionTile(
                  icon: Icons.description_rounded,
                  label: 'Terms & Conditions',
                  onTap: controller.openTermsAndConditions,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapLg),

          // General section
          _SectionLabel(AppStrings.general),
          const SizedBox(height: AppDimensions.gapSm),
          Container(
            decoration: AppDecorations.cardDark,
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.cleaning_services_rounded,
                  label: AppStrings.clearCache,
                  onTap: controller.clearCache,
                ),
                _SettingsDivider(),
                _ActionTile(
                  icon: Icons.headset_mic_rounded,
                  label: AppStrings.contactSupport,
                  onTap: controller.openSupport,
                ),
                _SettingsDivider(),
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.appVersion,
                  value: controller.appVersion,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXl),
        ],
      ),
    );
  }
}

// ─── Shared tiles ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.gapXs),
      child: Text(
        text,
        style: AppTextStyles.pXSmallSemiBold
            .copyWith(color: AppColors.textSecondary, letterSpacing: 0.8),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.darkBorder,
      height: 0,
      thickness: 0.5,
      indent: AppDimensions.paddingMd + AppDimensions.sp32 + AppDimensions.gapMd,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: AppDimensions.sp32,
        height: AppDimensions.sp32,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: AppDimensions.iconXs, color: AppColors.primary),
      ),
      title: Text(label, style: AppTextStyles.pSmallSemiBold),
      subtitle: Text(subtitle,
          style: AppTextStyles.pXSmall
              .copyWith(color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      leading: Container(
        width: AppDimensions.sp32,
        height: AppDimensions.sp32,
        decoration: BoxDecoration(
          color: AppColors.navyMuted600.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: AppDimensions.iconXs, color: AppColors.navyMuted200),
      ),
      title: Text(label, style: AppTextStyles.pSmallSemiBold),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.navyMuted400, size: AppDimensions.iconSm),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: AppDimensions.sp32,
        height: AppDimensions.sp32,
        decoration: BoxDecoration(
          color: AppColors.navyMuted600.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: AppDimensions.iconXs, color: AppColors.navyMuted200),
      ),
      title: Text(label, style: AppTextStyles.pSmallSemiBold),
      trailing: Text(value,
          style: AppTextStyles.pSmallRegular
              .copyWith(color: AppColors.textSecondary)),
    );
  }
}
