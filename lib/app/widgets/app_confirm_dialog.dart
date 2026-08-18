import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import 'app_button.dart';

class AppConfirmDialog extends StatefulWidget {
  final bool isLogout;
  final VoidCallback? onConfirm;
  final Future<void> Function()? onConfirmAsync;

  const AppConfirmDialog({
    super.key,
    this.isLogout = true,
    this.onConfirm,
    this.onConfirmAsync,
  });

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();

  static void show({
    required bool isLogout,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
  }) {
    Get.bottomSheet(
      AppConfirmDialog(
        isLogout: isLogout,
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isLogout
                ? AppStrings.logoutConfirmTitle
                : AppStrings.deleteAccountConfirmTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.build(
              size: 24,
              height: 32,
              weight: FontWeight.w400,
              fontFamily: 'Helvetica Neue',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isLogout
                ? AppStrings.logoutConfirmDesc
                : AppStrings.deleteAccountConfirmDesc,
            textAlign: TextAlign.center,
            style: AppTextStyles.build(
              size: 14,
              height: 20,
              weight: FontWeight.w400,
              color: const Color(0xFF59677C),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.yes,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _onYesTapped,
                  backgroundColor: AppColors.primary,
                  borderRadius: 8,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: AppStrings.no,
                  onPressed: _isLoading ? null : () => Get.back(),
                  backgroundColor: const Color(0xFF949FB0),
                  borderRadius: 8,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onYesTapped() async {
    if (widget.onConfirmAsync != null) {
      setState(() => _isLoading = true);
      try {
        await widget.onConfirmAsync!();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      Get.back();
      widget.onConfirm?.call();
    }
  }
}
