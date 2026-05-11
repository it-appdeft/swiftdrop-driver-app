import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';
import '../utils/app_utils.dart';

class ConnectivityMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!ConnectivityService.to.isConnected.value) {
      AppUtils.showWarning('No internet connection.');
      // Don't hard-redirect, just warn — the app handles offline gracefully
    }
    return null;
  }
}
