enum AuthOtpType {
  signup,
  login,
  verifyCurrentPhone,
  verifyCurrentEmail,
  updatePhone,
  updateEmail;

  String get value {
    switch (this) {
      case AuthOtpType.signup:
        return 'signup';
      case AuthOtpType.login:
        return 'login';
      case AuthOtpType.verifyCurrentPhone:
        return 'verify_current_phone';
      case AuthOtpType.verifyCurrentEmail:
        return 'verify_current_email';
      case AuthOtpType.updatePhone:
        return 'update_phone';
      case AuthOtpType.updateEmail:
        return 'update_email';
    }
  }
}

enum AuthChannel {
  phone,
  email;

  String get value => name;
}

enum UserType {
  customer,
  driver;

  String get value => name;
}
