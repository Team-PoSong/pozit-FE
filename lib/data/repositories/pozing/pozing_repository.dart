import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/pozing_edit_job_model.dart';
import '../../models/pozing_upload_model.dart';

const Duration _kVideoTransferTimeout = Duration(minutes: 3);

class PozingRepository {
  const PozingRepository();

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

  Future<PozingThumbnailStatusResponse> getThumbnailStatus(int pozingId) async {
    try {
      final result = await DioClient.instance.get(
        '/api/pozing/$pozingId/thumbnail',
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('썸네일 상태 응답 형식이 올바르지 않습니다.');
      }

      return PozingThumbnailStatusResponse.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('썸네일 상태를 확인하지 못했습니다.');
    }
  }

  Future<File> downloadEditedVideo(String downloadUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/pozit_travel_log_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await createTransferDio(
        receiveTimeout: _kVideoTransferTimeout,
      ).download(downloadUrl, filePath);
      return File(filePath);
    } catch (_) {
      throw const ApiException('여행 로그 영상을 내려받지 못했습니다.');
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

  Future<void> _putVideoToPresignedUrl(
    String presignedUrl,
    File videoFile,
  ) async {
    final bytes = await videoFile.readAsBytes();
    await createTransferDio(sendTimeout: _kVideoTransferTimeout).put(
      presignedUrl,
      data: bytes,
      options: Options(
        headers: {'Content-Type': _contentTypeFor(videoFile.path)},
      ),
    );
  }

  String _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mov')) return 'video/quicktime';
    return 'video/mp4';
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
