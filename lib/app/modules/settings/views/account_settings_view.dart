import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/assets.dart';
import '../../../constants/app_strings.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../controllers/settings_controller.dart';

class AccountSettingsView extends GetView<SettingsController> {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.accountSetting,
          style: AppTextStyles.build(
            size: 18,
            weight: FontWeight.w500,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 2,
              separatorBuilder: (_, __) => const Divider(
                height: 24,
                thickness: 0.5,
                color: AppColors.lightBorder,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Obx(() => _SettingTile(
                        icon: Assets.images.deliveryUpdates,
                        label: AppStrings.deliveryUpdates,
                        value: controller.deliveryUpdates.value,
                        onChanged: controller.setDeliveryUpdates,
                      ));
                }
                return Obx(() => _SettingTile(
                      icon: Assets.images.notification,
                      label: AppStrings.notification,
                      value: controller.notifications.value,
                      onChanged: controller.setNotifications,
                    ));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: AppButton(
              label: AppStrings.deleteAccount,
              backgroundColor: AppColors.deleteRed,
              prefixIcon: Assets.images.deleteaccount.image(
                width: 16,
                height: 16,
                color: Colors.white,
              ),
              onPressed: controller.showDeletionReasonsModal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final AssetGenImage icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          icon.image(
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.build(
                size: 16,
                weight: FontWeight.w400,
                color: const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.primary,
              activeColor: Colors.white,
              inactiveTrackColor: const Color(0xFF949FB0),
              inactiveThumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
