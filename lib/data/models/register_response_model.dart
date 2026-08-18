import 'user_model.dart';

class RegisterResponseModel {
  final UserModel? user;
  final String? token;

  const RegisterResponseModel({this.user, this.token});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user?.toJson(),
        if (token != null) 'token': token,
      };
}
