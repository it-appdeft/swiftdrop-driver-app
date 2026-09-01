class OrderModel {
  final String id;
  final String orderId;
  final String status;
  final String? deliveryStatus;
  final String? orderStatus;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final String pickupShortAddress;
  final String deliveryAddress;
  final String deliveryShortAddress;
  final double pickupLat;
  final double pickupLng;
  final double deliveryLat;
  final double deliveryLng;
  final double distanceKm;
  final double distanceMiles;
  final int estimatedMinutes;
  final double earnings;
  final String currency;
  final String? restaurantName;
  final String? restaurantPhone;
  final String? restaurantImage;
  final double rating;
  final String? review;
  final DateTime? reviewDate;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.deliveryStatus,
    this.orderStatus,
    required this.customerName,
    required this.customerPhone,
    required this.pickupAddress,
    this.pickupShortAddress = '',
    required this.deliveryAddress,
    this.deliveryShortAddress = '',
    required this.pickupLat,
    required this.pickupLng,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.distanceKm,
    this.distanceMiles = 0.0,
    this.estimatedMinutes = 0,
    required this.earnings,
    this.currency = 'GBP',
    this.restaurantName,
    this.restaurantPhone,
    this.restaurantImage,
    this.rating = 4.0,
    this.review,
    this.reviewDate,
    this.notes,
    this.items = const [],
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final orderMap = json['order'] as Map<String, dynamic>?;

    final idVal = (json['delivery_id'] ??
            json['id'] ??
            orderMap?['id'] ??
            json['order_id'] ??
            '')
        .toString();
    final orderIdVal = (json['reference'] ??
            orderMap?['reference'] ??
            orderMap?['id'] ??
            json['order_id'] ??
            json['id'] ??
            json['order_uuid'] ??
            idVal)
        .toString();

    // Pickup address resolution (from pickup object, restaurant, or direct)
    final pickupObj = json['pickup'] as Map<String, dynamic>? ??
        orderMap?['pickup'] as Map<String, dynamic>?;
    final restaurant = json['restaurant'] as Map<String, dynamic>? ??
        orderMap?['restaurant'] as Map<String, dynamic>?;
    final restName = (restaurant?['name'] ??
            pickupObj?['name'] ??
            json['restaurant_name'] ??
            json['restaurantName'] ??
            orderMap?['restaurant_name'] ??
            '')
        .toString();
    final restPhone = (restaurant?['phone'] ??
            restaurant?['mobile'] ??
            pickupObj?['phone'] ??
            json['restaurant_phone'] ??
            orderMap?['restaurant_phone'])
        ?.toString();
    final restImage = (restaurant?['image'] ??
            restaurant?['logo'] ??
            restaurant?['banner'] ??
            json['restaurant_image'] ??
            orderMap?['restaurant_image'])
        ?.toString();

    final pickupShort = (pickupObj?['name'] ??
            restaurant?['name'] ??
            json['pickup_short_address'] ??
            (restName.isNotEmpty ? restName : null) ??
            json['restaurant_name'] ??
            '')
        .toString();

    final pickupAddr = (pickupObj?['address'] ??
            pickupObj?['full_address'] ??
            restaurant?['full_address'] ??
            restaurant?['address'] ??
            json['pickup_address'] ??
            orderMap?['pickup_address'] ??
            (pickupShort.isNotEmpty ? pickupShort : 'Store Location'))
        .toString();

    // Delivery address resolution (from dropoff object, dropoff_address, address object, or direct)
    final dropoffObj = json['dropoff'] as Map<String, dynamic>? ??
        json['dropoff_address'] as Map<String, dynamic>? ??
        orderMap?['dropoff_address'] as Map<String, dynamic>? ??
        orderMap?['dropoff'] as Map<String, dynamic>?;
    final addressObj = json['address'] as Map<String, dynamic>? ??
        orderMap?['address'] as Map<String, dynamic>?;

    String formattedDropoff = '';
    if (dropoffObj != null) {
      final parts = [
        dropoffObj['line_1'],
        dropoffObj['line_2'],
        dropoffObj['city'],
        dropoffObj['postcode'] ?? dropoffObj['zip']
      ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
      if (parts.isNotEmpty) {
        formattedDropoff = parts.join(', ');
      }
    }

    final deliveryAddr = (dropoffObj?['address'] ??
            dropoffObj?['full_address'] ??
            (formattedDropoff.isNotEmpty ? formattedDropoff : null) ??
            json['delivery_address'] ??
            orderMap?['delivery_address'] ??
            addressObj?['address_line_1'] ??
            addressObj?['full_address'] ??
            addressObj?['address'] ??
            '')
        .toString();
    final deliveryShort = (dropoffObj?['label'] ??
            dropoffObj?['line_1'] ??
            dropoffObj?['city'] ??
            json['delivery_short_address'] ??
            orderMap?['delivery_short_address'] ??
            addressObj?['label'] ??
            addressObj?['city'] ??
            deliveryAddr)
        .toString();

    // Pickup Coordinates
    final pLat = parseDouble(pickupObj?['lat'] ??
        json['pickup_lat'] ??
        restaurant?['lat'] ??
        orderMap?['pickup_lat']);
    final pLng = parseDouble(pickupObj?['lng'] ??
        json['pickup_lng'] ??
        restaurant?['lng'] ??
        orderMap?['pickup_lng']);

    // Delivery Coordinates
    final dLat = parseDouble(dropoffObj?['lat'] ??
        json['delivery_lat'] ??
        addressObj?['lat'] ??
        orderMap?['delivery_lat']);
    final dLng = parseDouble(dropoffObj?['lng'] ??
        json['delivery_lng'] ??
        addressObj?['lng'] ??
        orderMap?['delivery_lng']);

    // Earnings / Fee / Amount
    final earningsVal = parseDouble(
      json['amount'] ??
          orderMap?['amount'] ??
          json['earnings'] ??
          json['delivery_fee'] ??
          json['fee'] ??
          json['driver_earnings'] ??
          json['total'] ??
          orderMap?['total'],
    );

    final currencyVal = (json['currency'] ?? orderMap?['currency'] ?? 'GBP').toString();

    // Distance & Duration
    final rawDistMiles = parseDouble(json['distance_miles'] ?? orderMap?['distance_miles']);
    final rawDistKm = parseDouble(
        json['distance_km'] ?? orderMap?['distance_km'] ?? json['distance']);
    final distMiles = rawDistMiles > 0
        ? rawDistMiles
        : (rawDistKm > 0 ? rawDistKm * 0.621371 : 0.0);
    final distKm = rawDistKm > 0
        ? rawDistKm
        : (rawDistMiles > 0 ? rawDistMiles * 1.60934 : 0.0);

    final durationMinutesVal = parseInt(json['eta_minutes'] ??
        json['duration_minutes'] ??
        json['estimated_minutes'] ??
        orderMap?['eta_minutes'] ??
        orderMap?['estimated_minutes'] ??
        json['estimated_time'] ??
        json['duration'] ??
        json['eta'] ??
        orderMap?['duration_minutes']);

    // Customer Info
    final customer = json['customer'] as Map<String, dynamic>? ??
        orderMap?['customer'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>? ??
        orderMap?['user'] as Map<String, dynamic>?;
    final custName = (json['customer_name'] ??
            orderMap?['customer_name'] ??
            customer?['name'] ??
            json['user_name'] ??
            '')
        .toString();
    final custPhone = (json['customer_phone'] ??
            orderMap?['customer_phone'] ??
            dropoffObj?['phone'] ??
            customer?['mobile'] ??
            customer?['phone'] ??
            pickupObj?['phone'] ??
            restaurant?['phone'] ??
            '')
        .toString();

    // Dates
    DateTime parsedCreatedAt = DateTime.now();
    final rawDate = json['created_at'] ??
        orderMap?['created_at'] ??
        json['placed_at'] ??
        orderMap?['placed_at'];
    if (rawDate != null) {
      parsedCreatedAt = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      return DateTime.tryParse(val.toString());
    }

    final deliveredAtVal = parseDate(json['delivered_at'] ?? orderMap?['delivered_at']);

    // Review & Rating
    final custReview = json['customer_review'] as Map<String, dynamic>? ??
        json['review'] as Map<String, dynamic>?;
    final ratingVal = parseDouble(json['rating'] ??
        custReview?['rating'] ??
        json['customer_rating']);
    final rawReviewText = custReview?['review'] ??
        custReview?['comment'] ??
        custReview?['message'] ??
        json['review'] ??
        json['review_text'] ??
        json['feedback'];
    final String? reviewText = rawReviewText?.toString();
    final reviewDateVal = parseDate(custReview?['created_at'] ??
        json['review_date'] ??
        deliveredAtVal);

    String normalizeStatus(dynamic val) {
      if (val == null) return '';
      return val
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
    }

    // Status
    final deliveryStatusRaw = normalizeStatus(
        json['delivery_status'] ?? json['status'] ?? json['deliveryStatus']);
    final orderStatusRaw = normalizeStatus(json['order_status'] ??
        orderMap?['order_status'] ??
        orderMap?['status'] ??
        json['orderStatus']);

    String statusRaw = 'pending';
    if (deliveryStatusRaw.isNotEmpty) {
      statusRaw = deliveryStatusRaw;
    } else if (orderStatusRaw.isNotEmpty) {
      statusRaw = orderStatusRaw;
    } else if (deliveredAtVal != null) {
      statusRaw = 'delivered';
    }

    final normalizedStatus = statusRaw == 'driver_assigned' ? 'assigned' : statusRaw;

    List<OrderItemModel> parsedItems = [];
    final rawItems = json['items'] ??
        orderMap?['items'] ??
        json['order_items'] ??
        orderMap?['order_items'];

    if (rawItems is List && rawItems.isNotEmpty) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderItemModel.fromJson(e))
          .toList();
    }

    return OrderModel(
      id: idVal,
      orderId: orderIdVal,
      status: normalizedStatus,
      deliveryStatus: deliveryStatusRaw.isNotEmpty ? deliveryStatusRaw : null,
      orderStatus: orderStatusRaw.isNotEmpty ? orderStatusRaw : null,
      customerName: custName,
      customerPhone: custPhone,
      pickupAddress: pickupAddr,
      pickupShortAddress: pickupShort,
      deliveryAddress: deliveryAddr,
      deliveryShortAddress: deliveryShort,
      pickupLat: pLat,
      pickupLng: pLng,
      deliveryLat: dLat,
      deliveryLng: dLng,
      distanceKm: distKm,
      distanceMiles: distMiles,
      estimatedMinutes: durationMinutesVal,
      earnings: earningsVal,
      currency: currencyVal,
      restaurantName: restName.isNotEmpty ? restName : (pickupShort.isNotEmpty ? pickupShort : null),
      restaurantPhone: restPhone,
      restaurantImage: restImage,
      rating: ratingVal,
      review: reviewText,
      reviewDate: reviewDateVal,
      notes: dropoffObj?['instructions']?.toString() ??
          json['notes']?.toString() ??
          orderMap?['notes']?.toString() ??
          json['special_instructions']?.toString(),
      items: parsedItems,
      createdAt: parsedCreatedAt,
      acceptedAt: parseDate(json['accepted_at'] ?? orderMap?['accepted_at']),
      pickedUpAt: parseDate(json['picked_up_at'] ?? orderMap?['picked_up_at']),
      deliveredAt: deliveredAtVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'status': status,
        if (deliveryStatus != null) 'delivery_status': deliveryStatus,
        if (orderStatus != null) 'order_status': orderStatus,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'pickup_address': pickupAddress,
        'pickup_short_address': pickupShortAddress,
        'delivery_address': deliveryAddress,
        'delivery_short_address': deliveryShortAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'distance_km': distanceKm,
        'distance_miles': distanceMiles,
        'estimated_minutes': estimatedMinutes,
        'earnings': earnings,
        'currency': currency,
        if (restaurantName != null) 'restaurant_name': restaurantName,
        if (restaurantPhone != null) 'restaurant_phone': restaurantPhone,
        if (restaurantImage != null) 'restaurant_image': restaurantImage,
        'rating': rating,
        if (review != null) 'review': review,
        if (reviewDate != null) 'review_date': reviewDate!.toIso8601String(),
        if (notes != null) 'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        if (acceptedAt != null) 'accepted_at': acceptedAt!.toIso8601String(),
        if (pickedUpAt != null) 'picked_up_at': pickedUpAt!.toIso8601String(),
        if (deliveredAt != null) 'delivered_at': deliveredAt!.toIso8601String(),
      };

  OrderModel copyWith({
    String? id,
    String? orderId,
    String? status,
    String? deliveryStatus,
    String? orderStatus,
    String? customerName,
    String? customerPhone,
    String? pickupAddress,
    String? pickupShortAddress,
    String? deliveryAddress,
    String? deliveryShortAddress,
    double? pickupLat,
    double? pickupLng,
    double? deliveryLat,
    double? deliveryLng,
    double? distanceKm,
    double? distanceMiles,
    int? estimatedMinutes,
    double? earnings,
    String? currency,
    String? restaurantName,
    String? restaurantPhone,
    String? restaurantImage,
    double? rating,
    String? review,
    DateTime? reviewDate,
    String? notes,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) =>
      OrderModel(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        status: status ?? this.status,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        orderStatus: orderStatus ?? this.orderStatus,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        pickupShortAddress: pickupShortAddress ?? this.pickupShortAddress,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        deliveryShortAddress: deliveryShortAddress ?? this.deliveryShortAddress,
        pickupLat: pickupLat ?? this.pickupLat,
        pickupLng: pickupLng ?? this.pickupLng,
        deliveryLat: deliveryLat ?? this.deliveryLat,
        deliveryLng: deliveryLng ?? this.deliveryLng,
        distanceKm: distanceKm ?? this.distanceKm,
        distanceMiles: distanceMiles ?? this.distanceMiles,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        earnings: earnings ?? this.earnings,
        currency: currency ?? this.currency,
        restaurantName: restaurantName ?? this.restaurantName,
        restaurantPhone: restaurantPhone ?? this.restaurantPhone,
        restaurantImage: restaurantImage ?? this.restaurantImage,
        rating: rating ?? this.rating,
        review: review ?? this.review,
        reviewDate: reviewDate ?? this.reviewDate,
        notes: notes ?? this.notes,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        pickedUpAt: pickedUpAt ?? this.pickedUpAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
      );

  String get displayOrderId {
    if (orderId.isEmpty) return '#$id';
    return orderId.startsWith('#') ? orderId : '#$orderId';
  }

  bool get isNew =>
      (status == 'unassigned' ||
          status == 'new' ||
          status == 'pending' ||
          status == 'requested' ||
          status == 'open' ||
          status == 'searching' ||
          status == 'placed' ||
          status == 'pending_assignment') &&
      !isAssignedToDriver;

  bool get isAccepted =>
      status == 'accepted' ||
      status == 'assigned' ||
      status == 'driver_assigned' ||
      deliveryStatus == 'assigned' ||
      deliveryStatus == 'driver_assigned' ||
      deliveryStatus == 'accepted' ||
      orderStatus == 'driver_assigned';

  bool get isAssigned => isAccepted;

  bool get isReachedRestaurant =>
      status == 'reached_restaurant' ||
      status == 'arrived_at_restaurant' ||
      status == 'reached_pickup' ||
      status == 'at_restaurant' ||
      status == 'ready_for_pickup' ||
      deliveryStatus == 'reached_restaurant' ||
      deliveryStatus == 'arrived_at_restaurant' ||
      deliveryStatus == 'reached_pickup' ||
      deliveryStatus == 'at_restaurant' ||
      orderStatus == 'ready_for_pickup' ||
      orderStatus == 'reached_restaurant';

  bool get isPickedUp =>
      status == 'picked_up' ||
      status == 'out_for_delivery' ||
      status == 'on_the_way' ||
      status == 'in_transit' ||
      status == 'dispatched' ||
      status == 'reached_customer' ||
      status == 'arrived' ||
      status == 'driver_reached' ||
      deliveryStatus == 'picked_up' ||
      deliveryStatus == 'out_for_delivery' ||
      deliveryStatus == 'on_the_way' ||
      deliveryStatus == 'in_transit' ||
      deliveryStatus == 'dispatched' ||
      deliveryStatus == 'reached_customer' ||
      deliveryStatus == 'arrived' ||
      deliveryStatus == 'driver_reached' ||
      orderStatus == 'picked_up' ||
      orderStatus == 'out_for_delivery';

  bool get isReachedCustomer =>
      status == 'reached_customer' ||
      status == 'arrived' ||
      status == 'driver_reached' ||
      deliveryStatus == 'reached_customer' ||
      deliveryStatus == 'arrived' ||
      deliveryStatus == 'driver_reached' ||
      orderStatus == 'reached_customer';

  bool get isDelivered =>
      status == 'delivered' ||
      status == 'completed' ||
      deliveryStatus == 'delivered' ||
      deliveryStatus == 'completed' ||
      orderStatus == 'delivered' ||
      orderStatus == 'completed';

  bool get isCancelled =>
      status == 'cancelled' ||
      status == 'canceled' ||
      status == 'rejected' ||
      deliveryStatus == 'cancelled' ||
      deliveryStatus == 'canceled' ||
      orderStatus == 'cancelled' ||
      orderStatus == 'canceled';

  bool get isActive => !isDelivered && !isCancelled;

  bool get isAssignedToDriver =>
      isAccepted || isReachedRestaurant || isPickedUp || isReachedCustomer;

  String get displayStatus {
    if (isDelivered) return 'Delivered';
    if (isCancelled) return 'Canceled';
    if (isReachedCustomer) return 'Reached Customer';
    if (isPickedUp) return 'On the way';
    if (isReachedRestaurant) return 'Reached Restaurant';
    if (isAccepted) return 'Assigned';
    if (isNew) return 'Unassigned';
    return status.replaceAll('_', ' ');
  }
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;
  final String? options;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.options,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 1;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 1;
      return 1;
    }

    return OrderItemModel(
      name: (json['name'] ?? json['item_name'] ?? json['menu_item']?['name'] ?? 'Item')
          .toString(),
      quantity: parseInt(json['quantity'] ?? json['qty']),
      price: parseDouble(json['price'] ?? json['unit_price'] ?? json['subtotal']),
      options: json['special_instructions']?.toString() ??
          json['instructions']?.toString() ??
          json['options']?.toString() ??
          json['modifiers']?.toString() ??
          json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        if (options != null) 'options': options,
      };
}
