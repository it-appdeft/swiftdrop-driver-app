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
    int parseInt(dynamic value, int fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic value, bool fallback) {
      if (value == null) return fallback;
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase().trim();
        return lower == 'true' || lower == '1' || lower == 'online';
      }
      return fallback;
    }

    return DriverDashboardModel(
      availability: json['availability']?.toString() ?? 'offline',
      isOnline: parseBool(
        json['is_online'] ?? (json['availability'] == 'online'),
        false,
      ),
      approvalStatus: json['approval_status']?.toString() ?? 'pending',
      isSetupComplete: parseBool(json['is_setup_complete'], false),
      currentLocation: json['current_location'] is Map<String, dynamic>
          ? LocationPoint.fromJson(
              json['current_location'] as Map<String, dynamic>)
          : null,
      earnings: json['earnings'] is Map<String, dynamic>
          ? EarningsData.fromJson(json['earnings'] as Map<String, dynamic>)
          : null,
      deliveriesToday: parseInt(json['deliveries_today'], 0),
      timeOnlineMinutes: parseInt(json['time_online_minutes'], 0),
      deliveryRequestTimeoutSeconds:
          parseInt(json['delivery_request_timeout_seconds'], 30),
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return LocationPoint(
      lat: parseDouble(json['lat'] ?? json['latitude']),
      lng: parseDouble(json['lng'] ?? json['longitude']),
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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return EarningsData(
      today: parseDouble(json['today'] ?? json['amount'] ?? json['earnings']),
      currency: json['currency']?.toString() ?? 'GBP',
    );
  }

  Map<String, dynamic> toJson() => {
        'today': today,
        'currency': currency,
      };
}
