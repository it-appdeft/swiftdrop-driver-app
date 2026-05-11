class OrderModel {
  final String id;
  final String orderId;
  final String status;
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
  final int estimatedMinutes;
  final double earnings;
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
    this.estimatedMinutes = 0,
    required this.earnings,
    this.notes,
    this.items = const [],
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String? ?? '',
        orderId: json['order_id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        customerName: json['customer_name'] as String? ?? '',
        customerPhone: json['customer_phone'] as String? ?? '',
        pickupAddress: json['pickup_address'] as String? ?? '',
        pickupShortAddress: json['pickup_short_address'] as String? ?? '',
        deliveryAddress: json['delivery_address'] as String? ?? '',
        deliveryShortAddress: json['delivery_short_address'] as String? ?? '',
        pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0.0,
        pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0.0,
        deliveryLat: (json['delivery_lat'] as num?)?.toDouble() ?? 0.0,
        deliveryLng: (json['delivery_lng'] as num?)?.toDouble() ?? 0.0,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
        estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
        earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String?,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['created_at'] as String),
        acceptedAt: json['accepted_at'] != null
            ? DateTime.tryParse(json['accepted_at'] as String)
            : null,
        pickedUpAt: json['picked_up_at'] != null
            ? DateTime.tryParse(json['picked_up_at'] as String)
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.tryParse(json['delivered_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'status': status,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'pickup_address': pickupAddress,
        'delivery_address': deliveryAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'delivery_lat': deliveryLat,
        'delivery_lng': deliveryLng,
        'distance_km': distanceKm,
        'estimated_minutes': estimatedMinutes,
        'earnings': earnings,
        if (notes != null) 'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  OrderModel copyWith({
    String? status,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) =>
      OrderModel(
        id: id,
        orderId: orderId,
        status: status ?? this.status,
        customerName: customerName,
        customerPhone: customerPhone,
        pickupAddress: pickupAddress,
        pickupShortAddress: pickupShortAddress,
        deliveryAddress: deliveryAddress,
        deliveryShortAddress: deliveryShortAddress,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        deliveryLat: deliveryLat,
        deliveryLng: deliveryLng,
        distanceKm: distanceKm,
        estimatedMinutes: estimatedMinutes,
        earnings: earnings,
        notes: notes,
        items: items,
        createdAt: createdAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        pickedUpAt: pickedUpAt ?? this.pickedUpAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
      );

  bool get isNew => status == 'new' || status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPickedUp => status == 'picked_up';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => !isDelivered && !isCancelled;
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        name: json['name'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}
