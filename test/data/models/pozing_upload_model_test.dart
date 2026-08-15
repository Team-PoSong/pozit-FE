import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/pozing_upload_model.dart';

void main() {
  group('PozingPresignedUrlResponse.fromJson', () {
    test('presignedUrl과 objectKey를 그대로 파싱한다', () {
      final response = PozingPresignedUrlResponse.fromJson({
        'presignedUrl': 'https://example.com/upload',
        'objectKey': 'pozings/2/1/a2053747-c1ab-4aeb-a7ff-8871a8c1fdc5.mp4',
      });

      expect(response.presignedUrl, 'https://example.com/upload');
      expect(
        response.objectKey,
        'pozings/2/1/a2053747-c1ab-4aeb-a7ff-8871a8c1fdc5.mp4',
      );
    });
  });

  group('PozingSaveResponse.fromJson', () {
    test('필드를 그대로 파싱한다', () {
      final response = PozingSaveResponse.fromJson({
        'pozingId': 1,
        'courseSpotId': 2,
        'pozingObjectKey': 'pozings/1/2/uuid.mp4',
        'pozingUrl': 'https://example.com/pozing.mp4',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'thumbnailStatus': 'COMPLETED',
      });

      expect(response.pozingId, 1);
      expect(response.courseSpotId, 2);
      expect(response.pozingObjectKey, 'pozings/1/2/uuid.mp4');
      expect(response.pozingUrl, 'https://example.com/pozing.mp4');
      expect(response.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(response.thumbnailStatus, PozingThumbnailStatus.completed);
    });

    test('courseSpotId가 없으면 null이다', () {
      final response = PozingSaveResponse.fromJson({
        'pozingId': 1,
        'pozingObjectKey': 'pozings/1/2/uuid.mp4',
        'pozingUrl': 'https://example.com/pozing.mp4',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'thumbnailStatus': 'COMPLETED',
      });

      expect(response.courseSpotId, isNull);
    });

    test('thumbnailStatus가 PENDING이면 그대로 파싱한다', () {
      final response = PozingSaveResponse.fromJson({
        'pozingId': 1,
        'pozingObjectKey': 'pozings/1/2/uuid.mp4',
        'pozingUrl': 'https://example.com/pozing.mp4',
        'thumbnailUrl': '',
        'thumbnailStatus': 'PENDING',
      });

      expect(response.thumbnailStatus, PozingThumbnailStatus.pending);
      expect(response.thumbnailUrl, '');
    });

    test('thumbnailStatus가 없거나 알 수 없는 값이면 failed로 처리한다', () {
      final response = PozingSaveResponse.fromJson({
        'pozingId': 1,
        'pozingObjectKey': 'pozings/1/2/uuid.mp4',
        'pozingUrl': 'https://example.com/pozing.mp4',
        'thumbnailUrl': '',
      });

      expect(response.thumbnailStatus, PozingThumbnailStatus.failed);
    });
  });

  group('PozingThumbnailStatusResponse.fromJson', () {
    test('COMPLETED면 thumbnailUrl을 그대로 파싱한다', () {
      final response = PozingThumbnailStatusResponse.fromJson({
        'pozingId': 1,
        'thumbnailStatus': 'COMPLETED',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
      });

      expect(response.pozingId, 1);
      expect(response.thumbnailStatus, PozingThumbnailStatus.completed);
      expect(response.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('PENDING이면 thumbnailUrl이 없어도 빈 문자열로 처리한다', () {
      final response = PozingThumbnailStatusResponse.fromJson({
        'pozingId': 1,
        'thumbnailStatus': 'PENDING',
      });

      expect(response.thumbnailStatus, PozingThumbnailStatus.pending);
      expect(response.thumbnailUrl, '');
    });
  });
}
