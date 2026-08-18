import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import 'delivery_verification_controller.dart';

class ActiveDeliveryController extends BaseController {
  final OrderRepository _orderRepo;

  ActiveDeliveryController(this._orderRepo);

  final order = Rxn<OrderModel>();
  
  // false = heading to pickup (SS1), true = heading to dropoff (SS3)
  final isHeadingToDropoff = false.obs;

  // ─── Map Logic ─────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateMarkers();
  }

  void _updateMarkers() {
    final o = order.value;
    if (o == null) return;

    markers.clear();
    
    // Pickup Marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(o.pickupLat, o.pickupLng),
        infoWindow: InfoWindow(title: 'Pickup: ${o.pickupShortAddress}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    // Dropoff Marker
    markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(o.deliveryLat, o.deliveryLng),
        infoWindow: InfoWindow(title: 'Dropoff: ${o.deliveryShortAddress}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    _fitBounds();
  }

  void _fitBounds() {
    final o = order.value;
    if (o == null || mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        o.pickupLat < o.deliveryLat ? o.pickupLat : o.deliveryLat,
        o.pickupLng < o.deliveryLng ? o.pickupLng : o.deliveryLng,
      ),
      northeast: LatLng(
        o.pickupLat > o.deliveryLat ? o.pickupLat : o.deliveryLat,
        o.pickupLng > o.deliveryLng ? o.pickupLng : o.deliveryLng,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is OrderModel) {
      order.value = args;
      isHeadingToDropoff.value = args.isPickedUp;
    }
    
    // Refresh markers if order changes
    ever(order, (_) => _updateMarkers());
  }

  void reachedPickup() async {
    final success = await Get.toNamed('/delivery-verification', arguments: {
      'order': order.value,
      'type': VerificationType.pickup,
    });
    
    if (success == true) {
      isHeadingToDropoff.value = true;
    }
  }

  void reachedDropoff() {
    Get.toNamed('/delivery-verification', arguments: {
      'order': order.value,
      'type': VerificationType.delivery,
    });
  }

  void callStore() {
    // Implementation
  }

  void callCustomer() {
    // Implementation
  }
}
