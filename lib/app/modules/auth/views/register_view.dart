import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF1A1A2E)),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ─── Heading ───────────────────────────────────────────────────
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
                children: [
                  TextSpan(
                    text: 'Become ',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: 'A Delivery\nPartner',
                    style: TextStyle(color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Profile photo ─────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Full Name ─────────────────────────────────────────────────
            _FieldLabel('Full Name', required: true),
            _UnderlineField(
              controller: controller.nameController,
              hint: 'Enter Your Full Name',
            ),
            const SizedBox(height: 20),

            // ─── Email ─────────────────────────────────────────────────────
            _FieldLabel('Email Address', required: true),
            Obx(() {
              if (controller.emailVerified.value) {
                return _UnderlineField(
                  controller: controller.emailController,
                  hint: 'Enter your Email Address',
                  suffix: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('VERIFIED',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                  readOnly: true,
                );
              }
              return _UnderlineField(
                controller: controller.emailController,
                hint: 'Enter your Email Address',
                keyboardType: TextInputType.emailAddress,
                suffix: Obx(() => controller.isEmailOtpLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary))
                    : GestureDetector(
                        onTap: controller.sendEmailOtp,
                        child: const Text('VERIFY',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      )),
              );
            }),

            // Email OTP boxes
            Obx(() => controller.showEmailOtp.value
                ? _InlineOtpSection(
                    label:
                        "We've sent a 4-digit code to your email.",
                    otpControllers: controller.emailOtpControllers,
                    focusNodes: controller.emailOtpFocusNodes,
                    onChanged: controller.onEmailOtpChanged,
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 20),

            // ─── Mobile Number ─────────────────────────────────────────────
            _FieldLabel('Mobile Number', required: true),
            Obx(() {
              if (controller.phoneVerified.value) {
                return _PhoneField(
                  controller: controller.phoneController,
                  readOnly: true,
                  suffix: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('VERIFIED',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 16),
                    ],
                  ),
                );
              }
              return _PhoneField(
                controller: controller.phoneController,
                suffix: Obx(() => controller.isPhoneOtpLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary))
                    : GestureDetector(
                        onTap: controller.sendPhoneOtp,
                        child: const Text('Get OTP',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      )),
              );
            }),

            // Phone OTP boxes
            Obx(() => controller.showPhoneOtp.value
                ? _InlineOtpSection(
                    label: "We've sent a 4-digit code to your phone number.",
                    otpControllers: controller.phoneOtpControllers,
                    focusNodes: controller.phoneOtpFocusNodes,
                    onChanged: controller.onPhoneOtpChanged,
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            // ─── Register button ───────────────────────────────────────────
            Obx(() => _GreenButton(
                  label: 'Register',
                  isLoading: controller.isLoading.value,
                  onPressed:
                      controller.isLoading.value ? null : controller.register,
                )),
            const SizedBox(height: 20),

            // Login link
            Center(
              child: GestureDetector(
                onTap: () => Get.offNamed(AppRoutes.login),
                child: RichText(
                  text: TextSpan(
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey[600]),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Inline OTP section ───────────────────────────────────────────────────────

class _InlineOtpSection extends StatelessWidget {
  final String label;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onChanged;

  const _InlineOtpSection({
    required this.label,
    required this.otpControllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Verification Code',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SmallOtpBox(
                      controller: otpControllers[i],
                      focusNode: focusNodes[i],
                      autofocus: i == 0,
                      onChanged: (v) => onChanged(i, v),
                    ),
                  )),
              GestureDetector(
                onTap: () {},
                child: const Text('VERIFY',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallOtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const _SmallOtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Shared form widgets ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                  text: ' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _UnderlineField({
    required this.controller,
    required this.hint,
    this.suffix,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        suffix: suffix,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final Widget? suffix;
  final bool readOnly;

  const _PhoneField({required this.controller, this.suffix, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              const Text('🇬🇧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text('+44',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: Colors.grey[500]),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: '07700 000000',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              suffix: suffix,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GreenButton({required this.label, this.onPressed, this.isLoading = false});

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
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
