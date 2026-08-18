import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/vehicle_type_model.dart';
import '../../../../data/repositories/driver_repository.dart';
import '../../../base/base_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utils.dart';

class AccountDetailsController extends BaseController {
  final DriverRepository _driverRepo;
  AccountDetailsController(this._driverRepo);
  // Bank Details
  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final sortCodeController = TextEditingController();
  final bankNameController = TextEditingController();

  // Vehicle Details
  final registrationNumberController = TextEditingController();
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();
  
  final Rxn<DateTime> yearOfManufacture = Rxn<DateTime>();
  final Rxn<DateTime> insuranceExpiry = Rxn<DateTime>();
  final Rxn<DateTime> motExpiry = Rxn<DateTime>();
  
  final RxnString insuranceTypeValue = RxnString();
  
  final vehicleTypesList = <VehicleTypeModel>[].obs;
  
  final Rxn<VehicleTypeModel> selectedVehicleType = Rxn<VehicleTypeModel>();

  bool get requiresInsurance => selectedVehicleType.value?.requiresInsurance ?? true;
  bool get requiresDrivingLicence => selectedVehicleType.value?.requiresDrivingLicence ?? true;

  DriverDocumentModel? getUploadedDoc(String type) {
    final docs = AuthService.to.user?.documents ?? [];
    try {
      return docs.firstWhere((d) => d.type == type);
    } catch (_) {
      return null;
    }
  }

  // Document Files
  final licenceFrontFile = Rxn<File>();
  final licenceBackFile = Rxn<File>();
  final idProofFile = Rxn<File>();
  final insuranceCertFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    fetchVehicleTypes();
    fetchDriverProfile();
  }

  Future<void> fetchVehicleTypes() async {
    try {
      final res = await _driverRepo.getVehicleTypes();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        vehicleTypesList.assignAll(res.data!);
        _matchSelectedVehicleType();
      }
    } catch (e) {
      debugPrint('Error fetching vehicle types: $e');
    }
  }

  Future<void> fetchDriverProfile() async {
    try {
      final res = await _driverRepo.getProfile();
      AppLogger.i('[DRIVER PROFILE RESPONSE]: ${res.data}');
      if (res.success && res.data != null) {
        AuthService.to.updateUser(res.data!);
        _loadSavedData();
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
    }
  }

  void _matchSelectedVehicleType() {
    final u = AuthService.to.user;
    if (u?.vehicleType != null && u!.vehicleType!.isNotEmpty) {
      try {
        selectedVehicleType.value = vehicleTypesList.firstWhere(
          (v) =>
              v.slug.toLowerCase() == u.vehicleType!.toLowerCase() ||
              v.name.toLowerCase() == u.vehicleType!.toLowerCase(),
        );
      } catch (_) {}
    }
  }

  void _loadSavedData() {
    final u = AuthService.to.user;
    if (u == null) return;

    if (u.accountHolderName != null && u.accountHolderName!.isNotEmpty) {
      accountHolderController.text = u.accountHolderName!;
    }
    if (u.accountNumber != null && u.accountNumber!.isNotEmpty && !u.accountNumber!.contains('*')) {
      accountNumberController.text = u.accountNumber!;
    }
    if (u.sortCode != null && u.sortCode!.isNotEmpty) {
      sortCodeController.text = u.sortCode!;
    }
    if (u.bankName != null && u.bankName!.isNotEmpty) {
      bankNameController.text = u.bankName!;
    }

    if (u.vehicleNumber != null && u.vehicleNumber!.isNotEmpty) {
      registrationNumberController.text = u.vehicleNumber!;
    }
    if (u.vehicleMake != null && u.vehicleMake!.isNotEmpty) {
      vehicleMakeController.text = u.vehicleMake!;
    }
    if (u.vehicleModel != null && u.vehicleModel!.isNotEmpty) {
      vehicleModelController.text = u.vehicleModel!;
    }
    if (u.vehicleColor != null && u.vehicleColor!.isNotEmpty) {
      vehicleColorController.text = u.vehicleColor!;
    }

    if (u.yearOfManufacture != null && u.yearOfManufacture! > 0) {
      yearOfManufacture.value = DateTime(u.yearOfManufacture!);
    }
    if (u.insuranceExpiryDate != null && u.insuranceExpiryDate!.isNotEmpty) {
      insuranceExpiry.value = DateTime.tryParse(u.insuranceExpiryDate!);
    }
    if (u.motExpiryDate != null && u.motExpiryDate!.isNotEmpty) {
      motExpiry.value = DateTime.tryParse(u.motExpiryDate!);
    }
    if (u.insuranceType != null && u.insuranceType!.isNotEmpty) {
      insuranceTypeValue.value = u.insuranceType;
    }
    _matchSelectedVehicleType();
  }

  @override
  void onClose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    sortCodeController.dispose();
    bankNameController.dispose();
    registrationNumberController.dispose();
    vehicleMakeController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context, Rxn<DateTime> target, {DateTime? firstDate, DateTime? lastDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: target.value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
    );
    if (picked != null) {
      target.value = picked;
    }
  }

  String _getInsuranceTypeSlug(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('third') && lower.contains('theft')) return 'third_party_fire_theft';
    if (lower.contains('third')) return 'third_party';
    return 'comprehensive';
  }

  void updateDetails() {
    runAsync(() async {
      final accNum = accountNumberController.text.trim();

      final map = <String, dynamic>{
        'account_holder_name': accountHolderController.text.trim(),
        if (accNum.isNotEmpty && !accNum.contains('*'))
          'account_number': accNum,
        'sort_code': sortCodeController.text.trim(),
        'bank_name': bankNameController.text.trim(),
        'vehicle_type': selectedVehicleType.value?.slug ?? 'car',
        'vehicle_registration': registrationNumberController.text.trim(),
        'vehicle_make': vehicleMakeController.text.trim(),
        'vehicle_model': vehicleModelController.text.trim(),
        'vehicle_color': vehicleColorController.text.trim(),
        if (yearOfManufacture.value != null)
          'year_of_manufacture': yearOfManufacture.value!.year.toString(),
        if (requiresInsurance && insuranceTypeValue.value != null)
          'insurance_type': _getInsuranceTypeSlug(insuranceTypeValue.value!),
        if (requiresInsurance && insuranceExpiry.value != null)
          'insurance_expiry_date':
              DateFormat('yyyy-MM-dd').format(insuranceExpiry.value!),
        if (motExpiry.value != null)
          'mot_expiry_date':
              DateFormat('yyyy-MM-dd').format(motExpiry.value!),
      };

      if (requiresDrivingLicence && licenceFrontFile.value != null) {
        map['documents[driving_licence_front]'] = licenceFrontFile.value;
      }
      if (requiresDrivingLicence && licenceBackFile.value != null) {
        map['documents[driving_licence_back]'] = licenceBackFile.value;
      }
      if (idProofFile.value != null) {
        map['documents[id_proof]'] = idProofFile.value;
      }
      if (requiresInsurance && insuranceCertFile.value != null) {
        map['documents[insurance_certificate]'] = insuranceCertFile.value;
      }

      AppLogger.i('[SUBMIT PROFILE SETUP PAYLOAD]: $map');
      final res = await _driverRepo.completeProfileSetup(map);
      AppLogger.i('[SUBMIT PROFILE SETUP RESPONSE]: ${res.data}');

      if (res.success) {
        if (res.data != null) {
          try {
            final updatedUser = UserModel.fromJson(res.data!);
            AuthService.to.updateUser(updatedUser);
          } catch (e) {
            debugPrint('Error updating local user model: $e');
          }
        }
        AppUtils.showSuccess(res.message.isNotEmpty
            ? res.message
            : 'Profile setup submitted for verification.');
        Get.toNamed(AppRoutes.verificationPending,
            arguments: {'mode': 'review_updates'});
      } else {
        AppUtils.showError(
            res.message.isNotEmpty ? res.message : 'Failed to update account details');
      }
    });
  }

  void setDocument(String type, File file) {
    switch (type) {
      case 'licence_front': licenceFrontFile.value = file; break;
      case 'licence_back': licenceBackFile.value = file; break;
      case 'id_proof': idProofFile.value = file; break;
      case 'insurance': insuranceCertFile.value = file; break;
    }
  }

  void clearDocument(String type) {
    switch (type) {
      case 'licence_front': licenceFrontFile.value = null; break;
      case 'licence_back': licenceBackFile.value = null; break;
      case 'id_proof': idProofFile.value = null; break;
      case 'insurance': insuranceCertFile.value = null; break;
    }
  }
}
