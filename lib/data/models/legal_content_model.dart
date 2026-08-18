class LegalContentModel {
  final String html;
  final List<String> paragraphs;

  LegalContentModel({
    required this.html,
    required this.paragraphs,
  });

  factory LegalContentModel.fromJson(Map<String, dynamic> json) {
    return LegalContentModel(
      html: json['html'] as String? ?? '',
      paragraphs: (json['paragraphs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'html': html,
      'paragraphs': paragraphs,
    };
  }
}
