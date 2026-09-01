import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../active_delivery/controllers/delivery_verification_controller.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../../services/realtime_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_logger.dart';
import '../../../widgets/order_request_card.dart';
import '../../../themes/app_colors.dart';

import '../../../themes/app_text_styles.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/status_info_card.dart';
import '../../../../data/local/app_data.dart';

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

  void changeTab(int index) {
    currentIndex.value = index;
    if (approvalStatus.value.toLowerCase() == 'approved' && isOnline.value) {
      if (!isOnDelivery.value) {
        loadDeliveryRequests();
      }
    }
  }

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

  final approvalStatus = 'pending'.obs; // "approved" | "pending" | "rejected"
  final isSetupComplete = false.obs;
  final isOnline = false.obs;
  final isOnDelivery = false.obs;
  final currentActiveOrder = Rxn<OrderModel>();

  final todayEarnings = 0.0.obs;
  final totalDeliveries = 0.obs;
  RxInt get deliveriesToday => totalDeliveries;
  final timeOnlineMinutes = 0.obs;
  final rating = 0.0.obs;
  final deliveryRequestTimeoutSeconds = 30.obs;

  final currentLocationAddress = 'Fetching location...'.obs;
  final currentLat = 30.7046486.obs;
  final currentLng = 76.7178726.obs;

  // ─── Dashboard API Fetch ───────────────────────────────────────────────────

  Future<void> fetchDashboardData() async {
    try {
      final response = await _driverRepo.getDashboard();
      if (response.success && response.data != null) {
        final data = response.data!;
        approvalStatus.value = data.approvalStatus;
        isSetupComplete.value = data.isSetupComplete;
        
        final isApproved = data.approvalStatus.toLowerCase() == 'approved';
        final effectiveOnline = isApproved && data.isOnline;
        isOnline.value = effectiveOnline;
        deliveryRequestTimeoutSeconds.value = data.deliveryRequestTimeoutSeconds;
        StorageService.to.setOnlineMode(effectiveOnline);

        if (data.earnings != null) {
          todayEarnings.value = data.earnings!.today;
        }
        totalDeliveries.value = data.deliveriesToday;
        timeOnlineMinutes.value = data.timeOnlineMinutes;

        // Fetch current active order from GET /api/driver/deliveries/current-active only when online
        if (data.isOnline && data.approvalStatus.toLowerCase() == 'approved') {
          await fetchCurrentActiveDelivery();
        } else {
          isOnDelivery.value = false;
          currentActiveOrder.value = null;
        }

        // ─── STATIC TEST LOCATION (Active for testing) ─────────────────────
        currentLat.value = 30.7046486;
        currentLng.value = 76.7178726;
        _updateAddressFromCoordinates(30.7046486, 76.7178726);

        /*
        // ─── ACTUAL PRODUCTION LIVE LOCATION (Uncomment when ready) ────────
        if (data.currentLocation != null) {
          currentLat.value = data.currentLocation!.lat;
          currentLng.value = data.currentLocation!.lng;
          _updateAddressFromCoordinates(data.currentLocation!.lat, data.currentLocation!.lng);
        }
        */

        // Load delivery requests once on dashboard refresh if approved and online
        if (approvalStatus.value.toLowerCase() == 'approved' && isOnline.value) {
          if (!isOnDelivery.value) {
            loadDeliveryRequests();
          } else {
            activeOrders.clear();
          }
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

  final isTogglingOnline = false.obs;

  Future<void> toggleOnlineStatus() async {
    if (isTogglingOnline.value) return;

    // 1. Check driver approval status first
    if (approvalStatus.value.toLowerCase() != 'approved') {
      showVerificationPendingDialog();
      return;
    }

    // 2. Perform API call to toggle availability
    final nextStatus = !isOnline.value;
    final availabilityString = nextStatus ? 'online' : 'offline';

    isTogglingOnline.value = true;

    try {
      final result = await _driverRepo.toggleAvailability(availabilityString);
      if (result.success) {
        isOnline.value = nextStatus;
        StorageService.to.setOnlineMode(nextStatus);
        if (nextStatus && approvalStatus.value.toLowerCase() == 'approved') {
          await fetchCurrentActiveDelivery();
          sendLocationUpdate(30.7046486, 76.7178726);
          if (!isOnDelivery.value) {
            loadDeliveryRequests();
          } else {
            activeOrders.clear();
          }
        } else {
          _shownDialogOrderIds.clear();
          activeOrders.clear();
          isOnDelivery.value = false;
          currentActiveOrder.value = null;
        }
        AppUtils.showSuccess(
          nextStatus ? 'You are now online' : 'You are now offline',
        );
      } else {
        AppUtils.showError(result.message.isNotEmpty
            ? result.message
            : 'Failed to update online status');
      }
    } catch (e) {
      AppUtils.showError('Unable to connect. Please check your internet connection.');
    } finally {
      isTogglingOnline.value = false;
    }
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

  Timer? _locationTimer;

  Future<void> refreshLocation({bool showDialog = false}) async {
    // ─── STATIC TEST LOCATION ───
    currentLat.value = 30.7046486;
    currentLng.value = 76.7178726;
    _updateAddressFromCoordinates(30.7046486, 76.7178726);
    await sendLocationUpdate(30.7046486, 76.7178726);

    /*
    // ─── ACTUAL PRODUCTION LIVE LOCATION (Uncomment when ready) ───
    final pos = await LocationService.to.getCurrentLocation(showDialogIfDenied: showDialog);
    if (pos != null) {
      currentLat.value = pos.latitude;
      currentLng.value = pos.longitude;
      _updateAddressFromCoordinates(pos.latitude, pos.longitude);
      await sendLocationUpdate(pos.latitude, pos.longitude);
    }
    */
  }

  Future<void> onLocationHeaderTap() async {
    AppUtils.showInfo('Updating location...');
    currentLat.value = 30.7046486;
    currentLng.value = 76.7178726;
    _updateAddressFromCoordinates(30.7046486, 76.7178726);
    await sendLocationUpdate(30.7046486, 76.7178726);
    AppUtils.showSuccess('Location updated!');

    /*
    // ─── ACTUAL PRODUCTION LIVE LOCATION (Uncomment when ready) ───
    final pos = await LocationService.to.getCurrentLocation(showDialogIfDenied: true);
    if (pos != null) {
      currentLat.value = pos.latitude;
      currentLng.value = pos.longitude;
      _updateAddressFromCoordinates(pos.latitude, pos.longitude);
      await sendLocationUpdate(pos.latitude, pos.longitude);
      AppUtils.showSuccess('Location updated!');
    }
    */
  }

  Future<void> initLocationFlow() async {
    // ─── STATIC TEST LOCATION ───
    currentLat.value = 30.7046486;
    currentLng.value = 76.7178726;
    _updateAddressFromCoordinates(30.7046486, 76.7178726);
    await sendLocationUpdate(30.7046486, 76.7178726);

    /*
    // ─── ACTUAL PRODUCTION LIVE LOCATION & STREAM (Uncomment when ready) ───
    await refreshLocation(showDialog: true);

    LocationService.to.startLocationUpdates((newPos) {
      currentLat.value = newPos.latitude;
      currentLng.value = newPos.longitude;
      _updateAddressFromCoordinates(newPos.latitude, newPos.longitude);
      sendLocationUpdate(newPos.latitude, newPos.longitude);
    });

    if (approvalStatus.value.toLowerCase() == 'approved' && isOnline.value) {
      _startLocationTimer();
    }
    */
  }

  void _startLocationTimer() {
    /*
    // ─── ACTUAL PRODUCTION 5-SECOND LOCATION TIMER (Uncomment when ready) ───
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _sendPeriodicLocationUpdate(),
    );
    */
  }

  Future<void> _sendPeriodicLocationUpdate() async {
    /*
    // ─── ACTUAL PRODUCTION PERIODIC LOCATION UPDATE (Uncomment when ready) ───
    if (approvalStatus.value.toLowerCase() != 'approved' || !isOnline.value) return;
    try {
      final pos = await LocationService.to.getCurrentLocation(showDialogIfDenied: false);
      if (pos != null) {
        currentLat.value = pos.latitude;
        currentLng.value = pos.longitude;
        await sendLocationUpdate(pos.latitude, pos.longitude);
      } else if (currentLat.value != 0.0 && currentLng.value != 0.0) {
        await sendLocationUpdate(currentLat.value, currentLng.value);
      }
    } catch (_) {}
    */
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
  final Set<String> _shownDialogOrderIds = <String>{};

  Future<void> loadDeliveryRequests() async {
    final isApproved = approvalStatus.value.toLowerCase() == 'approved';
    // Only hit delivery requests endpoint when approved, online, and NOT actively on delivery
    if (!isApproved || !isOnline.value || isOnDelivery.value) {
      if (!isOnline.value || isOnDelivery.value) {
        activeOrders.clear();
      }
      return;
    }
    await runAsync(() async {
      try {
        final result = await _repo.getDeliveryRequests();
        if (result.success && result.data != null) {
          activeOrders.value = result.data!;
          _checkAndShowNewOrderDialog(result.data!);
        }
      } catch (_) {
        activeOrders.clear();
      }
    }, showLoadingIndicator: false);
  }

  Future<void> fetchCurrentActiveDelivery() async {
    final isApproved = approvalStatus.value.toLowerCase() == 'approved';
    if (!isOnline.value || !isApproved) {
      isOnDelivery.value = false;
      currentActiveOrder.value = null;
      return;
    }
    try {
      final res = await _repo.getCurrentActiveDelivery();
      if (res.success && res.data != null && res.data!.isAssignedToDriver) {
        isOnDelivery.value = true;
        currentActiveOrder.value = res.data;
        activeOrders.clear();

        // If the current-active response is lightweight (missing full pickup address), enrich it in background
        if (res.data!.pickupAddress.isEmpty) {
          try {
            final detailRes = await _repo.getOrderDetail(res.data!.id);
            if (detailRes.success && detailRes.data != null) {
              currentActiveOrder.value = detailRes.data;
            }
          } catch (_) {}
        }
      } else {
        isOnDelivery.value = false;
        currentActiveOrder.value = null;
      }
    } catch (_) {
      // Silent catch on active order sync
    }
  }

  void _checkAndShowNewOrderDialog(List<OrderModel> orders) {
    if (orders.isEmpty) {
      _shownDialogOrderIds.clear();
      return;
    }
    if (isOnDelivery.value || currentActiveOrder.value != null) return;

    // Prune IDs that no longer exist in incoming orders list
    _shownDialogOrderIds.removeWhere((id) => !orders.any((o) => o.id == id));

    // Find the first brand new / unassigned order that has not been shown in popup dialog yet
    final newOrder = orders.firstWhereOrNull(
      (o) => o.isNew && !_shownDialogOrderIds.contains(o.id),
    );
    if (newOrder != null) {
      _shownDialogOrderIds.add(newOrder.id);
      showOrderRequestPopup(newOrder);
    }
  }

  void showOrderRequestPopup(OrderModel order) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      Dialog(
        alignment: Alignment.topCenter,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 60,
        ),
        backgroundColor: Colors.transparent,
        child: OrderRequestCard(
          order: order,
          showActions: true,
          countdownSeconds: deliveryRequestTimeoutSeconds.value,
          onAccept: () {
            if (Get.isDialogOpen ?? false) Get.back();
            acceptOrder(order.id);
          },
          onReject: () {
            if (Get.isDialogOpen ?? false) Get.back();
            rejectOrder(order.id);
          },
          onTimeout: () {
            if (Get.isDialogOpen ?? false) Get.back();
            onOrderTimeout(order.id);
          },
          onTap: () {
            if (Get.isDialogOpen ?? false) Get.back();
            Get.toNamed(AppRoutes.orderDetail, arguments: order);
          },
        ),
      ),
      barrierDismissible: true,
    );
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
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    await runAsync(() async {
      final result = await _repo.acceptOrder(orderId);
      if (result.success) {
        AppUtils.showSuccess(AppConstants.orderAccepted);
        final idx = activeOrders.indexWhere((o) => o.id == orderId);
        OrderModel acceptedOrder;
        if (idx >= 0) {
          acceptedOrder = activeOrders[idx].copyWith(
            status: 'assigned',
            acceptedAt: DateTime.now(),
          );
        } else {
          acceptedOrder = OrderModel(
            id: orderId,
            orderId: orderId,
            status: 'assigned',
            customerName: 'Customer',
            customerPhone: '',
            pickupAddress: '',
            deliveryAddress: '',
            pickupLat: currentLat.value,
            pickupLng: currentLng.value,
            deliveryLat: currentLat.value,
            deliveryLng: currentLng.value,
            distanceKm: 0.0,
            earnings: 0.0,
            createdAt: DateTime.now(),
            acceptedAt: DateTime.now(),
          );
        }
        // Driver is now on delivery - stop background polling, clear active requests and set busy
        
        activeOrders.clear();
        _shownDialogOrderIds.add(orderId);
        isOnDelivery.value = true;
        currentActiveOrder.value = acceptedOrder;

        // Fetch fresh active delivery state from GET /api/driver/deliveries/current-active
        await fetchCurrentActiveDelivery();

        final targetOrder = currentActiveOrder.value ?? acceptedOrder;
        Get.toNamed(AppRoutes.activeDelivery, arguments: targetOrder);
      } else {
        AppUtils.showError(result.message.isNotEmpty
            ? result.message
            : 'Failed to accept delivery request');
      }
    }, showLoadingIndicator: true);
  }

  Future<void> rejectOrder(String orderId) async {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Reject Order',
      message: 'Are you sure you want to reject this delivery request?',
      confirmText: 'Reject',
      isDangerous: true,
    );
    if (!confirmed) return;

    await runAsync(() async {
      final result = await _repo.rejectOrder(orderId);
      if (result.success) {
        AppUtils.showInfo(AppConstants.orderRejected);
        _shownDialogOrderIds.add(orderId);
        activeOrders.removeWhere((o) => o.id == orderId);
      } else {
        AppUtils.showError(result.message.isNotEmpty
            ? result.message
            : 'Failed to reject delivery request');
      }
    }, showLoadingIndicator: true);
  }

  void onOrderTimeout(String orderId) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    _shownDialogOrderIds.add(orderId);
    _repo.rejectOrder(orderId);
    activeOrders.removeWhere((o) => o.id == orderId);
  }

  void returnToActiveDelivery() {
    final ord = currentActiveOrder.value;
    if (ord != null) {
      if (ord.isReachedCustomer) {
        Get.toNamed(AppRoutes.deliveryVerification, arguments: {
          'order': ord,
          'type': VerificationType.delivery,
        });
      } else if (ord.isPickedUp) {
        Get.toNamed(AppRoutes.activeDelivery, arguments: ord);
      } else if (ord.isReachedRestaurant) {
        Get.toNamed(AppRoutes.orderPickup, arguments: ord);
      } else {
        Get.toNamed(AppRoutes.activeDelivery, arguments: ord);
      }
    } else {
      Get.toNamed(AppRoutes.activeDelivery);
    }
  }

  // ─── Realtime WebSocket Listeners ──────────────────────────────────────────

  void _setupRealtimeListeners() {
    if (!Get.isRegistered<RealtimeService>()) return;
    final driverId = AuthService.to.user?.id;
    if (driverId == null || driverId.toString().isEmpty) return;

    final channelName = 'private-driver.$driverId';

    // 1. New delivery request assigned to driver
    RealtimeService.to.onEvent(channelName, 'order.delivery.request', (data) {
      AppLogger.i('Realtime event: order.delivery.request received');
      _handleIncomingOrderEvent(data);
    });
    RealtimeService.to.onEvent(channelName, 'delivery.request', (data) {
      AppLogger.i('Realtime event: delivery.request received');
      _handleIncomingOrderEvent(data);
    });
    RealtimeService.to.onEvent(channelName, 'order.assigned', (data) {
      AppLogger.i('Realtime event: order.assigned received');
      _handleIncomingOrderEvent(data);
    });

    // 2. Order cancelled
    RealtimeService.to.onEvent(channelName, 'order.cancelled', (data) {
      AppLogger.i('Realtime event: order.cancelled received');
      isOnDelivery.value = false;
      currentActiveOrder.value = null;
      fetchDashboardData();
    });
    RealtimeService.to.onEvent(channelName, 'delivery.cancelled', (data) {
      AppLogger.i('Realtime event: delivery.cancelled received');
      isOnDelivery.value = false;
      currentActiveOrder.value = null;
      fetchDashboardData();
    });

    // 3. Order completed / delivered
    RealtimeService.to.onEvent(channelName, 'order.completed', (data) {
      AppLogger.i('Realtime event: order.completed received');
      isOnDelivery.value = false;
      currentActiveOrder.value = null;
      fetchDashboardData();
    });
    RealtimeService.to.onEvent(channelName, 'delivery.completed', (data) {
      AppLogger.i('Realtime event: delivery.completed received');
      isOnDelivery.value = false;
      currentActiveOrder.value = null;
      fetchDashboardData();
    });

    // 4. Stats / earnings updated
    RealtimeService.to.onEvent(channelName, 'dashboard.updated', (_) {
      fetchDashboardData();
    });
    RealtimeService.to.onEvent(channelName, 'earnings.updated', (_) {
      fetchDashboardData();
    });

    // 5. Realtime status updates
    void handleLiveStatusUpdate(Map<String, dynamic> data) {
      AppLogger.i('⚡ [Dashboard Reverb Trigger] Status updated: $data');
      final newDeliveryStatus = (data['delivery_status'] ?? data['status'] ?? '').toString();
      final newOrderStatus = (data['order_status'] ?? '').toString();
      final effectiveStatus = newDeliveryStatus.isNotEmpty ? newDeliveryStatus : newOrderStatus;

      if (effectiveStatus.isNotEmpty && currentActiveOrder.value != null) {
        currentActiveOrder.value = currentActiveOrder.value!.copyWith(
          status: effectiveStatus,
          deliveryStatus: newDeliveryStatus.isNotEmpty ? newDeliveryStatus : currentActiveOrder.value!.deliveryStatus,
          orderStatus: newOrderStatus.isNotEmpty ? newOrderStatus : currentActiveOrder.value!.orderStatus,
        );
        if (currentActiveOrder.value!.isDelivered) {
          isOnDelivery.value = false;
          currentActiveOrder.value = null;
        } else {
          isOnDelivery.value = true;
        }
      }
      fetchCurrentActiveDelivery();
      fetchDashboardData();
    }

    RealtimeService.to.onEvent(channelName, 'order.status.updated', handleLiveStatusUpdate);
    RealtimeService.to.onEvent(channelName, 'delivery.status.updated', handleLiveStatusUpdate);
    RealtimeService.to.onEvent(channelName, 'order.status_updated', handleLiveStatusUpdate);
    RealtimeService.to.onEvent(channelName, 'delivery.status_updated', handleLiveStatusUpdate);
    RealtimeService.to.onEvent(channelName, 'delivery.tracking.updated', handleLiveStatusUpdate);
  }

  void _handleIncomingOrderEvent(Map<String, dynamic> data) {
    AppLogger.i('Handling incoming order event: $data');
    try {
      Map<String, dynamic>? rawOrderMap;
      if (data.containsKey('order') && data['order'] is Map<String, dynamic>) {
        rawOrderMap = data['order'] as Map<String, dynamic>;
      } else if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        rawOrderMap = data['data'] as Map<String, dynamic>;
      } else if (data.containsKey('id') || data.containsKey('order_uuid') || data.containsKey('delivery_id')) {
        rawOrderMap = data;
      }

      if (rawOrderMap != null) {
        final orderObj = OrderModel.fromJson(rawOrderMap);
        if (isOnline.value && !isOnDelivery.value && currentActiveOrder.value == null) {
          // Add to active orders list if not already present
          final exists = activeOrders.any((o) => o.id == orderObj.id);
          if (!exists) {
            activeOrders.insert(0, orderObj);
          }
          if (!_shownDialogOrderIds.contains(orderObj.id)) {
            _shownDialogOrderIds.add(orderObj.id);
            showOrderRequestPopup(orderObj);
          }
          return;
        }
      }
      loadDeliveryRequests();
    } catch (e) {
      AppLogger.w('Failed to parse incoming order event: $e');
      loadDeliveryRequests();
    }
  }

  void _removeRealtimeListeners() {
    if (!Get.isRegistered<RealtimeService>()) return;
    final driverId = AuthService.to.user?.id;
    if (driverId == null) return;
    final channelName = 'private-driver.$driverId';

    RealtimeService.to.removeEventHandler(channelName, 'order.delivery.request');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.request');
    RealtimeService.to.removeEventHandler(channelName, 'order.assigned');
    RealtimeService.to.removeEventHandler(channelName, 'order.cancelled');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.cancelled');
    RealtimeService.to.removeEventHandler(channelName, 'order.completed');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.completed');
    RealtimeService.to.removeEventHandler(channelName, 'dashboard.updated');
    RealtimeService.to.removeEventHandler(channelName, 'earnings.updated');
    RealtimeService.to.removeEventHandler(channelName, 'order.status.updated');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.status.updated');
    RealtimeService.to.removeEventHandler(channelName, 'order.status_updated');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.status_updated');
    RealtimeService.to.removeEventHandler(channelName, 'delivery.tracking.updated');
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final userApproval = AuthService.to.user?.approvalStatus ?? 'pending';
    approvalStatus.value = userApproval;
    final isApproved = userApproval.toLowerCase() == 'approved';
    isOnline.value = isApproved ? StorageService.to.isOnlineMode : false;
    isOnDelivery.value = false;
    _loadUserStats();
    fetchDashboardData();
    initLocationFlow();
    _setupRealtimeListeners();
  }

  @override
  void onClose() {
    _removeRealtimeListeners();
    _locationTimer?.cancel();
    LocationService.to.stopLocationUpdates();
    super.onClose();
  }
}
