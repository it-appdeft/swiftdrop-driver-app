import 'dart:async';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/local/app_data.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/order_repository.dart';

class DashboardController extends BaseController {
  final OrderRepository _repo;
  DashboardController(this._repo);

  // ─── Navigation ────────────────────────────────────────────────────────────

  final currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;

  // ─── User ──────────────────────────────────────────────────────────────────

  UserModel? get user => AuthService.to.user;

  // ─── Online toggle ─────────────────────────────────────────────────────────

  final isOnline = false.obs;

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    StorageService.to.setOnlineMode(isOnline.value);
    AppUtils.showInfo(
      isOnline.value ? 'You are now online' : 'You are now offline',
    );
  }

  // ─── Active orders ─────────────────────────────────────────────────────────

  final activeOrders = <OrderModel>[].obs;
  Timer? _pollTimer;

  Future<void> loadActiveOrders() async {
    await runAsync(() async {
      final result = await _repo.getActiveOrders();
      if (result.success && result.data != null) {
        activeOrders.value = result.data!;
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _silentRefresh(),
    );
  }

  Future<void> _silentRefresh() async {
    if (!isConnected || isLoading.value) return;
    try {
      final result = await _repo.getActiveOrders();
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

  // ─── Earnings summary ──────────────────────────────────────────────────────

  final todayEarnings = 0.0.obs;
  final totalDeliveries = 0.obs;
  final rating = 0.0.obs;

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
        AppUtils.showSuccess('Order accepted!');
        final idx = activeOrders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          activeOrders[idx] = activeOrders[idx].copyWith(
            status: 'accepted',
            acceptedAt: DateTime.now(),
          );
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
        AppUtils.showInfo('Order rejected');
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
    _loadUserStats();
    loadActiveOrders();
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }
}
