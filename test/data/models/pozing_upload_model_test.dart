import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/pozing_upload_model.dart';

void main() {
  group('PozingPresignedUrlResponse.fromJson', () {
    test('presignedUrl과 uploadId를 그대로 파싱한다', () {
      final response = PozingPresignedUrlResponse.fromJson({
        'presignedUrl': 'https://example.com/upload',
        'uploadId': 'upload-123',
      });

      expect(response.presignedUrl, 'https://example.com/upload');
      expect(response.uploadId, 'upload-123');
    });

    test('objectKey는 presignedUrl 경로에서 쿼리스트링을 제외하고 추출한다', () {
      final response = PozingPresignedUrlResponse.fromJson({
        'presignedUrl':
            'https://pozit-pozing.s3.ap-northeast-2.amazonaws.com/pozings/2/1/a2053747-c1ab-4aeb-a7ff-8871a8c1fdc5.mp4'
            '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=abc',
        'uploadId': '359cc8f4-2780-4ffe-9e01-fd9924fde90c',
      });

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
      });

      expect(response.pozingId, 1);
      expect(response.courseSpotId, 2);
      expect(response.pozingObjectKey, 'pozings/1/2/uuid.mp4');
      expect(response.pozingUrl, 'https://example.com/pozing.mp4');
      expect(response.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('courseSpotId가 없으면 null이다', () {
      final response = PozingSaveResponse.fromJson({
        'pozingId': 1,
        'pozingObjectKey': 'pozings/1/2/uuid.mp4',
        'pozingUrl': 'https://example.com/pozing.mp4',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
      });

      expect(response.courseSpotId, isNull);
    });
  });
}
