import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

import '../../../../data/repositories/order_repository.dart';
import '../../../utils/app_utils.dart';

enum VerificationType { pickup, delivery }

class DeliveryVerificationController extends BaseController {
  final OrderRepository _orderRepo = Get.isRegistered<OrderRepository>()
      ? Get.find<OrderRepository>()
      : Get.put(OrderRepository());
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  final otp = ''.obs;
  final order = Rxn<OrderModel>();
  final type = VerificationType.pickup.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      order.value = args['order'];
      type.value = args['type'] ?? VerificationType.pickup;
    }

    otpController.addListener(() {
      otp.value = otpController.text;
      if (hasError.value) hasError.value = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      focusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  final isVerifying = false.obs;

  Future<void> confirm() async {
    if (otp.value.length < 4 || isVerifying.value) return;
    final delId = order.value?.id ?? '';
    if (delId.isEmpty) {
      AppUtils.showError('Invalid delivery ID');
      return;
    }

    final isPickup = type.value == VerificationType.pickup;
    final targetStatus = isPickup ? 'picked_up' : 'delivered';

    isVerifying.value = true;
    try {
      final res = await _orderRepo.updateDeliveryStatus(
        deliveryId: delId,
        status: targetStatus,
        otp: otp.value,
      );

      if (res.success) {
        AppUtils.showSuccess(
          res.message.isNotEmpty
              ? res.message
              : (isPickup ? 'Order marked picked_up' : 'Order delivered successfully'),
        );

        if (isPickup) {
          // Fetch fresh tracking details from API after status update
          OrderModel? updatedOrder;
          try {
            final trackingRes = await _orderRepo.getDeliveryTracking(delId);
            if (trackingRes.success && trackingRes.data != null) {
              updatedOrder = trackingRes.data;
            }
          } catch (_) {}

          final currentOrd = order.value;
          updatedOrder ??= (currentOrd != null
              ? currentOrd.copyWith(status: 'picked_up')
              : OrderModel(
                  id: delId,
                  orderId: delId,
                  status: 'picked_up',
                  customerName: 'Customer',
                  customerPhone: '',
                  pickupAddress: '',
                  deliveryAddress: '',
                  pickupLat: 0.0,
                  pickupLng: 0.0,
                  deliveryLat: 0.0,
                  deliveryLng: 0.0,
                  distanceKm: 0.0,
                  earnings: 0.0,
                  createdAt: DateTime.now(),
                ));

          Get.offAllNamed(
            AppRoutes.activeDelivery,
            arguments: updatedOrder,
          );
        } else {
          if (Get.isRegistered<DashboardController>()) {
            final dash = Get.find<DashboardController>();
            dash.isOnDelivery.value = false;
            dash.currentActiveOrder.value = null;
            await dash.fetchDashboardData();
          }
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else {
        hasError.value = true;
        AppUtils.showError(
          res.message.isNotEmpty ? res.message : 'Invalid verification code. Please try again.',
        );
      }
    } catch (e) {
      AppUtils.showError('Something went wrong. Please try again.');
    } finally {
      isVerifying.value = false;
    }
  }
}
