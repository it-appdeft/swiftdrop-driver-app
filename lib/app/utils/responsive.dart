import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive {
  Responsive._();

  static double get width {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final w = views.first.physicalSize.width / views.first.devicePixelRatio;
        if (w > 0) return w;
      }
      // Fallback to GetX if PlatformDispatcher fails
      final getWidth = Get.width;
      if (getWidth > 0) return getWidth;
    } catch (_) {}
    return 375.0;
  }

  static double get height {
    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final h = views.first.physicalSize.height / views.first.devicePixelRatio;
        if (h > 0) return h;
      }
      // Fallback to GetX if PlatformDispatcher fails
      final getHeight = Get.height;
      if (getHeight > 0) return getHeight;
    } catch (_) {}
    return 812.0;
  }

  static double get statusBarHeight {
    try {
      return Get.statusBarHeight;
    } catch (_) {
      return 0.0;
    }
  }

  static double get bottomBarHeight {
    try {
      return Get.bottomBarHeight;
    } catch (_) {
      return 0.0;
    }
  }

  static bool get isMobile => width < 600;
  static bool get isTablet => width >= 600 && width < 1024;
  static bool get isDesktop => width >= 1024;

  // Responsive value selector
  static T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // Scale dimensions relative to 375px design width
  static double w(double pixels) => width * (pixels / 375);
  static double h(double pixels) => height * (pixels / 812);

  // Adaptive font size
  static double sp(double size) => size * (width / 375).clamp(0.85, 1.3);

  // Percentage based
  static double wp(double percent) => width * percent / 100;
  static double hp(double percent) => height * percent / 100;

  // Safe padding shortcut
  static EdgeInsets get safeArea => EdgeInsets.only(
        top: statusBarHeight,
        bottom: bottomBarHeight,
      );
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double xs      = 320;
  static const double sm      = 480;
  static const double mobile  = 600;
  static const double tablet  = 1024;
  static const double desktop = 1200;
}

extension ContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;
}
