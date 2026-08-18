import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/order_model.dart';
import '../../../base/base_controller.dart';

enum VerificationType { pickup, delivery }

class DeliveryVerificationController extends BaseController {
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

  void confirm() {
    if (otp.value.length < 4) return;

    if (otp.value == '1234' || type.value == VerificationType.pickup) {
      if (type.value == VerificationType.pickup) {
        Get.back(result: true);
      } else {
        Get.offAllNamed('/dashboard');
      }
    } else {
      hasError.value = true;
    }
  }
}
