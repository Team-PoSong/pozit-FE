class PresignedUrlResponse {
  final String presignedUrl;
  final String fileUrl;
  final String objectKey;

  const PresignedUrlResponse({
    required this.presignedUrl,
    required this.fileUrl,
    required this.objectKey,
  });

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      presignedUrl: json['presignedUrl'] as String,
      fileUrl: json['fileUrl'] as String,
      objectKey: json['objectKey'] as String,
    );
  }
}
