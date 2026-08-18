import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../generated/assets.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  const AppAppBar({
    super.key,
    this.title = '',
    this.onBack,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? Get.back,
              icon: Assets.images.backIcon.image(width: 24, height: 24),
            )
          : null,
      centerTitle: true,
      title: title.isEmpty
          ? null
          : Text(
              title,
              style: AppTextStyles.pLargeMedium.copyWith(
                color: AppColors.otpTitle,
              ),
            ),
    );
  }
}
