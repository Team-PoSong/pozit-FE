// API 연동을 위한 필드 값을 통일합니다.

// ExampleResponse
class ExampleModel {
  final int id;
  final String title;
  final String summary;
  final String? link;
  final String backgroundImageUrl;

  const ExampleModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.link,
    required this.backgroundImageUrl,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id:                 json['id']                 as int,
      title:              json['title']              as String,
      summary:            json['summary']            as String,
      link:               json['link']               as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String,
    );
  }
}