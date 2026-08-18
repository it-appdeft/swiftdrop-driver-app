class DeletionReasonModel {
  final int id;
  final String label;
  final String slug;
  final bool isOther;
  final int sortOrder;

  DeletionReasonModel({
    required this.id,
    required this.label,
    required this.slug,
    required this.isOther,
    required this.sortOrder,
  });

  factory DeletionReasonModel.fromJson(Map<String, dynamic> json) {
    return DeletionReasonModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isOther: json['is_other'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'slug': slug,
      'is_other': isOther,
      'sort_order': sortOrder,
    };
  }
}
