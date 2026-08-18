class ApiParams {
  ApiParams._();

  static const String phoneNumber = 'mobile';
  static const String countryCode = 'country_code';
  static const String countryIso = 'country_iso';
  static const String email = 'email';
  static const String code = 'code';
  static const String type = 'type';
  static const String fcmToken = 'fcm_token';
  static const String name = 'name';
  static const String profileImage = 'profile_photo';
  static const String method = '_method';
  static const String vehicleType = 'vehicle_type';
  static const String vehicleNumber = 'vehicle_number';
  static const String channel = 'channel';
  static const String userType = 'user_type';

  static const String step = 'step';

  // Step 1 — Bank Details
  static const String accountHolderName = 'account_holder_name';
  static const String accountNumber = 'account_number';
  static const String sortCode = 'sort_code';
  static const String bankName = 'bank_name';

  // Step 2 — Vehicle Details
  static const String vehicleRegistration = 'vehicle_registration';
  static const String vehicleMake = 'vehicle_make';
  static const String vehicleModel = 'vehicle_model';
  static const String vehicleColor = 'vehicle_color';
  static const String yearOfManufacture = 'year_of_manufacture';
  static const String insuranceType = 'insurance_type';
  static const String insuranceExpiryDate = 'insurance_expiry_date';
  static const String motExpiryDate = 'mot_expiry_date';

  // Step 3 — Documents (multipart)
  static const String docDrivingLicenceFront =
      'documents[driving_licence_front]';
  static const String docDrivingLicenceBack =
      'documents[driving_licence_back]';
  static const String docIdProof = 'documents[id_proof]';
  static const String docInsuranceCertificate =
      'documents[insurance_certificate]';
}
