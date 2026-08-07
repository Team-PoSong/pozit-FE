import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/travel/presigned_url_response.dart';
import '../../models/travel/travel_course_model.dart';
import '../../models/travel/travel_detail_model.dart';
import '../../models/travel/travel_tag_model.dart';
import '../../models/travel/travel_update_request.dart';

class TravelRepository {
  const TravelRepository();

  Future<TravelDetailModel> getTravelDetail(int travelId) async {
    try {
      final result = await DioClient.instance.get('/api/travels/$travelId');

      if (result is! Map<String, dynamic>) {
        throw const ApiException('여행 상세 응답 형식이 올바르지 않습니다.');
      }

      return TravelDetailModel.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 상세 정보를 처리하지 못했습니다.');
    }
  }

  Future<void> updateTravel(int travelId, TravelUpdateRequest request) async {
    try {
      await DioClient.instance.patch(
        '/api/travels/$travelId',
        data: request.toJson(),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 정보를 수정하지 못했습니다.');
    }
  }

  Future<void> updateVisibility(int travelId, bool isPublic) async {
    try {
      await DioClient.instance.patch(
        '/api/travels/$travelId/visibility',
        data: {'isPublic': isPublic},
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('공개 설정을 변경하지 못했습니다.');
    }
  }

  Future<void> leaveTravel(int travelId) async {
    try {
      await DioClient.instance.delete('/api/travels/$travelId/leave');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행에서 나가지 못했습니다.');
    }
  }

  Future<void> deleteTravel(int travelId) async {
    try {
      await DioClient.instance.delete('/api/travels/$travelId');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행을 삭제하지 못했습니다.');
    }
  }

  Future<void> removeMember(int travelId, int userId) async {
    try {
      await DioClient.instance.delete('/api/travels/$travelId/members/$userId');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('멤버를 내보내지 못했습니다.');
    }
  }

  Future<String> getInviteCode(int travelId) async {
    try {
      final result = await DioClient.instance.get(
        '/api/travels/invite',
        queryParameters: {'travelId': travelId},
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('초대 코드 응답 형식이 올바르지 않습니다.');
      }

      return result['inviteCode'] as String? ?? '';
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('초대 코드를 불러오지 못했습니다.');
    }
  }

  /// 배경 사진을 presigned URL로 S3에 직접 업로드한 뒤, 완료된 objectKey를
  /// 서버에 저장합니다.
  Future<void> uploadBackgroundImage(int travelId, File file) async {
    try {
      final presigned = await _getBackgroundImageUploadUrl(travelId);
      await _putFileToPresignedUrl(presigned.presignedUrl, file);
      await _saveBackgroundImage(travelId, presigned.objectKey);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('배경 사진을 업로드하지 못했습니다.');
    }
  }

  Future<PresignedUrlResponse> _getBackgroundImageUploadUrl(
    int travelId,
  ) async {
    final result = await DioClient.instance.post(
      '/api/travels/presigned-url/$travelId/background-image',
    );

    if (result is! Map<String, dynamic>) {
      throw const ApiException('업로드 URL 응답 형식이 올바르지 않습니다.');
    }

    return PresignedUrlResponse.fromJson(result);
  }

  // S3 presigned URL은 백엔드 인증 토큰과 무관하므로, 인터셉터가 붙은
  // DioClient가 아니라 별도의 순수 Dio 인스턴스로 직접 업로드합니다.
  Future<void> _putFileToPresignedUrl(String presignedUrl, File file) async {
    final bytes = await file.readAsBytes();
    await Dio().put(
      presignedUrl,
      data: bytes,
      options: Options(
        headers: {'Content-Type': _contentTypeFor(file.path)},
      ),
    );
  }

  Future<void> _saveBackgroundImage(int travelId, String objectKey) async {
    await DioClient.instance.patch(
      '/api/travels/save/background-image',
      data: {'travelId': travelId, 'backGroundImgUrl': objectKey},
    );
  }

  String _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'application/octet-stream';
  }

  Future<TravelCourseModel> getCourseDetail(int courseId) async {
    try {
      final result = await DioClient.instance.get('/api/courses/$courseId');

      if (result is! Map<String, dynamic>) {
        throw const ApiException('코스 상세 응답 형식이 올바르지 않습니다.');
      }

      return TravelCourseModel.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('코스 상세 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> updateCourseSpots(
    int courseId,
    List<int> touristSpotIds,
  ) async {
    try {
      await DioClient.instance.patch(
        '/api/courses/$courseId/spots',
        data: {'touristSpotIds': touristSpotIds},
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('코스를 수정하지 못했습니다.');
    }
  }

  Future<List<TravelTagModel>> getTags() async {
    try {
      final result = await DioClient.instance.get('/api/tags');
      return _parseTagList(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('태그 목록을 불러오지 못했습니다.');
    }
  }

  Future<List<TravelTagModel>> getTravelTags(int travelId) async {
    try {
      final result = await DioClient.instance.get(
        '/api/travels/$travelId/tags',
      );
      return _parseTagList(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 태그 목록을 불러오지 못했습니다.');
    }
  }

  List<TravelTagModel> _parseTagList(dynamic result) {
    if (result is! List) {
      throw const ApiException('태그 목록 응답 형식이 올바르지 않습니다.');
    }
    return result
        .map((e) => TravelTagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
