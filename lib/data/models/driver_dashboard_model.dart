class DriverDashboardModel {
  final String availability;
  final bool isOnline;
  final String approvalStatus;
  final bool isSetupComplete;
  final LocationPoint? currentLocation;
  final EarningsData? earnings;
  final int deliveriesToday;
  final int timeOnlineMinutes;
  final int deliveryRequestTimeoutSeconds;

  DriverDashboardModel({
    required this.availability,
    required this.isOnline,
    required this.approvalStatus,
    required this.isSetupComplete,
    this.currentLocation,
    this.earnings,
    required this.deliveriesToday,
    required this.timeOnlineMinutes,
    required this.deliveryRequestTimeoutSeconds,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    return DriverDashboardModel(
      availability: json['availability'] as String? ?? 'offline',
      isOnline: json['is_online'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      isSetupComplete: json['is_setup_complete'] as bool? ?? false,
      currentLocation: json['current_location'] != null
          ? LocationPoint.fromJson(
              json['current_location'] as Map<String, dynamic>)
          : null,
      earnings: json['earnings'] != null
          ? EarningsData.fromJson(json['earnings'] as Map<String, dynamic>)
          : null,
      deliveriesToday: (json['deliveries_today'] as num?)?.toInt() ?? 0,
      timeOnlineMinutes: (json['time_online_minutes'] as num?)?.toInt() ?? 0,
      deliveryRequestTimeoutSeconds:
          (json['delivery_request_timeout_seconds'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availability': availability,
      'is_online': isOnline,
      'approval_status': approvalStatus,
      'is_setup_complete': isSetupComplete,
      if (currentLocation != null) 'current_location': currentLocation!.toJson(),
      if (earnings != null) 'earnings': earnings!.toJson(),
      'deliveries_today': deliveriesToday,
      'time_online_minutes': timeOnlineMinutes,
      'delivery_request_timeout_seconds': deliveryRequestTimeoutSeconds,
    };
  }
}

class LocationPoint {
  final double lat;
  final double lng;

  LocationPoint({required this.lat, required this.lng});

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class EarningsData {
  final double today;
  final String currency;

  EarningsData({required this.today, required this.currency});

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      today: (json['today'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'GBP',
    );
  }

  Map<String, dynamic> toJson() => {
        'today': today,
        'currency': currency,
      };
}
