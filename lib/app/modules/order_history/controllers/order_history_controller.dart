import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';

class OrderHistoryController extends BaseController {
  final OrderRepository _orderRepo;

  OrderHistoryController(this._orderRepo);

  final _allOrders  = <OrderModel>[];
  final orders      = <OrderModel>[].obs;
  final hasMore     = false.obs;
  final selectedFilter = 'all'.obs; // 'all' | 'completed' | 'cancelled'

  static const _limit = 20;
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    ever(selectedFilter, (_) => _applyFilter());
  }

  Future<void> loadHistory() async {
    await runAsync(() async {
      _page = 1;
      final res = await _orderRepo.getOrderHistory(page: _page, limit: _limit);
      _allOrders
        ..clear()
        ..addAll(res.data ?? []);
      _applyFilter();
      hasMore.value = (res.data?.length ?? 0) >= _limit;
    });
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    showLoadingMore();
    try {
      _page++;
      final res = await _orderRepo.getOrderHistory(page: _page, limit: _limit);
      _allOrders.addAll(res.data ?? []);
      _applyFilter();
      hasMore.value = (res.data?.length ?? 0) >= _limit;
    } catch (_) {
      _page--;
    } finally {
      hideLoadingMore();
    }
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  void viewDetail(OrderModel order) =>
      Get.toNamed(AppRoutes.orderDetail, arguments: order);

  void _applyFilter() {
    switch (selectedFilter.value) {
      case 'completed':
        orders.assignAll(_allOrders.where((o) => o.isDelivered || o.deliveredAt != null));
      case 'cancelled':
        orders.assignAll(_allOrders.where((o) => o.isCancelled));
      default:
        orders.assignAll(_allOrders);
    }
  }
}
