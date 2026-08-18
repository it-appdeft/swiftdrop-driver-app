class VehicleTypeModel {
  final String slug;
  final String name;
  final bool requiresInsurance;
  final bool requiresDrivingLicence;

  const VehicleTypeModel({
    required this.slug,
    required this.name,
    required this.requiresInsurance,
    required this.requiresDrivingLicence,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      slug: json['slug'] as String,
      name: json['name'] as String,
      requiresInsurance: json['requires_insurance'] as bool? ?? true,
      requiresDrivingLicence: json['requires_driving_licence'] as bool? ?? true,
    );
  }
}
