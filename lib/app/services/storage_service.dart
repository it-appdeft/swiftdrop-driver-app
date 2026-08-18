import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';
import '../../data/models/user_model.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final _box = GetStorage();

  // ─── Auth ──────────────────────────────────────────────────────────────────

  String? get authToken => _box.read<String>(StorageKeys.authToken);
  String? get refreshToken => _box.read<String>(StorageKeys.refreshToken);

  void saveAuthToken(String token) =>
      _box.write(StorageKeys.authToken, token);

  void saveRefreshToken(String token) =>
      _box.write(StorageKeys.refreshToken, token);

  void clearAuth() {
    _box.remove(StorageKeys.authToken);
    _box.remove(StorageKeys.refreshToken);
    _box.remove(StorageKeys.userData);
  }

  bool get isLoggedIn =>
      authToken != null && authToken!.isNotEmpty;

  // ─── User ──────────────────────────────────────────────────────────────────

  UserModel? get user {
    final raw = _box.read<String>(StorageKeys.userData);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void saveUser(UserModel user) =>
      _box.write(StorageKeys.userData, jsonEncode(user.toJson()));

  // ─── Onboarding ────────────────────────────────────────────────────────────

  bool get onboardingCompleted =>
      _box.read<bool>(StorageKeys.onboardingCompleted) ?? false;

  void setOnboardingCompleted() =>
      _box.write(StorageKeys.onboardingCompleted, true);

  // ─── FCM ──────────────────────────────────────────────────────────────────

  String? get fcmToken => _box.read<String>(StorageKeys.fcmToken);

  void saveFcmToken(String token) =>
      _box.write(StorageKeys.fcmToken, token);

  // ─── Driver online state ───────────────────────────────────────────────────

  bool get isOnlineMode =>
      _box.read<bool>(StorageKeys.isOnlineMode) ?? false;

  void setOnlineMode(bool value) =>
      _box.write(StorageKeys.isOnlineMode, value);

  // ─── Auto Login ───────────────────────────────────────────────────────────

  bool get isAutoLogin => _box.read<bool>(StorageKeys.isAutoLogin) ?? false;
  void setAutoLogin(bool value) => _box.write(StorageKeys.isAutoLogin, value);

  // ─── Device Token ─────────────────────────────────────────────────────────

  String? get deviceToken => _box.read<String>(StorageKeys.deviceToken);
  void saveDeviceToken(String token) => _box.write(StorageKeys.deviceToken, token);

  // ─── Generic ───────────────────────────────────────────────────────────────

  void writeData(String key, dynamic value) {
    if (value == null) {
      _box.remove(key);
    } else if (value is String ||
        value is int ||
        value is double ||
        value is bool ||
        value is List ||
        value is Map) {
      _box.write(key, value);
    } else {
      // For custom models, try calling toJson
      try {
        _box.write(key, value.toJson());
      } catch (e) {
        _box.write(key, value);
      }
    }
  }

  T? readData<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) {
    final data = _box.read(key);
    if (data == null) return null;

    if (fromJson != null && data is Map) {
      return fromJson(Map<String, dynamic>.from(data));
    }

    if (data is T) return data;
    return null;
  }

  T? read<T>(String key) => _box.read<T>(key);
  void write(String key, dynamic value) => _box.write(key, value);
  void remove(String key) => _box.remove(key);

  void clearAll() => _box.erase();
}
