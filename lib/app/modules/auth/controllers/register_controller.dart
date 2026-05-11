import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_utils.dart';
import '../../../../data/local/app_data.dart';

class RegisterController extends BaseController {
  // ─── Step ──────────────────────────────────────────────────────────────────

  final currentStep = 1.obs; // 1=Bank 2=Vehicle 3=Documents

  // ─── Basic info ────────────────────────────────────────────────────────────

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ─── Email OTP ──────────────────────────────────────────────────────────────

  final showEmailOtp = false.obs;
  final emailVerified = false.obs;
  final isEmailOtpLoading = false.obs;
  final emailOtpControllers =
      List.generate(4, (_) => TextEditingController());
  final emailOtpFocusNodes = List.generate(4, (_) => FocusNode());

  // ─── Phone OTP ──────────────────────────────────────────────────────────────

  final showPhoneOtp = false.obs;
  final phoneVerified = false.obs;
  final isPhoneOtpLoading = false.obs;
  final phoneOtpControllers =
      List.generate(4, (_) => TextEditingController());
  final phoneOtpFocusNodes = List.generate(4, (_) => FocusNode());

  // ─── Bank details ───────────────────────────────────────────────────────────

  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final sortCodeController = TextEditingController();
  final bankNameController = TextEditingController();

  // ─── Vehicle details ────────────────────────────────────────────────────────

  final vehicleType = Rxn<String>();
  final registrationNumberController = TextEditingController();
  final vehicleMake = Rxn<String>();
  final vehicleModel = Rxn<String>();
  final vehicleColorController = TextEditingController();
  final yearOfManufacture = Rxn<DateTime>();
  final insuranceType = Rxn<String>();
  final insuranceExpiry = Rxn<DateTime>();
  final motExpiry = Rxn<DateTime>();

  static const vehicleTypes = ['Motorcycle', 'Scooter', 'Bicycle', 'Car', 'Van'];
  static const vehicleMakes = ['Honda', 'Yamaha', 'Kawasaki', 'Suzuki', 'KTM', 'BMW', 'Triumph', 'Piaggio', 'Vespa', 'Ford', 'Vauxhall', 'Volkswagen', 'Mercedes-Benz'];
  static const vehicleModels = ['CB125R', 'CB500F', 'MT-07', 'MT-125', 'Z400', 'Z125', 'GSX-S125', 'Duke 390', 'C 400 GT', 'Street Triple', 'MP3 300', 'GTV 300', 'Transit Custom', 'Vivaro', 'Transporter'];
  static const insuranceTypes = ['Third Party Only', 'Third Party, Fire & Theft', 'Comprehensive'];

  // ─── Document upload ────────────────────────────────────────────────────────

  final licenceFrontUploaded = false.obs;
  final licenceBackUploaded = false.obs;
  final idProofUploaded = false.obs;
  final insuranceCertUploaded = false.obs;

  // ─── Email OTP actions ──────────────────────────────────────────────────────

  Future<void> sendEmailOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !AppUtils.isValidEmail(email)) {
      AppUtils.showError('Please enter a valid email address');
      return;
    }
    isEmailOtpLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isEmailOtpLoading.value = false;
    showEmailOtp.value = true;
    AppUtils.showSuccess('Code sent to $email');
  }

  void onEmailOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      emailOtpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      emailOtpFocusNodes[index - 1].requestFocus();
    }
    if (emailOtpControllers.every((c) => c.text.length == 1)) {
      _verifyEmailOtp();
    }
  }

  Future<void> _verifyEmailOtp() async {
    await Future.delayed(const Duration(milliseconds: 500));
    emailVerified.value = true;
    showEmailOtp.value = false;
    for (final c in emailOtpControllers) { c.clear(); }
    AppUtils.showSuccess('Email verified!');
  }

  // ─── Phone OTP actions ──────────────────────────────────────────────────────

  Future<void> sendPhoneOtp() async {
    if (phoneController.text.trim().isEmpty) {
      AppUtils.showError('Please enter your mobile number');
      return;
    }
    isPhoneOtpLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isPhoneOtpLoading.value = false;
    showPhoneOtp.value = true;
    final num = phoneController.text.trim();
    final display = num.startsWith('0') ? '+44 ${num.substring(1)}' : num;
    AppUtils.showSuccess('OTP sent to $display');
  }

  void onPhoneOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      phoneOtpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      phoneOtpFocusNodes[index - 1].requestFocus();
    }
    if (phoneOtpControllers.every((c) => c.text.length == 1)) {
      _verifyPhoneOtp();
    }
  }

  Future<void> _verifyPhoneOtp() async {
    await Future.delayed(const Duration(milliseconds: 500));
    phoneVerified.value = true;
    showPhoneOtp.value = false;
    for (final c in phoneOtpControllers) { c.clear(); }
    AppUtils.showSuccess('Phone number verified!');
  }

  // ─── Registration actions ────────────────────────────────────────────────────

  Future<void> register() async {
    if (nameController.text.trim().isEmpty) {
      AppUtils.showError('Please enter your full name');
      return;
    }
    if (!emailVerified.value) {
      AppUtils.showError('Please verify your email address');
      return;
    }
    if (!phoneVerified.value) {
      AppUtils.showError('Please verify your mobile number');
      return;
    }
    await runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      currentStep.value = 1;
      Get.toNamed(AppRoutes.registerSteps);
    });
  }

  Future<void> continueBankDetails() async {
    await runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      currentStep.value = 2;
    });
  }

  Future<void> continueVehicleDetails() async {
    await runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      currentStep.value = 3;
    });
  }

  Future<void> submitDocuments() async {
    await runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      AuthService.to.saveSession(
        accessToken: 'sd_access_token',
        refreshToken: 'sd_refresh_token',
        user: AppData.user,
      );
      Get.toNamed(AppRoutes.verificationPending);
    });
  }

  void toggleUpload(String docType) {
    switch (docType) {
      case 'licence_front': licenceFrontUploaded.value = !licenceFrontUploaded.value;
      case 'licence_back': licenceBackUploaded.value = !licenceBackUploaded.value;
      case 'id_proof': idProofUploaded.value = !idProofUploaded.value;
      case 'insurance': insuranceCertUploaded.value = !insuranceCertUploaded.value;
    }
  }

  Future<void> pickDate(BuildContext context, Rxn<DateTime> target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: target.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null) target.value = picked;
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
    vehicleColorController.dispose();
    for (final c in emailOtpControllers) { c.dispose(); }
    for (final c in phoneOtpControllers) { c.dispose(); }
    for (final f in emailOtpFocusNodes) { f.dispose(); }
    for (final f in phoneOtpFocusNodes) { f.dispose(); }
    super.onClose();
  }
}
