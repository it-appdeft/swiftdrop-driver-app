import 'user_model.dart';

class VerifyOtpResponseModel {
  final String? target;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? driver;

  const VerifyOtpResponseModel({
    this.target,
    this.accessToken,
    this.refreshToken,
    this.driver,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      target: json['target']?.toString(),
      accessToken: (json['access_token'] ?? json['token'])?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      driver: (json['driver'] != null || json['user'] != null)
          ? UserModel.fromJson((json['driver'] ?? json['user']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (target != null) 'target': target,
        if (accessToken != null) 'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (driver != null) 'driver': driver?.toJson(),
      };
}
