import 'package:get/get.dart';
import '../network/dio_client.dart';
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
  }

  void updateUser(UserModel user) {
    _storage.saveUser(user);
    currentUser.value = user;
  }

  void logout() {
    _storage.clearAuth();
    DioClient.reset();
    currentUser.value = null;
    AppLogger.i('User logged out');
  }
}
