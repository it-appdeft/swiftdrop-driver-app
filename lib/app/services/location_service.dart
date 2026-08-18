import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';
import '../widgets/app_button.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find();

  StreamSubscription<Position>? _positionStreamSub;
  Position? currentPosition;

  /// Check location service & permissions, then return current Position
  Future<Position?> getCurrentLocation({bool showDialogIfDenied = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showDialogIfDenied) {
          _showLocationServiceDisabledDialog();
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (showDialogIfDenied) {
          showLocationPermissionDialog();
        }
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      currentPosition = pos;
      return pos;
    } catch (e) {
      if (showDialogIfDenied) {
        showLocationPermissionDialog();
      }
      return null;
    }
  }

  /// Start continuous location listener
  void startLocationUpdates(Function(Position pos) onLocationChanged) {
    stopLocationUpdates();
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // update every 20 meters
    );
    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      currentPosition = position;
      onLocationChanged(position);
    });
  }

  /// Stop location listener
  void stopLocationUpdates() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  /// Show Location Permission Dialog instructing user to enable settings
  void showLocationPermissionDialog({VoidCallback? onRetry}) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.gapMd),
              Text(
                'Location Permission Required',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: AppDimensions.gapSm),
              Text(
                'SwiftDrop needs your live location to show delivery requests near you and update your status. Please grant location permission in settings.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),
              AppButton(
                label: 'Open Settings',
                onPressed: () async {
                  Get.back();
                  await openAppSettings();
                },
              ),
              const SizedBox(height: AppDimensions.gapSm),
              TextButton(
                onPressed: () {
                  Get.back();
                  if (onRetry != null) onRetry();
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.deleteRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showLocationServiceDisabledDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gps_off_rounded,
                  size: 44,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: AppDimensions.gapMd),
              Text(
                'Location Services Disabled',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: AppDimensions.gapSm),
              Text(
                'Please enable GPS / Location Services on your device to continue using the driver app.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.gapLg),
              AppButton(
                label: 'Open Location Settings',
                onPressed: () async {
                  Get.back();
                  await Geolocator.openLocationSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
