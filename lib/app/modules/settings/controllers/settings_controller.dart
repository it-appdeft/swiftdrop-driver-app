import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_utils.dart';

class SettingsController extends BaseController {
  final _storage = StorageService.to;

  final orderNotifications   = true.obs;
  final paymentNotifications = true.obs;
  final locationTracking     = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() {
    orderNotifications.value   = _storage.read<bool>('pref_order_notif')   ?? true;
    paymentNotifications.value = _storage.read<bool>('pref_payment_notif') ?? true;
    locationTracking.value     = _storage.read<bool>('pref_location')      ?? true;
  }

  void setOrderNotifications(bool val) {
    orderNotifications.value = val;
    _storage.write('pref_order_notif', val);
  }

  void setPaymentNotifications(bool val) {
    paymentNotifications.value = val;
    _storage.write('pref_payment_notif', val);
  }

  void setLocationTracking(bool val) {
    locationTracking.value = val;
    _storage.write('pref_location', val);
  }

  void clearCache() => AppUtils.showSuccess('Cache cleared successfully');

  void openSupport() => AppUtils.showInfo('Support feature coming soon');

  void openPrivacyPolicy() => AppUtils.showInfo('Privacy policy coming soon');

  String get appVersion => '1.0.0';
}
