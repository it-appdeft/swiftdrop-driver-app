import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../constants/api_params.dart';
import '../../../constants/auth_enums.dart';
import '../../../themes/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/app_strings.dart';
import '../../../routes/app_routes.dart';
import '../../../constants/storage_keys.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/models/register_response_model.dart';
import '../../../../data/models/vehicle_type_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class RegisterController extends BaseController {
  final AuthRepository _repo;
  RegisterController(this._repo);

  // ─── Step Logic ────────────────────────────────────────────────────────────

  final currentStep = 1.obs; // 1=Bank 2=Vehicle 3=Documents
  int _initialStep = 1;
  int get initialStep => _initialStep;

  String _lastEmailText = '';
  String _lastPhoneText = '';

  // ─── Basic Info Form ───────────────────────────────────────────────────────

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final emailLength = 0.obs;
  final isEmailValid = false.obs;
  final phoneController = TextEditingController();
  final phoneLength = 0.obs;
  final avatarFile = Rxn<File>();

  // ─── Country Picker ────────────────────────────────────────────────────────

  final Rx<Country> selectedCountry = Country.parse('GB').obs; // Default to UK (+44)

  String get dialCode => '+${selectedCountry.value.phoneCode}';
  String get flagEmoji => selectedCountry.value.flagEmoji;
  String get isoCode => selectedCountry.value.countryCode;

  void onCountrySelected(Country country) =>
      selectedCountry.value = country;

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return AppStrings.mobileNumberRequired;
    if (phone.length < 8 || phone.length > 12) {
      return AppStrings.mobileNumberInvalid;
    }
    return null;
  }

  // ─── Email OTP Section ─────────────────────────────────────────────────────

  final showEmailOtp = false.obs;
  final emailVerified = false.obs;
  final isEmailSending = false.obs;
  final isEmailVerifying = false.obs;
  final emailOtpController = TextEditingController();
  final emailOtpFocusNode = FocusNode();
  final emailResendTimer = 0.obs;
  final isEmailOtpComplete = false.obs;

  // ─── Phone OTP Section ─────────────────────────────────────────────────────

  final showPhoneOtp = false.obs;
  final phoneVerified = false.obs;
  final isPhoneSending = false.obs;
  final isPhoneVerifying = false.obs;
  final phoneOtpController = TextEditingController();
  final phoneOtpFocusNode = FocusNode();
  final phoneResendTimer = 0.obs;
  final isPhoneOtpComplete = false.obs;

  // ─── Bank Details Form ─────────────────────────────────────────────────────

  final bankFormKey = GlobalKey<FormState>();
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final sortCodeController = TextEditingController();
  final bankNameController = TextEditingController();

  String? validateAccountHolder(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterAccountHolderName;
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    final val = value?.trim() ?? '';
    if (val.isEmpty) {
      return AppStrings.accountNumberRequired;
    }
    if (!RegExp(r'^\d{6,12}$').hasMatch(val)) {
      return AppStrings.accountNumberInvalid;
    }
    return null;
  }

  String? validateSortCode(String? value) {
    final val = value?.trim() ?? '';
    if (val.isEmpty) {
      return AppStrings.sortCodeRequired;
    }
    // Matches XXXXXX or XX-XX-XX
    if (!RegExp(r'^(\d{6}|\d{2}-\d{2}-\d{2})$').hasMatch(val)) {
      return AppStrings.sortCodeInvalid;
    }
    return null;
  }

  String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.enterBankName;
    }
    return null;
  }

  // ─── Vehicle Details Form ──────────────────────────────────────────────────

  final vehicleTypesList = <VehicleTypeModel>[].obs;
  final selectedVehicleType = Rxn<VehicleTypeModel>();
  final registrationNumberController = TextEditingController();
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();
  final yearOfManufacture = Rxn<DateTime>();
  final insuranceTypeValue = Rxn<String>();
  final insuranceExpiry = Rxn<DateTime>();
  final motExpiry = Rxn<DateTime>();

  static const insuranceTypes = [
    'Comprehensive',
    'Third Party',
    'Third Party, Fire & Theft',
  ];

  static const _insuranceTypeBackendValues = {
    'Comprehensive': 'comprehensive',
    'Third Party': 'third_party',
    'Third Party, Fire & Theft': 'third_party_fire_theft',
  };

  bool get requiresInsurance => selectedVehicleType.value?.requiresInsurance ?? true;
  bool get requiresDrivingLicence => selectedVehicleType.value?.requiresDrivingLicence ?? true;

  // ─── Document Upload Section ───────────────────────────────────────────────

  final licenceFrontFile = Rxn<File>();
  final licenceBackFile = Rxn<File>();
  final idProofFile = Rxn<File>();
  final insuranceCertFile = Rxn<File>();

  bool get licenceFrontUploaded => licenceFrontFile.value != null;
  bool get licenceBackUploaded => licenceBackFile.value != null;
  bool get idProofUploaded => idProofFile.value != null;
  bool get insuranceCertUploaded => insuranceCertFile.value != null;

  // ─── Vehicle Types API ────────────────────────────────────────────────────
  Future<void> loadVehicleTypes() async {
    await runAsync(() async {
      final result = await _repo.getVehicleTypes();
      if (result.success && result.data != null) {
        vehicleTypesList.value = result.data!;
      }
    }, showLoadingIndicator: false);
  }

  // ─── Send Email OTP API ────────────────────────────────────────────────────
  Future<void> sendEmailOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !AppUtils.isValidEmail(email)) {
      AppUtils.showError(AppConstants.enterValidEmail);
      return;
    }
    
    isEmailSending.value = true;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        email: email,
        type: AuthOtpType.signup,
        channel: AuthChannel.email,
      );
      if (result.success) {
        showEmailOtp.value = true;
        _startEmailResendTimer();
        final testCode = result.data?.testCode ?? '1111';
        AppUtils.showSuccess(AppStrings.otpSentSuccess.replaceFirst('%s', testCode));
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
    isEmailSending.value = false;
  }

  void _startEmailResendTimer() {
    emailResendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (emailResendTimer.value <= 0) return false;
      emailResendTimer.value--;
      return emailResendTimer.value > 0;
    });
  }

  void onEmailOtpChanged(String value) {
    isEmailOtpComplete.value = value.length == 4;
  }

  // ─── Verify Email OTP API ──────────────────────────────────────────────────
  Future<void> verifyEmailOtp() async {
    final email = emailController.text.trim();
    final otp = emailOtpController.text;
    if (otp.length < 4) {
      AppUtils.showError(AppConstants.enterCompleteOtp);
      return;
    }

    isEmailVerifying.value = true;
    await runAsync(() async {
      final result = await _repo.verifyOtp(
        email: email,
        otp: otp,
        type: AuthOtpType.signup,
        channel: AuthChannel.email,
      );
      if (result.success) {
        emailVerified.value = true;
        showEmailOtp.value = false;
        emailOtpController.clear();
        AppUtils.showSuccess(AppStrings.verified);
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
    isEmailVerifying.value = false;
  }

  // ─── Send Phone OTP API ────────────────────────────────────────────────────
  Future<void> sendPhoneOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppUtils.showError(AppConstants.enterMobileNumber);
      return;
    }

    isPhoneSending.value = true;
    await runAsync(() async {
      final result = await _repo.sendOtp(
        countryCode: dialCode,
        countryIso: isoCode,
        phone: phone,
        email: emailController.text.trim(),
        type: AuthOtpType.signup,
        channel: AuthChannel.phone,
      );
      if (result.success) {
        showPhoneOtp.value = true;
        _startPhoneResendTimer();
        final testCode = result.data?.testCode ?? '1111';
        AppUtils.showSuccess(AppStrings.otpSentSuccess.replaceFirst('%s', testCode));
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
    isPhoneSending.value = false;
  }

  void _startPhoneResendTimer() {
    phoneResendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (phoneResendTimer.value <= 0) return false;
      phoneResendTimer.value--;
      return phoneResendTimer.value > 0;
    });
  }

  void onPhoneOtpChanged(String value) {
    isPhoneOtpComplete.value = value.length == 4;
  }

  // ─── Verify Phone OTP API ──────────────────────────────────────────────────
  Future<void> verifyPhoneOtp() async {
    final phone = phoneController.text.trim();
    final otp = phoneOtpController.text;
    if (otp.length < 4) {
      AppUtils.showError(AppConstants.enterCompleteOtp);
      return;
    }

    isPhoneVerifying.value = true;
    await runAsync(() async {
      final result = await _repo.verifyOtp(
        phone: phone,
        countryCode: dialCode,
        countryIso: isoCode,
        email: emailController.text.trim(),
        otp: otp,
        type: AuthOtpType.signup,
        channel: AuthChannel.phone,
      );
      if (result.success) {
        phoneVerified.value = true;
        showPhoneOtp.value = false;
        phoneOtpController.clear();
        AppUtils.showSuccess(AppStrings.verified);
      } else {
        throw Exception(result.message);
      }
    }, showLoadingIndicator: false);
    isPhoneVerifying.value = false;
  }

  // ─── Register Driver API ───────────────────────────────────────────────────
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      AppUtils.showError(AppConstants.enterFullName);
      return;
    }
    if (avatarFile.value == null) {
      AppUtils.showError(AppStrings.profilePictureRequired);
      return;
    }
    if (!emailVerified.value) {
      AppUtils.showError(AppConstants.verifyEmailFirst);
      return;
    }
    if (!phoneVerified.value) {
      AppUtils.showError(AppConstants.verifyPhoneFirst);
      return;
    }

    await runAsync(() async {
      final result = await _repo.registerDriver(
        name: name,
        email: email,
        phone: phone,
        countryCode: dialCode,
        countryIso: isoCode,
        profileImage: avatarFile.value,
      );

      if (!result.success || result.data == null) {
        throw Exception(result.message);
      }

      final data = result.data!;
      final token = data.token;
      final user = data.user;
      if (token == null || token.isEmpty || user == null) {
        throw Exception(result.message);
      }

      AuthService.to.saveSession(
        accessToken: token,
        refreshToken: '',
        user: user,
      );
      
      StorageService.to.writeData(StorageKeys.registerData, data);

      final storedRegister = StorageService.to.readData<RegisterResponseModel>(
        StorageKeys.registerData,
        fromJson: (j) => RegisterResponseModel.fromJson(j),
      );
      AppLogger.i('Saved auth token: ${StorageService.to.authToken}');
      AppLogger.i('Saved user: ${StorageService.to.user?.toJson()}');
      AppLogger.i('Saved register data: ${storedRegister?.toJson()}');

      AppUtils.showSuccess(result.message);
      currentStep.value = 1;
      Get.toNamed(AppRoutes.registerSteps);
    });
  }

  // ─── Registration Flow Actions ─────────────────────────────────────────────

  Future<void> continueBankDetails() async {
    final holderError = validateAccountHolder(accountHolderController.text);
    if (holderError != null) {
      AppUtils.showError(holderError);
      return;
    }

    final numberError = validateAccountNumber(accountNumberController.text);
    if (numberError != null) {
      AppUtils.showError(numberError);
      return;
    }

    final sortError = validateSortCode(sortCodeController.text);
    if (sortError != null) {
      AppUtils.showError(sortError);
      return;
    }

    final bankError = validateBankName(bankNameController.text);
    if (bankError != null) {
      AppUtils.showError(bankError);
      return;
    }

    final holder = accountHolderController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final sortCode = sortCodeController.text.trim();
    final bankName = bankNameController.text.trim();

    await runAsync(() async {
      final result = await _repo.setupProfile(
        step: 1,
        data: {
          ApiParams.accountHolderName: holder,
          ApiParams.accountNumber: accountNumber,
          ApiParams.sortCode: sortCode,
          ApiParams.bankName: bankName,
        },
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      AppUtils.showSuccess(result.message);
      
      // Load vehicle types specifically for Step 2
      loadVehicleTypes();

      currentStep.value = 2;
    });
  }
// ─── Vehicle details ───────────────────────────────────────────────────
  Future<void> continueVehicleDetails() async {
    final type = selectedVehicleType.value;
    final reg = registrationNumberController.text.trim().toUpperCase();
    final make = vehicleMakeController.text.trim();
    final model = vehicleModelController.text.trim();
    final color = vehicleColorController.text.trim();
    final year = yearOfManufacture.value;
    final insType = insuranceTypeValue.value;
    final insExpiry = insuranceExpiry.value;

    if (type == null) {
      AppUtils.showError(AppStrings.vehicleTypeRequired);
      return;
    }
    if (reg.isEmpty) {
      AppUtils.showError(AppStrings.vrnRequired);
      return;
    }
    if (make.isEmpty) {
      AppUtils.showError(AppStrings.vehicleMakeRequired);
      return;
    }
    if (model.isEmpty) {
      AppUtils.showError(AppStrings.vehicleModelRequired);
      return;
    }
    if (color.isEmpty) {
      AppUtils.showError(AppStrings.vehicleColorRequired);
      return;
    }
    if (year == null) {
      AppUtils.showError(AppStrings.yearRequired);
      return;
    }
    if (requiresInsurance) {
      if (insType == null) {
        AppUtils.showError(AppStrings.insuranceTypeRequired);
        return;
      }
      if (insExpiry == null) {
        AppUtils.showError(AppStrings.insuranceExpiryRequired);
        return;
      }
    }

    await runAsync(() async {
      final result = await _repo.setupProfile(
        step: 2,
        data: {
          ApiParams.vehicleType: type.slug,
          ApiParams.vehicleRegistration: reg,
          ApiParams.vehicleMake: make,
          ApiParams.vehicleModel: model,
          ApiParams.vehicleColor: color,
          ApiParams.yearOfManufacture: year.year.toString(),
          if (requiresInsurance && insType != null) ApiParams.insuranceType: _insuranceTypeBackendValues[insType] ?? insType,
          if (requiresInsurance && insExpiry != null)
            ApiParams.insuranceExpiryDate: _formatYmd(insExpiry),
          if (motExpiry.value != null)
            ApiParams.motExpiryDate: _formatYmd(motExpiry.value!),
        },
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      AppUtils.showSuccess(result.message);
      currentStep.value = 3;
    });
  }
// ─── Submit Documents ───────────────────────────────────────────────────
  Future<void> submitDocuments() async {
    final licenceFront = licenceFrontFile.value;
    final licenceBack = licenceBackFile.value;
    final idProof = idProofFile.value;
    final insuranceCert = insuranceCertFile.value;

    if (requiresDrivingLicence) {
      if (licenceFront == null) {
        AppUtils.showError(AppStrings.drivingLicenceFrontRequired);
        return;
      }
      if (licenceBack == null) {
        AppUtils.showError(AppStrings.drivingLicenceBackRequired);
        return;
      }
    }

    if (idProof == null) {
      AppUtils.showError(AppStrings.idProofRequired);
      return;
    }

    if (requiresInsurance && insuranceCert == null) {
      AppUtils.showError(AppStrings.insuranceCertificateRequired);
      return;
    }

    await runAsync(() async {
      final result = await _repo.setupProfile(
        step: 3,
        data: {
          if (requiresDrivingLicence && licenceFront != null)
            ApiParams.docDrivingLicenceFront: licenceFront,
          if (requiresDrivingLicence && licenceBack != null)
            ApiParams.docDrivingLicenceBack: licenceBack,
          ApiParams.docIdProof: idProof,
          if (requiresInsurance && insuranceCert != null)
            ApiParams.docInsuranceCertificate: insuranceCert,
        },
      );

      if (!result.success) {
        throw Exception(result.message);
      }

      AppUtils.showSuccess(result.message);
      Get.toNamed(AppRoutes.verificationPending);
    });
  }

  String _formatYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── State Reset Helpers ───────────────────────────────────────────────────

  void resetBankDetails() {
    accountHolderController.clear();
    accountNumberController.clear();
    sortCodeController.clear();
    bankNameController.clear();
  }

  void resetVehicleDetails() {
    selectedVehicleType.value = null;
    registrationNumberController.clear();
    vehicleMakeController.clear();
    vehicleModelController.clear();
    vehicleColorController.clear();
    yearOfManufacture.value = null;
    insuranceTypeValue.value = null;
    insuranceExpiry.value = null;
    motExpiry.value = null;
  }

  void resetDocumentUpload() {
    licenceFrontFile.value = null;
    licenceBackFile.value = null;
    idProofFile.value = null;
    insuranceCertFile.value = null;
  }

  void setDocument(String docType, File file) {
    switch (docType) {
      case 'licence_front': licenceFrontFile.value = file;
      case 'licence_back': licenceBackFile.value = file;
      case 'id_proof': idProofFile.value = file;
      case 'insurance': insuranceCertFile.value = file;
    }
  }

  void clearDocument(String docType) {
    switch (docType) {
      case 'licence_front': licenceFrontFile.value = null;
      case 'licence_back': licenceBackFile.value = null;
      case 'id_proof': idProofFile.value = null;
      case 'insurance': insuranceCertFile.value = null;
    }
  }

  Future<void> pickDate(
    BuildContext context,
    Rxn<DateTime> target, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime initial = target.value ?? today;

    final first = firstDate != null
        ? DateTime(firstDate.year, firstDate.month, firstDate.day)
        : DateTime(2000);
    final last = lastDate != null
        ? DateTime(lastDate.year, lastDate.month, lastDate.day)
        : DateTime(2040);

    // Safety check: ensure initialDate is within bounds
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A1A2E),
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) target.value = picked;
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // Check for initial step from arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('step')) {
      _initialStep = args['step'] as int;
      currentStep.value = _initialStep;
    } else {
      // Fallback: check user profile if logged in
      final user = AuthService.to.user;
      if (user != null && user.setupStep > 0 && user.setupStep < 3) {
        _initialStep = user.setupStep + 1;
        currentStep.value = _initialStep;
      }
    }

    emailController.addListener(() {
      final text = emailController.text;
      if (text == _lastEmailText) return;
      _lastEmailText = text;
      emailLength.value = text.length;
      isEmailValid.value = AppUtils.isValidEmail(text.trim());
      if (emailVerified.value || showEmailOtp.value) {
        emailVerified.value = false;
        showEmailOtp.value = false;
        emailOtpController.clear();
        emailResendTimer.value = 0;
      }
    });
    phoneController.addListener(() {
      final text = phoneController.text;
      if (text == _lastPhoneText) return;
      _lastPhoneText = text;
      phoneLength.value = text.length;
      if (phoneVerified.value || showPhoneOtp.value) {
        phoneVerified.value = false;
        showPhoneOtp.value = false;
        phoneOtpController.clear();
        phoneResendTimer.value = 0;
      }
    });

    // Auto-load vehicle types when reaching Step 2 if not already loaded
    ever(currentStep, (step) {
      if (step == 2 && vehicleTypesList.isEmpty) {
        loadVehicleTypes();
      }
    });

    // Check if we are already at Step 2 on initialization
    if (currentStep.value == 2 && vehicleTypesList.isEmpty) {
      loadVehicleTypes();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    sortCodeController.dispose();
    bankNameController.dispose();
    registrationNumberController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    emailOtpController.dispose();
    emailOtpFocusNode.dispose();
    phoneOtpController.dispose();
    phoneOtpFocusNode.dispose();
    super.onClose();
  }
}
