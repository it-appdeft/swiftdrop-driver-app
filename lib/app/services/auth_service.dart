import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../network/dio_client.dart';
import 'notification_service.dart';
import 'realtime_service.dart';
import 'storage_service.dart';
import '../../data/models/user_model.dart';
import '../utils/app_logger.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _storage = StorageService.to;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _storage.user;

    if (isAuthenticated && currentUser.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentUser.value != null) {
          _connectRealtime(currentUser.value!);
        }
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.to.syncFcmTokenWithServer();
        }
      });
    }
  }

  bool get isAuthenticated => _storage.isLoggedIn;

  UserModel? get user => currentUser.value;

  void saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) {
    _storage.saveAuthToken(accessToken);
    _storage.saveRefreshToken(refreshToken);
    _storage.saveUser(user);
    currentUser.value = user;
    AppLogger.i('Session saved for user: ${user.id}');

    _connectRealtime(user);
    if (Get.isRegistered<NotificationService>()) {
      NotificationService.to.syncFcmTokenWithServer();
    }
  }

  void updateUser(UserModel user) {
    _storage.saveUser(user);
    currentUser.value = user;
  }

  void logout() {
    if (Get.isRegistered<RealtimeService>()) {
      RealtimeService.to.disconnect();
    }
    _storage.clearAll();
    DioClient.reset();
    currentUser.value = null;
    AppLogger.i('User logged out');
  }

  // ─── Reverb Connection ─────────────────────────────────────────────────────

  void _connectRealtime(UserModel user) {
    if (!Get.isRegistered<RealtimeService>()) return;
    final realtime = RealtimeService.to;
    realtime.connect().then((_) {
      final driverId = user.id;
      if (driverId.toString().isNotEmpty) {
        realtime.subscribeDriver(driverId);
      }
    });
  }
}
