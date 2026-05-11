class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;
  final int totalDeliveries;
  final bool isActive;
  final bool isVerified;
  final bool isOnline;
  final double walletBalance;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
    this.totalDeliveries = 0,
    this.isActive = false,
    this.isVerified = false,
    this.isOnline = false,
    this.walletBalance = 0.0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
        avatar: json['avatar'] as String?,
        vehicleType: json['vehicle_type'] as String?,
        vehicleNumber: json['vehicle_number'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
        totalDeliveries: json['total_deliveries'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? false,
        isOnline: json['is_online'] as bool? ?? false,
        walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (rating != null) 'rating': rating,
        'total_deliveries': totalDeliveries,
        'is_active': isActive,
        'is_verified': isVerified,
        'is_online': isOnline,
        'wallet_balance': walletBalance,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? avatar,
    String? vehicleType,
    String? vehicleNumber,
    bool? isOnline,
    double? walletBalance,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        avatar: avatar ?? this.avatar,
        vehicleType: vehicleType ?? this.vehicleType,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        rating: rating,
        totalDeliveries: totalDeliveries,
        isActive: isActive,
        isVerified: isVerified,
        isOnline: isOnline ?? this.isOnline,
        walletBalance: walletBalance ?? this.walletBalance,
        createdAt: createdAt,
      );
}
