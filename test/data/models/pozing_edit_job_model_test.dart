import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/pozing_edit_job_model.dart';

void main() {
  group('PozingEditJobCreateResponse.fromJson', () {
    test('jobId와 status를 파싱한다', () {
      final response = PozingEditJobCreateResponse.fromJson({
        'jobId': 1,
        'status': 'QUEUED',
      });

      expect(response.jobId, 1);
      expect(response.status, PozingEditJobStatus.queued);
    });
  });

  group('PozingEditJobStatusResponse.fromJson', () {
    test('완료 상태면 downloadUrl과 expiresAt이 채워진다', () {
      final response = PozingEditJobStatusResponse.fromJson({
        'jobId': 1,
        'status': 'COMPLETED',
        'downloadUrl': 'https://example.com/edited.mp4',
        'expiresAt': '2026-08-07T00:00:00Z',
      });

      expect(response.status, PozingEditJobStatus.completed);
      expect(response.downloadUrl, 'https://example.com/edited.mp4');
      expect(response.errorMessage, isNull);
      expect(response.expiresAt, DateTime.parse('2026-08-07T00:00:00Z'));
    });

    test('실패 상태면 errorMessage가 채워진다', () {
      final response = PozingEditJobStatusResponse.fromJson({
        'jobId': 1,
        'status': 'FAILED',
        'errorMessage': '편집에 실패했습니다.',
      });

      expect(response.status, PozingEditJobStatus.failed);
      expect(response.errorMessage, '편집에 실패했습니다.');
      expect(response.downloadUrl, isNull);
    });

    test('알 수 없는 status는 failed로 처리된다', () {
      final response = PozingEditJobStatusResponse.fromJson({
        'jobId': 1,
        'status': 'SOME_UNKNOWN_VALUE',
      });

      expect(response.status, PozingEditJobStatus.failed);
    });
  });

  group('isPozingEditJobInProgress', () {
    test('QUEUED와 PROCESSING만 진행중으로 판단한다', () {
      expect(isPozingEditJobInProgress(PozingEditJobStatus.queued), isTrue);
      expect(
        isPozingEditJobInProgress(PozingEditJobStatus.processing),
        isTrue,
      );
      expect(
        isPozingEditJobInProgress(PozingEditJobStatus.completed),
        isFalse,
      );
      expect(isPozingEditJobInProgress(PozingEditJobStatus.failed), isFalse);
    });
  });
}
