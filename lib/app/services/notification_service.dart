import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/auth_repository.dart';
import '../../firebase_options.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_logger.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.i('🌙 [Background FCM] Title: "${message.notification?.title}", Data: ${message.data}');
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  late final FirebaseMessaging _fcm;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'swiftdrop_orders';
  static const _channelName = 'Order Notifications';
  static const _channelDesc = 'Notifications for new orders and updates';

  final RxnString fcmToken = RxnString();

  String? get token => fcmToken.value ?? StorageService.to.fcmToken;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      if (Firebase.apps.isEmpty) return;
      _fcm = FirebaseMessaging.instance;
      await _setupLocalNotifications();
      await _setupFCM();
    } catch (e) {
      AppLogger.w('NotificationService: setup skipped: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _fcm.setAutoInitEnabled(true);

    // Enable presentation options so notifications alert the user
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.i('Notification permission status: ${settings.authorizationStatus}');

    try {
      await Permission.notification.request();
    } catch (_) {}

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      final status = await Permission.notification.status;
      if (status.isPermanentlyDenied) {
        Future.delayed(const Duration(milliseconds: 1500), _showPermissionDialog);
      }
    }

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Notification tap from terminated state
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNotificationOpen(initial);

    // Token management with retry
    final currentToken = await _fetchTokenWithRetry();
    if (currentToken != null) {
      fcmToken.value = currentToken;
      StorageService.to.saveFcmToken(currentToken);
      print('\n====================================================');
      print('🔥 FIREBASE INITIALIZED SUCCESSFULLY (DRIVER APP)');
      print('🔑 FCM DEVICE TOKEN: $currentToken');
      print('====================================================\n');
      _syncTokenWithServer(currentToken);
    } else {
      AppLogger.w('FCM token could not be retrieved after retries.');
    }

    _fcm.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Request notification permissions and show settings dialog if denied
  Future<void> checkAndRequestPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        AppLogger.i('Notification permission granted');
        await getOrFetchToken();
      } else if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  /// Shows dialog when notification permission is permanently denied
  void _showPermissionDialog() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Color(0xFFFF6B00)),
            SizedBox(width: 10),
            Text(
              'Notification Permission',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          'Please enable notifications in settings to receive instant delivery and order assignment alerts.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Helper to fetch FCM token with automatic retry
  Future<String?> _fetchTokenWithRetry({int maxRetries = 4}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final token = await _fcm.getToken();
        if (token != null && token.isNotEmpty) {
          return token;
        }
      } catch (e) {
        AppLogger.w('FCM token fetch attempt $attempt / $maxRetries failed ($e)');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    }
    return null;
  }

  /// Explicitly retrieve or refresh the device FCM token on-demand
  Future<String?> getOrFetchToken() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final newToken = await _fetchTokenWithRetry(maxRetries: 3);
        if (newToken != null) {
          fcmToken.value = newToken;
          StorageService.to.saveFcmToken(newToken);
          _syncTokenWithServer(newToken);
          return newToken;
        }
      }
    } catch (e) {
      AppLogger.e('Error manually fetching FCM token', e);
    }
    return token;
  }

  Future<void> syncFcmTokenWithServer([String? specificToken]) async {
    final tokenToSync = specificToken ?? token;
    if (tokenToSync == null || tokenToSync.isEmpty) return;
    if (!StorageService.to.isLoggedIn) return;

    try {
      final authRepo = AuthRepository();
      final response = await authRepo.updateFcmToken(tokenToSync);
      if (response.success) {
        AppLogger.i('FCM token synced with server successfully');
      }
    } catch (e) {
      AppLogger.w('FCM token server sync skipped: $e');
    }
  }

  Future<void> _syncTokenWithServer(String token) async =>
      syncFcmTokenWithServer(token);

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.i('🔔 [FCM Message] Title: "${message.notification?.title}", Body: "${message.notification?.body}"');
    AppLogger.i('📦 [FCM Data Payload] ${message.data}');
    
    final type = (message.data['type'] ?? message.data['event'] ?? '').toString().toLowerCase();
    final status = (message.data['status'] ?? '').toString().toLowerCase();
    AppLogger.i('🏷️ [FCM Type] "$type", Status: "$status"');

    // Trigger delivery requests API and refresh dashboard if notification relates to deliveries/orders
    if (type.contains('order') ||
        type.contains('delivery') ||
        type == 'new_delivery' ||
        type == 'new_order' ||
        type == 'delivery_request' ||
        status == 'unassigned' ||
        status == 'new' ||
        status == 'pending' ||
        type.isEmpty) {
      if (Get.isRegistered<DashboardController>()) {
        AppLogger.i('⚡ [FCM Trigger] Refreshing delivery requests & dashboard');
        Get.find<DashboardController>().loadDeliveryRequests();
        Get.find<DashboardController>().fetchDashboardData();
      }
    }

    // 1. Trigger haptic vibration reminder for driver
    HapticFeedback.heavyImpact();

    final title = message.notification?.title ?? message.data['title']?.toString() ?? 'Order Update';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? message.data['message']?.toString() ?? 'You have a new update.';

    // 2. Show high-priority local notification pop-up
    try {
      final notifId = (message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch).abs() % 100000;
      _localNotifications.show(
        notifId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      AppLogger.e('Error showing local notification', e);
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    AppLogger.i('📲 [FCM Opened] Title: "${message.notification?.title}", Data: ${message.data}');
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDeliveryRequests();
      Get.find<DashboardController>().fetchDashboardData();
    }
    _routeFromData(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    HapticFeedback.lightImpact();
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      AppLogger.i('👆 [Local Notification Tapped] Payload: $data');
      _routeFromData(data);
    } catch (e) {
      AppLogger.e('Notification tap routing error', e);
    }
  }

  void _routeFromData(Map<String, dynamic> data) {
    AppLogger.i('🧭 [Notification Route] Data: $data');
    final type = (data['type'] ?? data['event'] ?? '').toString().toLowerCase();
    final deliveryId = (data['delivery_id'] ?? data['id'] ?? data['order_id'] ?? '').toString();
    final status = (data['status'] ?? '').toString().toLowerCase();

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDeliveryRequests();
      Get.find<DashboardController>().fetchDashboardData();
    }

    if (deliveryId.isEmpty) {
      Get.toNamed(AppRoutes.dashboard);
      return;
    }

    final orderStatus = (data['order_status'] ?? '').toString().toLowerCase();
    final deliveryStatus = (data['delivery_status'] ?? status).toString().toLowerCase();

    // 1. Reached restaurant / ready for pickup -> route directly to Order Pickup screen
    if (deliveryStatus == 'reached_restaurant' ||
        deliveryStatus == 'arrived_at_restaurant' ||
        deliveryStatus == 'reached_pickup' ||
        deliveryStatus == 'at_restaurant' ||
        orderStatus == 'ready_for_pickup' ||
        status == 'reached_restaurant' ||
        status == 'ready_for_pickup') {
      Get.toNamed(AppRoutes.orderPickup, arguments: deliveryId);
      return;
    }

    // 2. Active delivery statuses (assigned, picked up, out for delivery, etc.) -> route to Active Delivery screen
    final isActiveDelivery = deliveryStatus == 'driver_assigned' ||
        deliveryStatus == 'assigned' ||
        deliveryStatus == 'picked_up' ||
        deliveryStatus == 'out_for_delivery' ||
        deliveryStatus == 'on_the_way' ||
        deliveryStatus == 'in_transit' ||
        deliveryStatus == 'dispatched' ||
        orderStatus == 'driver_assigned' ||
        orderStatus == 'picked_up' ||
        type == 'order_status_updated' ||
        type == 'delivery_assigned' ||
        type == 'order_assigned' ||
        type == 'active_delivery';

    if (isActiveDelivery) {
      Get.toNamed(AppRoutes.activeDelivery, arguments: deliveryId);
      return;
    }

    // 3. Delivered or completed orders -> route to Order Detail screen
    if (status == 'delivered' || status == 'completed') {
      Get.toNamed(AppRoutes.orderDetail, arguments: {'delivery_id': deliveryId, 'id': deliveryId});
      return;
    }

    // 4. New delivery requests / incoming orders -> route to Dashboard (shows interactive order dialog)
    if (type == 'new_delivery' ||
        type == 'new_order' ||
        type == 'delivery_request' ||
        status == 'new' ||
        status == 'pending' ||
        status == 'unassigned' ||
        status == 'requested' ||
        status == 'open') {
      Get.toNamed(AppRoutes.dashboard);
      return;
    }

    // 5. Default order/delivery fallback -> Active Delivery screen
    if (type.contains('order') || type.contains('delivery')) {
      Get.toNamed(AppRoutes.activeDelivery, arguments: deliveryId);
      return;
    }

    Get.toNamed(AppRoutes.dashboard);
  }

  void _onTokenRefresh(String token) {
    fcmToken.value = token;
    StorageService.to.saveFcmToken(token);
    print('\n====================================================');
    print('🔄 FCM DEVICE TOKEN REFRESHED (DRIVER APP)');
    print('🔑 NEW FCM DEVICE TOKEN: $token');
    print('====================================================\n');
    _syncTokenWithServer(token);
  }

  Future<void> clearBadge() async {
    await _localNotifications.cancelAll();
  }
}
