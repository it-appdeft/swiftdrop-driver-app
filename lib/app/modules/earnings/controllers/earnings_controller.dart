import 'package:get/get.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/repositories/earnings_repository.dart';
import '../../../base/base_controller.dart';

class EarningsController extends BaseController {
  final EarningsRepository _repo;

  EarningsController(this._repo);

  final totalBalance      = 0.0.obs;
  final todayEarnings     = 0.0.obs;
  final weekEarnings      = 0.0.obs;
  final monthEarnings     = 0.0.obs;
  final todayDeliveries   = 0.obs;
  final weekDeliveries    = 0.obs;
  final transactions      = <TransactionModel>[].obs;
  final hasMoreTx         = false.obs;

  static const _txLimit = 20;
  int _txPage = 1;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await _loadSummary();
    await _loadTransactions();
  }

  Future<void> _loadSummary() async {
    await runAsync(() async {
      final res = await _repo.getEarningsSummary();
      final data = res.data ?? {};
      totalBalance.value    = (data['wallet_balance'] as num?)?.toDouble() ?? 0.0;
      todayEarnings.value   = (data['today']          as num?)?.toDouble() ?? 0.0;
      weekEarnings.value    = (data['week']           as num?)?.toDouble() ?? 0.0;
      monthEarnings.value   = (data['month']          as num?)?.toDouble() ?? 0.0;
      todayDeliveries.value = data['today_deliveries'] as int? ?? 0;
      weekDeliveries.value  = data['week_deliveries']  as int? ?? 0;
    });
  }

  Future<void> _loadTransactions() async {
    _txPage = 1;
    try {
      final res = await _repo.getTransactions(page: _txPage, limit: _txLimit);
      transactions.assignAll(res.data ?? []);
      hasMoreTx.value = (res.data?.length ?? 0) >= _txLimit;
    } catch (_) {}
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMoreTx.value || isLoadingMore.value) return;
    showLoadingMore();
    try {
      _txPage++;
      final res = await _repo.getTransactions(page: _txPage, limit: _txLimit);
      transactions.addAll(res.data ?? []);
      hasMoreTx.value = (res.data?.length ?? 0) >= _txLimit;
    } catch (_) {
      _txPage--;
    } finally {
      hideLoadingMore();
    }
  }
}
