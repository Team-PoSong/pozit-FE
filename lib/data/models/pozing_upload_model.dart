class PozingPresignedUrlResponse {
  final String presignedUrl;

  /// 업로드 세션 식별자입니다. savePozing에 전달할 S3 objectKey와는 다른
  /// 값이며(실제 objectKey는 presignedUrl의 경로에 들어 있음), savePozing
  /// 호출에는 사용하지 않습니다.
  final String uploadId;

  const PozingPresignedUrlResponse({
    required this.presignedUrl,
    required this.uploadId,
  });

  /// presignedUrl 경로에서 추출한 실제 S3 objectKey입니다.
  /// 예: ".../pozings/2/1/uuid.mp4?X-Amz-..." -> "pozings/2/1/uuid.mp4"
  String get objectKey => Uri.parse(presignedUrl).path.replaceFirst('/', '');

  factory PozingPresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PozingPresignedUrlResponse(
      presignedUrl: json['presignedUrl'] as String,
      uploadId: json['uploadId'] as String,
    );
  }
}

class PozingSaveResponse {
  final int pozingId;
  final int? courseSpotId;
  final String pozingObjectKey;
  final String pozingUrl;
  final String thumbnailUrl;

  const PozingSaveResponse({
    required this.pozingId,
    this.courseSpotId,
    required this.pozingObjectKey,
    required this.pozingUrl,
    required this.thumbnailUrl,
  });

  factory PozingSaveResponse.fromJson(Map<String, dynamic> json) {
    return PozingSaveResponse(
      pozingId: json['pozingId'] as int,
      courseSpotId: json['courseSpotId'] as int?,
      pozingObjectKey: json['pozingObjectKey'] as String? ?? '',
      pozingUrl: json['pozingUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }
}
