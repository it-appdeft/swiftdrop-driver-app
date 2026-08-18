import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../../services/storage_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_dimensions.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_info_card.dart';
import '../../../../data/local/app_data.dart';
import '../../../../data/models/driver_dashboard_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/driver_repository.dart';
import '../../../../data/repositories/order_repository.dart';

class DashboardController extends BaseController {
  final OrderRepository _repo;
  final DriverRepository _driverRepo;

  DashboardController(this._repo, this._driverRepo);

  // ─── Navigation ────────────────────────────────────────────────────────────

  final currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;

  // ─── Back Press Handling & Exit Confirmation ──────────────────────────────

  void handleBackPress() {
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return;
    }
    showExitAppDialog();
  }

  void showExitAppDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exit Application',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navy900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to exit SwiftDrop Driver?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    onPressed: () => Get.back(),
                    backgroundColor: AppColors.infoBoxBg,
                    textColor: AppColors.navy900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Exit',
                    backgroundColor: AppColors.deleteRed,
                    onPressed: () {
                      Get.back();
                      SystemNavigator.pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── User & Dashboard Status ───────────────────────────────────────────────

  UserModel? get user => AuthService.to.user;

  final approvalStatus = 'approved'.obs; // "approved" | "pending" | "rejected"
  final isSetupComplete = true.obs;
  final isOnline = false.obs;
  final isOnDelivery = false.obs;

  final todayEarnings = 0.0.obs;
  final totalDeliveries = 0.obs;
  final timeOnlineMinutes = 0.obs;
  final rating = 0.0.obs;

  final currentLocationAddress = 'Fetching location...'.obs;
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;

  // ─── Dashboard API Fetch ───────────────────────────────────────────────────

  Future<void> fetchDashboardData() async {
    try {
      final response = await _driverRepo.getDashboard();
      if (response.success && response.data != null) {
        final data = response.data!;
        approvalStatus.value = data.approvalStatus;
        isSetupComplete.value = data.isSetupComplete;
        isOnline.value = data.isOnline;
        StorageService.to.setOnlineMode(data.isOnline);

        if (data.earnings != null) {
          todayEarnings.value = data.earnings!.today;
        }
        totalDeliveries.value = data.deliveriesToday;
        timeOnlineMinutes.value = data.timeOnlineMinutes;

        if (data.currentLocation != null) {
          currentLat.value = data.currentLocation!.lat;
          currentLng.value = data.currentLocation!.lng;
          _updateAddressFromCoordinates(data.currentLocation!.lat, data.currentLocation!.lng);
        }

        // Only fetch delivery requests if driver is approved and online
        if (approvalStatus.value.toLowerCase() == 'approved' && isOnline.value) {
          loadDeliveryRequests();
        } else {
          activeOrders.clear();
        }
      }
    } catch (e) {
      // Fallback to local storage mode if API request fails initially
      isOnline.value = StorageService.to.isOnlineMode;
    }
  }

  // ─── Online Toggle with Approval Status Check ─────────────────────────────

  Future<void> toggleOnlineStatus() async {
    // 1. Check driver approval status first
    if (approvalStatus.value.toLowerCase() != 'approved') {
      showVerificationPendingDialog();
      return;
    }

    // 2. Perform API call to toggle availability
    final nextStatus = !isOnline.value;
    final availabilityString = nextStatus ? 'online' : 'offline';

    await runAsync(() async {
      final result = await _driverRepo.toggleAvailability(availabilityString);
      if (result.success) {
        isOnline.value = nextStatus;
        StorageService.to.setOnlineMode(nextStatus);
        if (nextStatus && approvalStatus.value.toLowerCase() == 'approved') {
          loadDeliveryRequests();
        } else {
          activeOrders.clear();
        }
        AppUtils.showSuccess(
          nextStatus ? 'You are now online' : 'You are now offline',
        );
      } else {
        AppUtils.showError(result.message.isNotEmpty
            ? result.message
            : 'Failed to update online status');
      }
    }, showLoadingIndicator: true);
  }

  void showVerificationPendingDialog() {
    Get.dialog(
      Dialog(
        alignment: Alignment.center,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: StatusInfoCard(
          type: StatusInfoType.verificationPending,
          onButtonPressed: () => Get.back(),
          showBackground: true,
          width: double.infinity,
        ),
      ),
    );
  }

  // ─── Location Access & Continuous Updates ──────────────────────────────────

  Future<void> refreshLocation({bool showDialog = false}) async {
    final pos = await LocationService.to.getCurrentLocation(showDialogIfDenied: showDialog);
    if (pos != null) {
      currentLat.value = pos.latitude;
      currentLng.value = pos.longitude;
      _updateAddressFromCoordinates(pos.latitude, pos.longitude);
      await sendLocationUpdate(pos.latitude, pos.longitude);
    }
  }

  Future<void> onLocationHeaderTap() async {
    AppUtils.showInfo('Updating your live location...');
    final pos = await LocationService.to.getCurrentLocation(showDialogIfDenied: true);
    if (pos != null) {
      currentLat.value = pos.latitude;
      currentLng.value = pos.longitude;
      _updateAddressFromCoordinates(pos.latitude, pos.longitude);
      await sendLocationUpdate(pos.latitude, pos.longitude);
      AppUtils.showSuccess('Location updated!');
    }
  }

  Future<void> initLocationFlow() async {
    await refreshLocation(showDialog: true);

    // Subscribe to continuous location updates when position changes
    LocationService.to.startLocationUpdates((newPos) {
      currentLat.value = newPos.latitude;
      currentLng.value = newPos.longitude;
      _updateAddressFromCoordinates(newPos.latitude, newPos.longitude);
      sendLocationUpdate(newPos.latitude, newPos.longitude);
    });
  }

  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return;
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
        },
        options: Options(
          headers: {'User-Agent': 'SwiftDropDriverApp/1.0'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      if (response.data != null && response.data['address'] != null) {
        final addr = response.data['address'];
        final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['suburb'] ?? addr['county'] ?? '';
        final state = addr['state'] ?? addr['country'] ?? '';
        final road = addr['road'] ?? addr['neighbourhood'] ?? addr['residential'] ?? '';

        final List<String> parts = [];
        if (road.toString().isNotEmpty) parts.add(road.toString());
        if (city.toString().isNotEmpty) parts.add(city.toString());
        if (state.toString().isNotEmpty) parts.add(state.toString());

        if (parts.isNotEmpty) {
          currentLocationAddress.value = parts.join(', ');
          return;
        }
      }
    } catch (_) {}
    currentLocationAddress.value = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  Future<void> sendLocationUpdate(double lat, double lng) async {
    try {
      await _driverRepo.updateLocation(lat: lat, lng: lng);
    } catch (_) {
      // Silent error on location sync background request
    }
  }

  // ─── Active orders / Delivery Requests ─────────────────────────────────────

  final activeOrders = <OrderModel>[].obs;
  Timer? _pollTimer;

  Future<void> loadDeliveryRequests() async {
    // Only hit delivery requests endpoint when approved AND online
    if (approvalStatus.value.toLowerCase() != 'approved' || !isOnline.value) {
      activeOrders.clear();
      return;
    }
    await runAsync(() async {
      try {
        final result = await _repo.getDeliveryRequests();
        if (result.success && result.data != null) {
          activeOrders.value = result.data!;
        }
      } catch (_) {
        activeOrders.clear();
      }
    }, showLoadingIndicator: false);
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _silentRefresh(),
    );
  }

  Future<void> _silentRefresh() async {
    if (!isConnected || isLoading.value) return;
    if (approvalStatus.value.toLowerCase() != 'approved' || !isOnline.value) return;
    try {
      final result = await _repo.getDeliveryRequests();
      if (result.success && result.data != null) {
        final currentIds = activeOrders.map((o) => o.id).toSet();
        final newOrders = result.data!.where((o) => !currentIds.contains(o.id));
        if (newOrders.isNotEmpty) {
          activeOrders.addAll(newOrders);
        }
      }
    } catch (_) {
      // Silent fail on background refresh
    }
  }

  // ─── User Stats ────────────────────────────────────────────────────────────

  void _loadUserStats() {
    final u = user;
    if (u == null) return;
    totalDeliveries.value = u.totalDeliveries;
    rating.value = u.rating ?? 0.0;
    todayEarnings.value =
        (AppData.earningsSummary['today'] as num?)?.toDouble() ?? 0.0;
  }

  // ─── Order actions ─────────────────────────────────────────────────────────

  Future<void> acceptOrder(String orderId) async {
    await runAsync(() async {
      final result = await _repo.acceptOrder(orderId);
      if (result.success) {
        AppUtils.showSuccess(AppConstants.orderAccepted);
        final idx = activeOrders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          activeOrders[idx] = activeOrders[idx].copyWith(
            status: 'accepted',
            acceptedAt: DateTime.now(),
          );
          Get.toNamed('/active-delivery', arguments: activeOrders[idx]);
        }
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
  }

  Future<void> rejectOrder(String orderId) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Reject Order',
      message: 'Are you sure you want to reject this order?',
      confirmText: 'Reject',
      isDangerous: true,
    );
    if (!confirmed) return;

    await runAsync(() async {
      final result = await _repo.rejectOrder(orderId);
      if (result.success) {
        AppUtils.showInfo(AppConstants.orderRejected);
        activeOrders.removeWhere((o) => o.id == orderId);
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    isOnline.value = StorageService.to.isOnlineMode;
    isOnDelivery.value = false;
    _loadUserStats();
    fetchDashboardData();
    initLocationFlow();
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    LocationService.to.stopLocationUpdates();
    super.onClose();
  }
}
