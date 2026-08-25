class SupportInfoModel {
  const SupportInfoModel({
    required this.serviceTerm,
    required this.privacyPolicy,
    required this.locationTerm,
  });

  final TermModel serviceTerm;
  final TermModel privacyPolicy;
  final TermModel? locationTerm;

  factory SupportInfoModel.fromJson(Map<String, dynamic> json) {
    return SupportInfoModel(
      serviceTerm: TermModel.fromJson(
        json['serviceTerm'] as Map<String, dynamic>,
      ),
      privacyPolicy: TermModel.fromJson(
        json['privacyPolicy'] as Map<String, dynamic>,
      ),
      locationTerm: switch (json['locationTerm']) {
        final Map<String, dynamic> locationTerm =>
          TermModel.fromJson(locationTerm),
        _ => null,
      },
    );
  }
}

class TermModel {
  const TermModel({
    required this.title,
    required this.version,
    required this.sections,
    this.effectiveDate,
  });

  final String title;
  final String version;
  final DateTime? effectiveDate;
  final List<TermSectionModel> sections;

  factory TermModel.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    if (sections is! List<dynamic>) {
      throw const FormatException('약관 본문 형식이 올바르지 않습니다.');
    }
    return TermModel(
      title: json['title'] as String,
      version: json['version'] as String,
      effectiveDate: (json['effectiveDate'] as String?) != null
          ? DateTime.parse(json['effectiveDate'] as String)
          : null,
      sections: sections
          .map(
            (section) => TermSectionModel.fromJson(
              section as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }
}

class TermSectionModel {
  const TermSectionModel({required this.title, required this.content});

  final String title;
  final String content;

  factory TermSectionModel.fromJson(Map<String, dynamic> json) {
    return TermSectionModel(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
