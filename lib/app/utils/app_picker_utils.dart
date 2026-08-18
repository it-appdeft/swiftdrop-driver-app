import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class AppPickerUtils {
  AppPickerUtils._();

  static final ImagePicker _picker = ImagePicker();
  static const _nativeChannel = MethodChannel('com.swiftdrop/native');

  static Future<void> showPicker({
    required Function(File file) onFilePicked,
    bool showDocument = false,
    bool crop = true,
    String? title,
  }) async {
    final context = Get.context!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Wait until the sheet is FULLY dismissed before opening any native picker.
    // Each option calls Get.back(result: source) — the Future below resolves only
    // after the dismiss animation completes, eliminating the race condition.
    final source = await Get.bottomSheet<String>(
      Container(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? (showDocument ? AppStrings.uploadDocument : AppStrings.uploadPhoto),
              style: AppTextStyles.build(
                size: 18,
                weight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildOption(
                  icon: Icons.camera_alt_outlined,
                  label: AppStrings.camera,
                  onTap: () => Get.back(result: 'camera'),
                ),
                const SizedBox(width: 20),
                _buildOption(
                  icon: Icons.photo_library_outlined,
                  label: AppStrings.gallery,
                  onTap: () => Get.back(result: 'gallery'),
                ),
                if (showDocument) ...[
                  const SizedBox(width: 20),
                  _buildOption(
                    icon: Icons.description_outlined,
                    label: AppStrings.document,
                    onTap: () => Get.back(result: 'document'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );

    if (source == null) return;

    File? file;

    if (source == 'camera') {
      if (!await _handlePermission(Permission.camera, AppStrings.camera)) return;
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo == null) return;
      file = crop ? await _cropImage(File(photo.path)) : File(photo.path);
    } else if (source == 'gallery') {
      bool granted;
      if (Platform.isIOS) {
        granted = true;
      } else {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final permission = androidInfo.version.sdkInt >= 33
            ? Permission.photos
            : Permission.storage;
        granted = await _handlePermission(permission, AppStrings.gallery);
      }
      if (!granted) return;
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) return;
      file = crop ? await _cropImage(File(image.path)) : File(image.path);
    } else if (source == 'document') {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );
      if (result == null || result.files.single.path == null) return;
      file = File(result.files.single.path!);
    }

    if (file != null) onFilePicked(file);
  }

  static Future<File?> _cropImage(File imageFile) async {
    if (Platform.isIOS) {
      await _nativeChannel.invokeMethod('dismissPresented');
    }
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primary,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  static Future<bool> _handlePermission(Permission permission, String label) async {
    PermissionStatus status = await permission.status;
    if (status.isGranted) return true;

    status = await permission.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) _showSettingsDialog(label);
    return false;
  }

  static void _showSettingsDialog(String label) {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.permissionTitle.replaceFirst('%s', label)),
        content: Text(AppStrings.permissionNeeded.replaceFirst('%s', label)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text(AppStrings.settings),
          ),
        ],
      ),
    );
  }

  static void openCountryPicker({required void Function(Country) onSelect}) {
    showCountryPicker(
      context: Get.context!,
      showPhoneCode: true,
      onSelect: onSelect,
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.white,
        textStyle: AppTextStyles.pMedium.copyWith(color: AppColors.otpTitle),
        searchTextStyle: AppTextStyles.pMedium.copyWith(color: AppColors.otpTitle),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        inputDecoration: InputDecoration(
          hintText: AppStrings.search,
          hintStyle: AppTextStyles.pMedium.copyWith(color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.otpBoxBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.build(
              size: 12,
              weight: FontWeight.w500,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
