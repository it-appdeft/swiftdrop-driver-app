import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  AppLogger.i('Background notification: ${message.messageId}');
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  late final FirebaseMessaging _fcm;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'swiftdrop_orders';
  static const _channelName = 'Order Notifications';
  static const _channelDesc = 'Notifications for new orders and updates';

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      if (Firebase.apps.isEmpty) return;
      _fcm = FirebaseMessaging.instance;
      await _requestPermission();
      await _setupLocalNotifications();
      await _setupFCM();
    } catch (e) {
      AppLogger.w('NotificationService: setup skipped — $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.i('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create high-priority channel for Android
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Notification tap from terminated state
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNotificationOpen(initial);

    // Token management
    await _refreshToken();
    _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.i('Foreground notification: ${message.messageId}');
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    AppLogger.i('Notification opened: ${message.data}');
    _routeFromData(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _routeFromData(data);
    } catch (e) {
      AppLogger.e('Notification tap routing error', e);
    }
  }

  void _routeFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    switch (type) {
      case 'new_order':
        Get.toNamed(AppRoutes.orderDetail, arguments: {'id': id});
        break;
      case 'order_update':
        Get.toNamed(AppRoutes.orderDetail, arguments: {'id': id});
        break;
      default:
        Get.toNamed(AppRoutes.dashboard);
    }
  }

  Future<void> _refreshToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      StorageService.to.saveFcmToken(token);
      AppLogger.i('FCM token refreshed');
    }
  }

  void _onTokenRefresh(String token) {
    StorageService.to.saveFcmToken(token);
    AppLogger.i('FCM token updated');
  }

  Future<void> clearBadge() async {
    await _localNotifications.cancelAll();
  }
}
