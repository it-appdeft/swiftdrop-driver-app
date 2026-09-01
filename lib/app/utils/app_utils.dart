import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class AppUtils {
  AppUtils._();

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = AppConfig.imageUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$base$cleanPath';
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      showWarning('Phone number not available');
      return;
    }
    final Uri uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      showError('Could not launch dialer for $cleanPhone');
    }
  }

  // ─── Snackbars ─────────────────────────────────────────────────────────────

  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      icon: const Icon(Icons.check_circle, color: AppColors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      icon: const Icon(Icons.error, color: AppColors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Warning',
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(message, style: AppTextStyles.bodyMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: isDangerous
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Formatting ─────────────────────────────────────────────────────────────

  static String formatCurrency(double amount, {String symbol = '£'}) =>
      '$symbol${NumberFormat('#,##0.00').format(amount)}';

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  static String formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  static String formatDateTime(DateTime dateTime) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

  static String formatTime(DateTime dateTime) =>
      DateFormat('hh:mm a').format(dateTime);

  static String formatDate(DateTime dateTime) =>
      DateFormat('dd MMM yyyy').format(dateTime);

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ─── Validation ─────────────────────────────────────────────────────────────

  static bool isValidPhone(String phone) =>
      RegExp(r'^07\d{9}$').hasMatch(phone.replaceAll(RegExp(r'\s'), ''));

  static bool isValidEmail(String email) =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  // ─── Misc ───────────────────────────────────────────────────────────────────

  static void hideKeyboard() =>
      FocusManager.instance.primaryFocus?.unfocus();

  static Color orderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        return AppColors.statusNew;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'picked_up':
        return AppColors.statusPickedUp;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }
}
