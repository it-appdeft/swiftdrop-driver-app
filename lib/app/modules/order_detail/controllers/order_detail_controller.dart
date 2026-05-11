import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_utils.dart';

class OrderDetailController extends BaseController {
  final OrderRepository _orderRepo;

  OrderDetailController(this._orderRepo);

  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is OrderModel) {
      order.value = Get.arguments as OrderModel;
    } else {
      setError('Order data not found');
    }
  }

  Future<void> acceptOrder() async {
    if (order.value == null) return;
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Accept Order',
      message: 'Accept order #${order.value!.orderId}?',
      confirmText: 'Accept',
    );
    if (!confirmed) return;

    await runAsync(() async {
      await _orderRepo.acceptOrder(order.value!.id);
      _patchStatus('accepted', acceptedAt: DateTime.now());
      AppUtils.showSuccess('Order accepted!');
    });
  }

  Future<void> rejectOrder() async {
    if (order.value == null) return;
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Reject Order',
      message: 'Are you sure you want to reject this order?',
      confirmText: 'Reject',
      isDangerous: true,
    );
    if (!confirmed) return;

    await runAsync(() async {
      await _orderRepo.rejectOrder(order.value!.id);
      AppUtils.showSuccess('Order rejected');
      Get.back();
    });
  }

  Future<void> confirmPickup() async {
    if (order.value == null) return;
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Confirm Pickup',
      message: 'Confirm you have picked up the order from the merchant?',
      confirmText: 'Confirm Pickup',
    );
    if (!confirmed) return;

    await runAsync(() async {
      await _orderRepo.confirmPickup(order.value!.id);
      _patchStatus('picked_up', pickedUpAt: DateTime.now());
      AppUtils.showSuccess('Pickup confirmed!');
    });
  }

  Future<void> confirmDelivery() async {
    if (order.value == null) return;
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Confirm Delivery',
      message: 'Confirm you have delivered the order to the customer?',
      confirmText: 'Confirm Delivery',
    );
    if (!confirmed) return;

    await runAsync(() async {
      await _orderRepo.confirmDelivery(orderId: order.value!.id);
      _patchStatus('delivered', deliveredAt: DateTime.now());
      AppUtils.showSuccess('Delivery confirmed! Great job!');
    });
  }

  void openNavigation() {
    AppUtils.showInfo('Opening navigation to delivery location…');
  }

  void callCustomer() {
    final phone = order.value?.customerPhone ?? '';
    if (phone.isEmpty) return;
    AppUtils.showInfo('Calling +91 $phone…');
  }

  void _patchStatus(
    String status, {
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) {
    order.value = order.value!.copyWith(
      status: status,
      acceptedAt: acceptedAt,
      pickedUpAt: pickedUpAt,
      deliveredAt: deliveredAt,
    );
  }

  static void open(OrderModel o) =>
      Get.toNamed(AppRoutes.orderDetail, arguments: o);
}
