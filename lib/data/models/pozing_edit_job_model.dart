import 'package:flutter/foundation.dart';

enum PozingEditJobStatus {
  queued,
  processing,
  completed,
  failed,
  expired,
  deleted,
  deleteFailed,
}

bool isPozingEditJobInProgress(PozingEditJobStatus status) =>
    status == PozingEditJobStatus.queued ||
    status == PozingEditJobStatus.processing;

PozingEditJobStatus _parsePozingEditJobStatus(String? raw) {
  switch (raw) {
    case 'QUEUED':
      return PozingEditJobStatus.queued;
    case 'PROCESSING':
      return PozingEditJobStatus.processing;
    case 'COMPLETED':
      return PozingEditJobStatus.completed;
    case 'FAILED':
      return PozingEditJobStatus.failed;
    case 'EXPIRED':
      return PozingEditJobStatus.expired;
    case 'DELETED':
      return PozingEditJobStatus.deleted;
    case 'DELETE_FAILED':
      return PozingEditJobStatus.deleteFailed;
    default:
      debugPrint('알 수 없는 포징 편집 작업 status: $raw');
      return PozingEditJobStatus.failed;
  }
}

class PozingEditJobCreateResponse {
  final int jobId;
  final PozingEditJobStatus status;

  const PozingEditJobCreateResponse({required this.jobId, required this.status});

  factory PozingEditJobCreateResponse.fromJson(Map<String, dynamic> json) {
    return PozingEditJobCreateResponse(
      jobId: json['jobId'] as int,
      status: _parsePozingEditJobStatus(json['status'] as String?),
    );
  }
}

class PozingEditJobStatusResponse {
  final int jobId;
  final PozingEditJobStatus status;
  final String? downloadUrl;
  final String? errorMessage;
  final DateTime? expiresAt;

  const PozingEditJobStatusResponse({
    required this.jobId,
    required this.status,
    this.downloadUrl,
    this.errorMessage,
    this.expiresAt,
  });

  factory PozingEditJobStatusResponse.fromJson(Map<String, dynamic> json) {
    final expiresAtRaw = json['expiresAt'] as String?;
    return PozingEditJobStatusResponse(
      jobId: json['jobId'] as int,
      status: _parsePozingEditJobStatus(json['status'] as String?),
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      expiresAt: expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null,
    );
  }
}
