import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_utils.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class OrderDetailController extends BaseController {
  final OrderRepository _orderRepo;

  OrderDetailController(this._orderRepo);

  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    loadOrderDetail();
  }

  Future<void> loadOrderDetail() async {
    final args = Get.arguments;
    String? id;
    if (args is OrderModel) {
      order.value = args;
      id = args.id;
    } else if (args is String) {
      id = args;
    } else if (args is Map) {
      id = (args['delivery_id'] ?? args['id'] ?? args['order_id'])?.toString();
    }

    if (id != null && id.isNotEmpty) {
      await runAsync(() async {
        final res = await _orderRepo.getOrderDetail(id!);
        if (res.success && res.data != null) {
          if (order.value != null) {
            order.value = order.value!.copyWith(
              status: res.data!.status.isNotEmpty ? res.data!.status : order.value!.status,
              customerName: res.data!.customerName.isNotEmpty ? res.data!.customerName : order.value!.customerName,
              customerPhone: res.data!.customerPhone.isNotEmpty ? res.data!.customerPhone : order.value!.customerPhone,
              restaurantName: res.data!.restaurantName?.isNotEmpty == true ? res.data!.restaurantName : order.value!.restaurantName,
              restaurantPhone: res.data!.restaurantPhone?.isNotEmpty == true ? res.data!.restaurantPhone : order.value!.restaurantPhone,
              restaurantImage: res.data!.restaurantImage?.isNotEmpty == true ? res.data!.restaurantImage : order.value!.restaurantImage,
              pickupAddress: res.data!.pickupAddress.isNotEmpty ? res.data!.pickupAddress : order.value!.pickupAddress,
              pickupShortAddress: res.data!.pickupShortAddress.isNotEmpty ? res.data!.pickupShortAddress : order.value!.pickupShortAddress,
              deliveryAddress: res.data!.deliveryAddress.isNotEmpty ? res.data!.deliveryAddress : order.value!.deliveryAddress,
              deliveryShortAddress: res.data!.deliveryShortAddress.isNotEmpty ? res.data!.deliveryShortAddress : order.value!.deliveryShortAddress,
              pickupLat: res.data!.pickupLat != 0.0 ? res.data!.pickupLat : order.value!.pickupLat,
              pickupLng: res.data!.pickupLng != 0.0 ? res.data!.pickupLng : order.value!.pickupLng,
              deliveryLat: res.data!.deliveryLat != 0.0 ? res.data!.deliveryLat : order.value!.deliveryLat,
              deliveryLng: res.data!.deliveryLng != 0.0 ? res.data!.deliveryLng : order.value!.deliveryLng,
              notes: res.data!.notes?.isNotEmpty == true ? res.data!.notes : order.value!.notes,
              items: res.data!.items.isNotEmpty ? res.data!.items : order.value!.items,
            );
          } else {
            order.value = res.data;
          }
        } else if (order.value == null) {
          setError(res.message);
        }
      }, showLoadingIndicator: order.value == null);
    } else if (order.value == null) {
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
      final res = await _orderRepo.acceptOrder(order.value!.id);
      if (res.success) {
        _patchStatus('accepted', acceptedAt: DateTime.now());
        AppUtils.showSuccess(AppConstants.orderAccepted);
        if (Get.isRegistered<DashboardController>()) {
          final dash = Get.find<DashboardController>();
          dash.isOnDelivery.value = true;
          dash.currentActiveOrder.value = order.value;
          dash.activeOrders.clear();
        }
        Get.offNamed(AppRoutes.activeDelivery, arguments: order.value);
      } else {
        AppUtils.showError(res.message.isNotEmpty
            ? res.message
            : 'Failed to accept order');
      }
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
      AppUtils.showSuccess(AppConstants.orderRejected);
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().onOrderTimeout(order.value!.id);
      }
      Get.back();
    });
  }

  void onOrderTimeout() {
    if (order.value != null) {
      _orderRepo.rejectOrder(order.value!.id);
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().onOrderTimeout(order.value!.id);
      }
    }
    AppUtils.showInfo('Order request expired');
    Get.back();
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
      AppUtils.showSuccess(AppConstants.pickupConfirmed);
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
      AppUtils.showSuccess(AppConstants.deliveryConfirmed);
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
