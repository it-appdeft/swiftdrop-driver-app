import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      title: 'Fast Deliveries',
      subtitle: 'Earn on your schedule',
      icon: Icons.delivery_dining_rounded,
      description:
          'Accept orders near you and deliver them quickly. The faster you deliver, the more you earn.',
    ),
    OnboardingPage(
      title: 'Real-time Tracking',
      subtitle: 'Always know where to go',
      icon: Icons.location_on_rounded,
      description:
          'Get turn-by-turn navigation for every delivery. Never get lost with our smart routing system.',
    ),
    OnboardingPage(
      title: 'Instant Payments',
      subtitle: 'Get paid after every delivery',
      icon: Icons.account_balance_wallet_rounded,
      description:
          'Your earnings are credited instantly after each delivery. Withdraw anytime to your bank account.',
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
