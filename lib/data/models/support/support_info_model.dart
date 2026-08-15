class SupportInfoModel {
  const SupportInfoModel({
    required this.serviceTerm,
    required this.privacyPolicy,
  });

  final TermModel serviceTerm;
  final TermModel privacyPolicy;
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
}

class TermSectionModel {
  const TermSectionModel({required this.title, required this.content});

  final String title;
  final String content;
}
