import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/pozing_edit_job_model.dart';
import '../../models/pozing_upload_model.dart';

class PozingRepository {
  const PozingRepository();

  /// 여행의 포징 영상들을 하나의 타임랩스로 편집하는 작업을 요청합니다.
  Future<PozingEditJobCreateResponse> requestEditPozing(int travelId) async {
    try {
      final result = await DioClient.instance.post(
        '/api/pozing/local-save',
        queryParameters: {'travelId': travelId},
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('여행 로그 생성 응답 형식이 올바르지 않습니다.');
      }

      return PozingEditJobCreateResponse.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 로그 생성을 요청하지 못했습니다.');
    }
  }

  /// 편집 작업 상태를 조회합니다. 완료되면 다운로드 URL이 함께 내려옵니다.
  Future<PozingEditJobStatusResponse> getEditPozingJob(int jobId) async {
    try {
      final result = await DioClient.instance.get('/api/pozing/edit-jobs/$jobId');

      if (result is! Map<String, dynamic>) {
        throw const ApiException('여행 로그 상태 응답 형식이 올바르지 않습니다.');
      }

      return PozingEditJobStatusResponse.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 로그 상태를 확인하지 못했습니다.');
    }
  }

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
