class PozingPresignedUrlResponse {
  final String presignedUrl;

  final String objectKey;

  const PozingPresignedUrlResponse({
    required this.presignedUrl,
    required this.objectKey,
  });

  factory PozingPresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PozingPresignedUrlResponse(
      presignedUrl: json['presignedUrl'] as String,
      objectKey: json['objectKey'] as String,
    );
  }
}

enum PozingThumbnailStatus {
  pending,
  completed,
  failed;

  static PozingThumbnailStatus fromJson(String? raw) {
    switch (raw) {
      case 'PENDING':
        return PozingThumbnailStatus.pending;
      case 'COMPLETED':
        return PozingThumbnailStatus.completed;
      default:
        return PozingThumbnailStatus.failed;
    }
  }
}

class PozingSaveResponse {
  final int pozingId;
  final int? courseSpotId;
  final String pozingObjectKey;
  final String pozingUrl;
  final String thumbnailUrl;
  final PozingThumbnailStatus thumbnailStatus;

  const PozingSaveResponse({
    required this.pozingId,
    this.courseSpotId,
    required this.pozingObjectKey,
    required this.pozingUrl,
    required this.thumbnailUrl,
    this.thumbnailStatus = PozingThumbnailStatus.completed,
  });

  factory PozingSaveResponse.fromJson(Map<String, dynamic> json) {
    return PozingSaveResponse(
      pozingId: json['pozingId'] as int,
      courseSpotId: json['courseSpotId'] as int?,
      pozingObjectKey: json['pozingObjectKey'] as String? ?? '',
      pozingUrl: json['pozingUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      thumbnailStatus: PozingThumbnailStatus.fromJson(
        json['thumbnailStatus'] as String?,
      ),
    );
  }
}

class PozingThumbnailStatusResponse {
  final int pozingId;
  final PozingThumbnailStatus thumbnailStatus;
  final String thumbnailUrl;

  const PozingThumbnailStatusResponse({
    required this.pozingId,
    required this.thumbnailStatus,
    required this.thumbnailUrl,
  });

  factory PozingThumbnailStatusResponse.fromJson(Map<String, dynamic> json) {
    return PozingThumbnailStatusResponse(
      pozingId: json['pozingId'] as int,
      thumbnailStatus: PozingThumbnailStatus.fromJson(
        json['thumbnailStatus'] as String?,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }
}
