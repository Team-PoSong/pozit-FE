import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/pozing_upload_model.dart';

class PozingRepository {
  const PozingRepository();

  /// 코스 장소에서 촬영한 타임랩스 영상을 presigned URL로 S3에 직접
  /// 업로드한 뒤, 업로드 완료를 서버에 알려 Pozing으로 저장합니다.
  Future<PozingSaveResponse> uploadPozingVideo({
    required int courseSpotId,
    required File videoFile,
  }) async {
    try {
      final presigned = await _getPresignedUrl(courseSpotId);
      await _putVideoToPresignedUrl(presigned.presignedUrl, videoFile);
      return await _savePozing(
        courseSpotId: courseSpotId,
        objectKey: presigned.objectKey,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('포징 영상을 업로드하지 못했습니다.');
    }
  }

  Future<PozingPresignedUrlResponse> _getPresignedUrl(int courseSpotId) async {
    final result = await DioClient.instance.post(
      '/api/pozing/presigned-url',
      queryParameters: {'courseSpotId': courseSpotId},
    );

    if (result is! Map<String, dynamic>) {
      throw const ApiException('업로드 URL 응답 형식이 올바르지 않습니다.');
    }

    return PozingPresignedUrlResponse.fromJson(result);
  }

  // S3 presigned URL은 백엔드 인증 토큰과 무관하므로, 인터셉터가 붙은
  // DioClient가 아니라 별도의 순수 Dio 인스턴스로 직접 업로드합니다.
  Future<void> _putVideoToPresignedUrl(
    String presignedUrl,
    File videoFile,
  ) async {
    final bytes = await videoFile.readAsBytes();
    await Dio().put(
      presignedUrl,
      data: bytes,
      options: Options(headers: {'Content-Type': 'video/mp4'}),
    );
  }

  Future<PozingSaveResponse> _savePozing({
    required int courseSpotId,
    required String objectKey,
  }) async {
    final result = await DioClient.instance.post(
      '/api/pozing/save',
      data: {'objectKey': objectKey, 'courseSpotId': courseSpotId},
    );

    if (result is! Map<String, dynamic>) {
      throw const ApiException('포징 저장 응답 형식이 올바르지 않습니다.');
    }

    return PozingSaveResponse.fromJson(result);
  }
}
