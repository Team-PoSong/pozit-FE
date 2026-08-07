class PozingPresignedUrlResponse {
  final String presignedUrl;

  final String uploadId;

  const PozingPresignedUrlResponse({
    required this.presignedUrl,
    required this.uploadId,
  });

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
