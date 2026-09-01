import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swiftdrop_driver_app/app/utils/app_logger.dart';
import 'package:swiftdrop_driver_app/app/utils/app_utils.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/realtime_service.dart';
import '../../../services/auth_service.dart';
import '../../../themes/app_colors.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'delivery_verification_controller.dart';

class ActiveDeliveryController extends BaseController {
  final OrderRepository _orderRepo;

  ActiveDeliveryController(this._orderRepo);

  final order = Rxn<OrderModel>();
 
 // false = heading to pickup (Stage 1: My Location -> Restaurant), true = heading to dropoff (Stage 2: Restaurant -> Customer)
 
  final isHeadingToDropoff = false.obs;

  void _setupRealtimeListeners(String ordId) {
    if (ordId.isEmpty || !Get.isRegistered<RealtimeService>()) return;

    final driverId = AuthService.to.user?.id;
    if (driverId == null) return;
    final driverChannel = 'private-driver.$driverId';
    final deliveryChannel = 'private-delivery.$ordId';

    // Subscribe to driver and delivery channels
    RealtimeService.to.subscribeToChannel(driverChannel);
    RealtimeService.to.subscribeToChannel(deliveryChannel);

    void handleStatusUpdate(Map<String, dynamic> data) {
      AppLogger.i('⚡ [WebSocket Event Trigger] Status updated: $data');
      // When WebSocket event is received, immediately refresh tracking API for authoritative state
      _fetchTrackingDetails(ordId);

      // If data payload already contains status, apply fast optimistic update
      final newDeliveryStatus = (data['delivery_status'] ?? data['status'] ?? '').toString();
      final newOrderStatus = (data['order_status'] ?? '').toString();
      final effectiveStatus = newDeliveryStatus.isNotEmpty ? newDeliveryStatus : newOrderStatus;

      if (effectiveStatus.isNotEmpty && order.value != null) {
        order.value = order.value!.copyWith(
          status: effectiveStatus,
          deliveryStatus: newDeliveryStatus.isNotEmpty ? newDeliveryStatus : order.value!.deliveryStatus,
          orderStatus: newOrderStatus.isNotEmpty ? newOrderStatus : order.value!.orderStatus,
        );
        if (order.value!.isPickedUp) {
          isHeadingToDropoff.value = true;
        }
        _checkStatusAndRedirectIfNeeded();
        _updateRouteAndMarkers();
      }
    }

    // Bind driver channel events
    RealtimeService.to.onEvent(driverChannel, 'order.status.updated', handleStatusUpdate);
    RealtimeService.to.onEvent(driverChannel, 'delivery.status.updated', handleStatusUpdate);
    RealtimeService.to.onEvent(driverChannel, 'order.status_updated', handleStatusUpdate);
    RealtimeService.to.onEvent(driverChannel, 'delivery.status_updated', handleStatusUpdate);
    RealtimeService.to.onEvent(driverChannel, 'delivery.tracking.updated', handleStatusUpdate);

    // Bind delivery channel events
    RealtimeService.to.onEvent(deliveryChannel, 'order.status.updated', handleStatusUpdate);
    RealtimeService.to.onEvent(deliveryChannel, 'delivery.status.updated', handleStatusUpdate);
    RealtimeService.to.onEvent(deliveryChannel, 'status.updated', handleStatusUpdate);

    // Cancelled / Completed events
    RealtimeService.to.onEvent(driverChannel, 'order.cancelled', (data) {
      AppLogger.i('Active delivery received order.cancelled');
      AppUtils.showError('This order was cancelled.');
      Get.offAllNamed(AppRoutes.dashboard);
    });

    RealtimeService.to.onEvent(driverChannel, 'delivery.cancelled', (data) {
      AppLogger.i('Active delivery received delivery.cancelled');
      AppUtils.showError('This delivery was cancelled.');
      Get.offAllNamed(AppRoutes.dashboard);
    });

    RealtimeService.to.onEvent(driverChannel, 'order.completed', (data) {
      AppLogger.i('Active delivery received order.completed');
      AppUtils.showSuccess('Delivery completed successfully!');
      Get.offAllNamed(AppRoutes.dashboard);
    });

    RealtimeService.to.onEvent(driverChannel, 'delivery.completed', (data) {
      AppLogger.i('Active delivery received delivery.completed');
      AppUtils.showSuccess('Delivery completed successfully!');
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }

  void _removeRealtimeListeners(String? ordId) {
    if (!Get.isRegistered<RealtimeService>()) return;
    final driverId = AuthService.to.user?.id;
    if (driverId == null) return;
    final driverChannel = 'private-driver.$driverId';
    final deliveryChannel = ordId != null && ordId.isNotEmpty ? 'private-delivery.$ordId' : '';

    RealtimeService.to.removeEventHandler(driverChannel, 'order.status.updated');
    RealtimeService.to.removeEventHandler(driverChannel, 'delivery.status.updated');
    RealtimeService.to.removeEventHandler(driverChannel, 'order.status_updated');
    RealtimeService.to.removeEventHandler(driverChannel, 'delivery.status_updated');
    RealtimeService.to.removeEventHandler(driverChannel, 'delivery.tracking.updated');
    RealtimeService.to.removeEventHandler(driverChannel, 'order.cancelled');
    RealtimeService.to.removeEventHandler(driverChannel, 'delivery.cancelled');
    RealtimeService.to.removeEventHandler(driverChannel, 'order.completed');
    RealtimeService.to.removeEventHandler(driverChannel, 'delivery.completed');

    if (deliveryChannel.isNotEmpty) {
      RealtimeService.to.removeEventHandler(deliveryChannel, 'order.status.updated');
      RealtimeService.to.removeEventHandler(deliveryChannel, 'delivery.status.updated');
      RealtimeService.to.removeEventHandler(deliveryChannel, 'status.updated');
      RealtimeService.to.unsubscribeFromChannel(deliveryChannel);
    }
  }

  // ─── Map Logic ─────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateRouteAndMarkers();
  }

  LatLng _getDriverLocation() {
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      if (dash.currentLat.value != 0.0 && dash.currentLng.value != 0.0) {
        return LatLng(dash.currentLat.value, dash.currentLng.value);
      }
    }
    return const LatLng(30.7046486, 76.7178726);
  }

  Future<BitmapDescriptor> _getBitmapFromAsset(String path, int targetWidth, {BitmapDescriptor? fallback}) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: targetWidth,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (_) {}
    return fallback ?? BitmapDescriptor.defaultMarker;
  }

  Future<void> _updateRouteAndMarkers() async {
    final o = order.value;
    if (o == null) return;

    markers.clear();
    polylines.clear();

    final driverPos = _getDriverLocation();
    final pickupPos = LatLng(
      o.pickupLat != 0.0 ? o.pickupLat : 30.7046486,
      o.pickupLng != 0.0 ? o.pickupLng : 76.7178726,
    );
    final dropoffPos = LatLng(
      o.deliveryLat != 0.0 ? o.deliveryLat : 30.70825659,
      o.deliveryLng != 0.0 ? o.deliveryLng : 76.68600194,
    );

    final driverIcon = await _getBitmapFromAsset(
      'assets/images/deliveryScooter.png',
      110,
      fallback: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );
    final pickupIcon = await _getBitmapFromAsset(
      'assets/images/pickupLocation.png',
      95,
      fallback: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    final dropoffIcon = await _getBitmapFromAsset(
      'assets/images/dropOffLocation.png',
      95,
      fallback: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    if (!isHeadingToDropoff.value) {
      // ─── STAGE 1: Heading to Pickup (Driver -> Restaurant) ────────────────
      markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: driverPos,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: driverIcon,
          zIndex: 10,
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('pickup_location'),
          position: pickupPos,
          infoWindow: InfoWindow(
            title: o.pickupShortAddress.isNotEmpty
                ? 'Store: ${o.pickupShortAddress}'
                : 'Pickup Location',
          ),
          icon: pickupIcon,
          zIndex: 5,
        ),
      );

      await _fetchRoutePolylines(driverPos, pickupPos);
    } else {
      // ─── STAGE 2: Heading to Dropoff (Driver -> Customer) ──────────────
      markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: driverPos,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: driverIcon,
          zIndex: 10,
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('pickup_location'),
          position: pickupPos,
          infoWindow: InfoWindow(
            title: o.pickupShortAddress.isNotEmpty
                ? 'Store: ${o.pickupShortAddress}'
                : 'Pickup Location',
          ),
          icon: pickupIcon,
          zIndex: 2,
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('dropoff_location'),
          position: dropoffPos,
          infoWindow: InfoWindow(
            title: o.deliveryShortAddress.isNotEmpty
                ? 'Customer: ${o.deliveryShortAddress}'
                : 'Dropoff Location',
          ),
          icon: dropoffIcon,
          zIndex: 5,
        ),
      );

      final originPos = (driverPos.latitude != 30.7046486 || driverPos.longitude != 76.7178726)
          ? driverPos
          : pickupPos;
      await _fetchRoutePolylines(originPos, dropoffPos);
    }
  }

  Future<void> _fetchRoutePolylines(LatLng origin, LatLng destination) async {
    List<LatLng> routePoints = [origin, destination];

    try {
      final dio = Dio();
      final url =
          'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
      final response = await dio.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.data != null &&
          response.data['routes'] is List &&
          (response.data['routes'] as List).isNotEmpty) {
        final geometry = response.data['routes'][0]['geometry'];
        if (geometry != null && geometry['coordinates'] is List) {
          final rawCoords = geometry['coordinates'] as List;
          final List<LatLng> fetchedPoints = [];
          for (var c in rawCoords) {
            if (c is List && c.length >= 2) {
              final lng = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              fetchedPoints.add(LatLng(lat, lng));
            }
          }
          if (fetchedPoints.isNotEmpty) {
            routePoints = fetchedPoints;
          }
        }
      }
    } catch (_) {
      // Fallback direct line
    }

    polylines.add(
      Polyline(
        polylineId: const PolylineId('active_delivery_route'),
        points: routePoints,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );

    _fitBoundsForPoints(routePoints);
  }

  void _fitBoundsForPoints(List<LatLng> points) {
    if (points.isEmpty || mapController == null || isClosed) return;

    try {
      if (points.length == 1) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 15),
        );
        return;
      }

      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (var p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      if ((maxLat - minLat).abs() < 0.0001 && (maxLng - minLng).abs() < 0.0001) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15),
        );
        return;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (_) {
      // Ignore camera animation errors when widget/controller is disposed
    }
  }

  final isUpdatingStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    String? deliveryId;

    if (args is OrderModel) {
      order.value = args;
      deliveryId = args.id;
      isHeadingToDropoff.value = args.isPickedUp;
      _checkStatusAndRedirectIfNeeded();
    } else if (args is String) {
      deliveryId = args;
    } else if (args is Map) {
      deliveryId = (args['delivery_id'] ?? args['id'] ?? args['order_id'] ?? '').toString();
      try {
        final ord = OrderModel.fromJson(Map<String, dynamic>.from(args));
        order.value = ord;
        isHeadingToDropoff.value = ord.isPickedUp;
        _checkStatusAndRedirectIfNeeded();
      } catch (_) {}
    }

    if (deliveryId != null && deliveryId.isNotEmpty) {
      _fetchTrackingDetails(deliveryId);
      _setupRealtimeListeners(deliveryId);
    } else {
      _fetchCurrentActiveDelivery();
    }

    // Refresh route whenever order or stage changes
    ever(order, (_) => _updateRouteAndMarkers());
    ever(isHeadingToDropoff, (_) => _updateRouteAndMarkers());
  }

  @override
  void onClose() {
    _removeRealtimeListeners(order.value?.id);
    mapController = null;
    super.onClose();
  }

  void _checkStatusAndRedirectIfNeeded() {
    final o = order.value;
    if (o == null) return;

    if (o.isDelivered) {
      if (Get.currentRoute != AppRoutes.dashboard) {
        AppUtils.showSuccess('Delivery completed successfully!');
        Get.offAllNamed(AppRoutes.dashboard);
      }
      return;
    }

    if (o.isPickedUp) {
      isHeadingToDropoff.value = true;
      if (Get.currentRoute == AppRoutes.orderPickup) {
        Get.offNamed(
          AppRoutes.activeDelivery,
          arguments: o,
        );
      }
      return;
    }

    if (o.isReachedRestaurant) {
      if (Get.currentRoute != AppRoutes.orderPickup) {
        Get.offNamed(
          AppRoutes.orderPickup,
          arguments: o,
        );
      }
      return;
    }
  }

  Future<void> _fetchTrackingDetails(String deliveryId) async {
    if (deliveryId.isEmpty) {
      await _fetchCurrentActiveDelivery();
      return;
    }
    await runAsync(() async {
      try {
        final res = await _orderRepo.getDeliveryTracking(deliveryId);
        if (res.success && res.data != null) {
          _populateOrder(res.data!);
          return;
        }
      } catch (_) {}

      // Fallback to order detail or active delivery
      try {
        final orderRes = await _orderRepo.getOrderDetail(deliveryId);
        if (orderRes.success && orderRes.data != null) {
          _populateOrder(orderRes.data!);
          return;
        }
      } catch (_) {}

      await _fetchCurrentActiveDelivery();
    }, showLoadingIndicator: false);
  }

  Future<void> _fetchCurrentActiveDelivery() async {
    try {
      final activeRes = await _orderRepo.getCurrentActiveDelivery();
      if (activeRes.success && activeRes.data != null) {
        _populateOrder(activeRes.data!);
        _setupRealtimeListeners(activeRes.data!.id);
        if (activeRes.data!.pickupAddress.isEmpty) {
          _fetchTrackingDetails(activeRes.data!.id);
        }
      }
    } catch (_) {}
  }

  void _populateOrder(OrderModel newOrder) {
    if (order.value != null) {
      order.value = order.value!.copyWith(
        id: newOrder.id.isNotEmpty ? newOrder.id : order.value!.id,
        orderId: newOrder.orderId.isNotEmpty ? newOrder.orderId : order.value!.orderId,
        status: newOrder.status.isNotEmpty ? newOrder.status : order.value!.status,
        deliveryStatus: newOrder.deliveryStatus ?? order.value!.deliveryStatus,
        orderStatus: newOrder.orderStatus ?? order.value!.orderStatus,
        customerName: newOrder.customerName.isNotEmpty ? newOrder.customerName : order.value!.customerName,
        customerPhone: newOrder.customerPhone.isNotEmpty ? newOrder.customerPhone : order.value!.customerPhone,
        restaurantName: newOrder.restaurantName?.isNotEmpty == true ? newOrder.restaurantName : order.value!.restaurantName,
        restaurantPhone: newOrder.restaurantPhone?.isNotEmpty == true ? newOrder.restaurantPhone : order.value!.restaurantPhone,
        restaurantImage: newOrder.restaurantImage?.isNotEmpty == true ? newOrder.restaurantImage : order.value!.restaurantImage,
        pickupAddress: newOrder.pickupAddress.isNotEmpty ? newOrder.pickupAddress : order.value!.pickupAddress,
        pickupShortAddress: newOrder.pickupShortAddress.isNotEmpty ? newOrder.pickupShortAddress : order.value!.pickupShortAddress,
        deliveryAddress: newOrder.deliveryAddress.isNotEmpty ? newOrder.deliveryAddress : order.value!.deliveryAddress,
        deliveryShortAddress: newOrder.deliveryShortAddress.isNotEmpty ? newOrder.deliveryShortAddress : order.value!.deliveryShortAddress,
        pickupLat: newOrder.pickupLat != 0.0 ? newOrder.pickupLat : order.value!.pickupLat,
        pickupLng: newOrder.pickupLng != 0.0 ? newOrder.pickupLng : order.value!.pickupLng,
        deliveryLat: newOrder.deliveryLat != 0.0 ? newOrder.deliveryLat : order.value!.deliveryLat,
        deliveryLng: newOrder.deliveryLng != 0.0 ? newOrder.deliveryLng : order.value!.deliveryLng,
        earnings: newOrder.earnings > 0 ? newOrder.earnings : order.value!.earnings,
        distanceKm: newOrder.distanceKm > 0 ? newOrder.distanceKm : order.value!.distanceKm,
        distanceMiles: newOrder.distanceMiles > 0 ? newOrder.distanceMiles : order.value!.distanceMiles,
        estimatedMinutes: newOrder.estimatedMinutes > 0 ? newOrder.estimatedMinutes : order.value!.estimatedMinutes,
        notes: newOrder.notes?.isNotEmpty == true ? newOrder.notes : order.value!.notes,
        items: newOrder.items.isNotEmpty ? newOrder.items : order.value!.items,
      );
    } else {
      order.value = newOrder;
    }
    isHeadingToDropoff.value = order.value?.isPickedUp ?? false;
    _checkStatusAndRedirectIfNeeded();
  }

  void reachedPickup() async {
    final delId = order.value?.id ?? '';
    final currentStatus = order.value?.status ?? '';
    
    final isAlreadyReached = currentStatus == 'reached_restaurant' ||
        currentStatus == 'arrived_at_restaurant' ||
        order.value?.isReachedRestaurant == true ||
        order.value?.isPickedUp == true;

    if (isAlreadyReached) {
      Get.offNamed(
        AppRoutes.orderPickup,
        arguments: order.value,
      );
      return;
    }

    if (delId.isEmpty) {
      AppUtils.showError('Invalid delivery ID');
      return;
    }

    bool success = false;
    isUpdatingStatus.value = true;
    try {
      final res = await _orderRepo.updateDeliveryStatus(
        deliveryId: delId,
        status: 'reached_restaurant',
      );
      if (res.success) {
        success = true;
        AppUtils.showSuccess(res.message.isNotEmpty ? res.message : 'Reached restaurant.');
        if (order.value != null) {
          order.value = order.value!.copyWith(status: 'reached_restaurant');
        }
      } else {
        AppUtils.showError(res.message.isNotEmpty ? res.message : 'Failed to update status.');
      }
    } catch (e) {
      AppUtils.showError('Something went wrong. Please try again.');
    } finally {
      isUpdatingStatus.value = false;
    }

    if (success) {
      Get.offNamed(
        AppRoutes.orderPickup,
        arguments: order.value,
      );
    }
  }

  void goToPickupVerification() async {
    final success = await Get.toNamed(
      AppRoutes.deliveryVerification,
      arguments: {'order': order.value, 'type': VerificationType.pickup},
    );

    if (success == true) {
      if (order.value != null) {
        order.value = order.value!.copyWith(status: 'picked_up');
      }
      isHeadingToDropoff.value = true;
      Get.offNamed(
        AppRoutes.activeDelivery,
        arguments: order.value,
      );
    }
  }

  void reachedDropoff() async {
    final delId = order.value?.id ?? '';
    final currentStatus = order.value?.status ?? '';

    final isAlreadyReachedCustomer = currentStatus == 'reached_customer' ||
        currentStatus == 'arrived' ||
        currentStatus == 'driver_reached';

    if (isAlreadyReachedCustomer) {
      Get.toNamed(
        AppRoutes.deliveryVerification,
        arguments: {'order': order.value, 'type': VerificationType.delivery},
      );
      return;
    }

    if (delId.isEmpty) {
      AppUtils.showError('Invalid delivery ID');
      return;
    }

    isUpdatingStatus.value = true;
    try {
      final res = await _orderRepo.updateDeliveryStatus(
        deliveryId: delId,
        status: 'reached_customer',
      );
      if (res.success) {
        AppUtils.showSuccess(res.message.isNotEmpty ? res.message : 'Reached customer location.');
        if (order.value != null) {
          order.value = order.value!.copyWith(status: 'reached_customer');
        }
        Get.toNamed(
          AppRoutes.deliveryVerification,
          arguments: {'order': order.value, 'type': VerificationType.delivery},
        );
      } else {
        AppUtils.showError(res.message.isNotEmpty ? res.message : 'Failed to update status.');
      }
    } catch (e) {
      AppUtils.showError('Something went wrong. Please try again.');
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  void callStore() {
    final phone = order.value?.restaurantPhone?.trim().isNotEmpty == true
        ? order.value!.restaurantPhone!
        : (order.value?.customerPhone?.trim().isNotEmpty == true ? order.value!.customerPhone! : '');
    if (phone.isNotEmpty) {
      AppUtils.makePhoneCall(phone);
    } else {
      AppUtils.makePhoneCall('+447911123456');
    }
  }

  void callCustomer() {
    final phone = order.value?.customerPhone?.trim() ?? '';
    if (phone.isNotEmpty) {
      AppUtils.makePhoneCall(phone);
    } else {
      AppUtils.makePhoneCall('+447911123456');
    }
  }

  void openHelpCenter() {
    Get.toNamed(AppRoutes.support, arguments: {'order': order.value});
  }
}
