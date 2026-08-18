import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_strings.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });
}

class OnboardingController extends BaseController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final pages = const [
    OnboardingPage(
      title: AppStrings.fastDeliveries,
      subtitle: AppStrings.earnOnSchedule,
      icon: Icons.delivery_dining_rounded,
      description: AppStrings.fastDeliveriesDesc,
    ),
    OnboardingPage(
      title: AppStrings.realTimeTracking,
      subtitle: AppStrings.alwaysKnowWhereToGo,
      icon: Icons.location_on_rounded,
      description: AppStrings.realTimeTrackingDesc,
    ),
    OnboardingPage(
      title: AppStrings.instantPayments,
      subtitle: AppStrings.getPaidAfterEveryDelivery,
      icon: Icons.account_balance_wallet_rounded,
      description: AppStrings.instantPaymentsDesc,
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void skipOnboarding() => completeOnboarding();

  void completeOnboarding() {
    StorageService.to.setOnboardingCompleted();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
