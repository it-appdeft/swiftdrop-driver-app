import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/responsive.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── Hero ────────────────────────────────────────────────────────
          SizedBox(
            height: size.height * 0.42,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/login_bg.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: Responsive.h(28),
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'SwiftDrop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.sp(28),
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: Responsive.h(4)),
                      Text(
                        'Driver Partner App',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: Responsive.sp(13),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: Responsive.h(4)),
                      Text(
                        '🇬🇧 United Kingdom',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: Responsive.sp(11),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── White card ───────────────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXxl),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(24),
                  Responsive.h(32),
                  Responsive.w(24),
                  Responsive.h(24) + bottomPad,
                ),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: Responsive.sp(26),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: Responsive.h(6)),
                      Text(
                        'Enter your mobile number to continue',
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: Responsive.h(32)),

                      _AuthLabel('Mobile Number'),
                      SizedBox(height: Responsive.h(8)),
                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: controller.onPhoneChanged,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter phone number';
                          }
                          if (!AppUtils.isValidPhone(v)) {
                            return 'Enter a valid UK mobile number (e.g. 07700 000000)';
                          }
                          return null;
                        },
                        style: TextStyle(
                          fontSize: Responsive.sp(14),
                          color: const Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(12),
                              vertical: Responsive.h(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🇬🇧',
                                  style: TextStyle(fontSize: Responsive.sp(18)),
                                ),
                                SizedBox(width: Responsive.w(6)),
                                Text(
                                  '+44',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: Responsive.sp(14),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(8)),
                                Container(
                                  width: 1,
                                  height: Responsive.h(20),
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                          hintText: '07700 000000',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: Responsive.sp(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(16),
                            vertical: Responsive.h(16),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.h(28)),

                      Obx(
                        () => _GreenButton(
                          label: 'Sign In',
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.sendOtp,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                      SizedBox(height: Responsive.h(24)),

                      Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: Responsive.sp(14),
                                color: Colors.grey[600],
                              ),
                              children: const [
                                TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Register',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared auth widgets ───────────────────────────────────────────────────────

class _AuthLabel extends StatelessWidget {
  final String text;
  const _AuthLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: Responsive.sp(13),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      );
}

class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GreenButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: Responsive.w(22),
                height: Responsive.w(22),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
