import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';

class VerificationPendingView extends StatelessWidget {
  const VerificationPendingView({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Clock icon in green circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 36),

            // Title
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
                children: [
                  TextSpan(
                    text: 'Document Verification\n',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  TextSpan(
                    text: 'In Progress',
                    style: TextStyle(color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Your submission is under review by our admin team. We'll update you as soon as the process is completed.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 2),

            // Go to Home button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
