import 'package:swiftdrop_driver_app/app/config/app_config.dart';

class DriverDocumentModel {
  final int id;
  final String type;
  final String fileUrl;
  final String? originalFilename;
  final String? verificationStatus;
  final String? createdAt;

  DriverDocumentModel({
    required this.id,
    required this.type,
    required this.fileUrl,
    this.originalFilename,
    this.verificationStatus,
    this.createdAt,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    String url = json['file_url'] as String? ?? json['url'] as String? ?? '';
    if (url.isNotEmpty && !url.startsWith('http://') && !url.startsWith('https://')) {
      url = '${AppConfig.imageUrl}$url';
    }
    return DriverDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      fileUrl: url,
      originalFilename: json['original_filename'] as String?,
      verificationStatus: json['verification_status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String? countryCode;
  final String? countryIso;
  final String? status;
  final List<String> roles;
  
  // Profile Fields
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? vehicleType;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? vehicleColor;
  final int? yearOfManufacture;
  final String? insuranceType;
  final String? insuranceExpiryDate;
  final String? motExpiryDate;
  
  // Bank Details
  final String? accountHolderName;
  final String? accountNumber;
  final String? sortCode;
  final String? bankName;

  // Documents
  final List<DriverDocumentModel> documents;
  
  // Settings & Status
  final bool notifyDeliveryUpdates;
  final bool notifyGeneral;
  final String? availability;
  final String? approvalStatus;
  final int setupStep;
  final bool isVerified;
  
  // Stats
  final double? rating;
  final int totalDeliveries;
  final double walletBalance;
  
  // Location
  final double? currentLat;
  final double? currentLng;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.countryCode,
    this.countryIso,
    this.status,
    this.roles = const [],
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.vehicleType,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleNumber,
    this.vehicleColor,
    this.yearOfManufacture,
    this.insuranceType,
    this.insuranceExpiryDate,
    this.motExpiryDate,
    this.accountHolderName,
    this.accountNumber,
    this.sortCode,
    this.bankName,
    this.documents = const [],
    this.notifyDeliveryUpdates = true,
    this.notifyGeneral = true,
    this.availability,
    this.approvalStatus,
    this.setupStep = 0,
    this.isVerified = false,
    this.rating,
    this.totalDeliveries = 0,
    this.walletBalance = 0.0,
    this.currentLat,
    this.currentLng,
    this.createdAt,
    this.updatedAt,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${AppConfig.imageUrl}$path';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Pick the base user data source
    // It could be in 'user' key (Get Profile API) or top-level (Login/Verify OTP API)
    final userPart = (json['user'] ?? json) as Map<String, dynamic>;
    
    // Pick the profile data source
    // In Get Profile API, profile fields are both at top level and nested in user.profile
    // In Login/Verify OTP API, they are in user.profile
    final profilePart = (json['profile'] ?? userPart['profile'] ?? json) as Map<String, dynamic>?;

    // Redundant but specific sources for certain API structures
    final vehiclePart = (json['vehicle'] ?? profilePart?['vehicle']) as Map<String, dynamic>?;
    final bankPart = (json['bank'] ?? profilePart?['bank']) as Map<String, dynamic>?;
    final setupPart = (json['setup'] ?? profilePart?['setup']) as Map<String, dynamic>?;
    final notifyPart = (json['notifications'] ?? profilePart?['notifications']) as Map<String, dynamic>?;

    final rawDocs = (json['documents'] ?? profilePart?['documents']) as List?;
    final docsList = rawDocs != null
        ? rawDocs
            .map((e) => DriverDocumentModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <DriverDocumentModel>[];

    return UserModel(
      documents: docsList,
      id: userPart['id']?.toString() ?? json['id']?.toString() ?? '',
      name: userPart['name'] as String? ?? json['name'] as String? ?? '',
      phone: (userPart['mobile'] ?? userPart['phone'] ?? json['mobile'] ?? json['phone']) as String? ?? '',
      email: (userPart['email'] ?? json['email']) as String?,
      status: (json['status'] ?? userPart['status']) as String?,
      roles: (userPart['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      
      // Profile mapping
      firstName: (json['first_name'] ?? profilePart?['first_name']) as String?,
      lastName: (json['last_name'] ?? profilePart?['last_name']) as String?,
      avatar: _resolveUrl(
        (json['profile_photo'] ?? userPart['profile_photo'] ?? profilePart?['profile_photo'] ?? userPart['avatar']) as String?,
      ),
      countryCode: (userPart['country_code'] ?? json['country_code']) as String?,
      countryIso: (userPart['country_iso'] ?? json['country_iso']) as String?,
      dateOfBirth: (json['date_of_birth'] ?? profilePart?['date_of_birth']) as String?,
      
      // Vehicle details (check top-level 'vehicle' then 'profile')
      vehicleType: (vehiclePart?['vehicle_type'] ?? json['vehicle_type'] ?? profilePart?['vehicle_type'] ?? userPart['vehicle_type']) as String?,
      vehicleMake: (vehiclePart?['vehicle_make'] ?? profilePart?['vehicle_make']) as String?,
      vehicleModel: (vehiclePart?['vehicle_model'] ?? profilePart?['vehicle_model']) as String?,
      vehicleNumber: (vehiclePart?['registration_number'] ?? json['vehicle_registration'] ?? profilePart?['vehicle_registration'] ?? userPart['vehicle_number']) as String?,
      vehicleColor: (vehiclePart?['vehicle_color'] ?? profilePart?['vehicle_color']) as String?,
      yearOfManufacture: _parseInt(vehiclePart?['year_of_manufacture'] ?? profilePart?['year_of_manufacture']),
      insuranceType: (vehiclePart?['insurance_type'] ?? profilePart?['insurance_type']) as String?,
      insuranceExpiryDate: (vehiclePart?['insurance_expiry_date'] ?? profilePart?['insurance_expiry_date']) as String?,
      motExpiryDate: (vehiclePart?['mot_expiry_date'] ?? profilePart?['mot_expiry_date']) as String?,
      
      // Bank details
      accountHolderName: (bankPart?['account_holder_name'] ?? profilePart?['account_holder_name']) as String?,
      accountNumber: (bankPart?['account_number'] ?? profilePart?['account_number']) as String?,
      sortCode: (bankPart?['sort_code'] ?? profilePart?['sort_code']) as String?,
      bankName: (bankPart?['bank_name'] ?? profilePart?['bank_name']) as String?,
      
      // Settings & Status
      notifyDeliveryUpdates: (notifyPart?['notify_delivery_updates'] ?? profilePart?['notify_delivery_updates']) as bool? ?? true,
      notifyGeneral: (notifyPart?['notify_general'] ?? profilePart?['notify_general']) as bool? ?? true,
      availability: (json['availability'] ?? profilePart?['availability']) as String?,
      approvalStatus: (json['approval_status'] ?? profilePart?['approval_status']) as String?,
      setupStep: _parseInt(setupPart?['current_step'] ?? profilePart?['setup_step'] ?? userPart['setup_step']) ?? 0,
      
      isVerified: (json['is_verified'] ?? (profilePart?['approval_status'] == 'approved')) as bool? ?? false,
      
      rating: _parseDouble(userPart['rating'] ?? profilePart?['rating']),
      totalDeliveries: _parseInt(userPart['total_deliveries']) ?? 0,
      walletBalance: _parseDouble(userPart['wallet_balance']) ?? 0.0,
      
      currentLat: _parseDouble(profilePart?['current_lat'] ?? userPart['current_lat']),
      currentLng: _parseDouble(profilePart?['current_lng'] ?? userPart['current_lng']),
      
      createdAt: userPart['created_at'] != null
          ? DateTime.tryParse(userPart['created_at'] as String)
          : null,
      updatedAt: (json['updated_at'] ?? userPart['updated_at'] ?? profilePart?['updated_at']) != null
          ? DateTime.tryParse((json['updated_at'] ?? userPart['updated_at'] ?? profilePart?['updated_at']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (countryCode != null) 'country_code': countryCode,
        if (countryIso != null) 'country_iso': countryIso,
        if (status != null) 'status': status,
        'roles': roles,
        'profile': {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (avatar != null) 'profile_photo': avatar,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (vehicleType != null) 'vehicle_type': vehicleType,
          if (vehicleMake != null) 'vehicle_make': vehicleMake,
          if (vehicleModel != null) 'vehicle_model': vehicleModel,
          if (vehicleNumber != null) 'vehicle_registration': vehicleNumber,
          if (vehicleColor != null) 'vehicle_color': vehicleColor,
          if (yearOfManufacture != null) 'year_of_manufacture': yearOfManufacture,
          if (insuranceType != null) 'insurance_type': insuranceType,
          if (insuranceExpiryDate != null) 'insurance_expiry_date': insuranceExpiryDate,
          if (motExpiryDate != null) 'mot_expiry_date': motExpiryDate,
          if (accountHolderName != null) 'account_holder_name': accountHolderName,
          if (accountNumber != null) 'account_number': accountNumber,
          if (sortCode != null) 'sort_code': sortCode,
          if (bankName != null) 'bank_name': bankName,
          'notify_delivery_updates': notifyDeliveryUpdates,
          'notify_general': notifyGeneral,
          if (availability != null) 'availability': availability,
          if (approvalStatus != null) 'approval_status': approvalStatus,
          'setup_step': setupStep,
          if (currentLat != null) 'current_lat': currentLat,
          if (currentLng != null) 'current_lng': currentLng,
          if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        },
        'is_verified': isVerified,
        if (rating != null) 'rating': rating,
        'total_deliveries': totalDeliveries,
        'wallet_balance': walletBalance,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  bool get isActive => status == 'active';
  bool get isOnline => availability == 'online';

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? countryCode,
    String? countryIso,
    String? status,
    String? availability,
    int? setupStep,
    double? walletBalance,
    String? vehicleType,
    String? vehicleNumber,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        avatar: avatar ?? this.avatar,
        countryCode: countryCode ?? this.countryCode,
        countryIso: countryIso ?? this.countryIso,
        status: status ?? this.status,
        roles: roles,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        vehicleType: vehicleType ?? this.vehicleType,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        vehicleColor: vehicleColor,
        yearOfManufacture: yearOfManufacture,
        insuranceType: insuranceType,
        insuranceExpiryDate: insuranceExpiryDate,
        motExpiryDate: motExpiryDate,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        sortCode: sortCode,
        bankName: bankName,
        documents: documents,
        notifyDeliveryUpdates: notifyDeliveryUpdates,
        notifyGeneral: notifyGeneral,
        availability: availability ?? this.availability,
        approvalStatus: approvalStatus,
        setupStep: setupStep ?? this.setupStep,
        isVerified: isVerified,
        rating: rating,
        totalDeliveries: totalDeliveries,
        walletBalance: walletBalance ?? this.walletBalance,
        currentLat: currentLat,
        currentLng: currentLng,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
