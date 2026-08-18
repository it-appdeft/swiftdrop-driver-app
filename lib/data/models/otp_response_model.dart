class OtpResponseModel {
  final String? target;
  final int? expiresIn;
  final String? testCode;

  const OtpResponseModel({
    this.target,
    this.expiresIn,
    this.testCode,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      target: json['target']?.toString(),
      expiresIn: json['expires_in'] as int?,
      testCode: json['test_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (target != null) 'target': target,
        'expires_in': expiresIn,
        'test_code': testCode,
      };
}
