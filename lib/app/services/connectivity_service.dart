import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();

  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType =
      ConnectivityResult.none.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkInitialConnectivity();
    _listenToChanges();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _listenToChanges() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    connectionType.value = result;
    final connected = result != ConnectivityResult.none;

    if (isConnected.value != connected) {
      isConnected.value = connected;
      AppLogger.i('Connectivity changed: ${connected ? 'online' : 'offline'} ($result)');
    }
  }

  Future<bool> checkConnection() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
    return isConnected.value;
  }

  String get connectionLabel {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      default:
        return 'No Connection';
    }
  }
}
