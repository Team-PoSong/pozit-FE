import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/travel/active_course_spot_model.dart';
import '../../models/travel/presigned_url_response.dart';
import '../../models/travel/like_based_travel_model.dart';
import '../../models/travel/travel_course_model.dart';
import '../../models/travel/travel_create_model.dart';
import '../../models/travel/travel_detail_model.dart';
import '../../models/travel/travel_list_model.dart';
import '../../models/travel/travel_region_model.dart';
import '../../models/travel/travel_recommendation_model.dart';
import '../../models/travel/travel_tag_model.dart';
import '../../models/travel/travel_update_request.dart';

const Duration _kImageTransferTimeout = Duration(seconds: 30);

class TravelRepository {
  const TravelRepository();

  static Future<List<TravelTagModel>>? _tagRequest;

  Future<TravelRegionPage> searchRegions({
    required String keyword,
    int cursor = 1,
    int size = 10,
  }) async {
    try {
      final result = await DioClient.instance.get(
        '/api/regions/search',
        queryParameters: {'keyword': keyword, 'cursor': cursor, 'size': size},
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('지역 검색 응답 형식이 올바르지 않습니다.');
      }
      return TravelRegionPage.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 지역을 검색하지 못했습니다.');
    }
  }

  Future<TravelCreateResult> createTravel(TravelCreateRequest request) async {
    try {
      final result = await DioClient.instance.post(
        '/api/travels',
        data: request.toJson(),
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('여행 생성 응답 형식이 올바르지 않습니다.');
      }
      return TravelCreateResult.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행을 생성하지 못했습니다.');
    }
  }

  Future<List<TravelListModel>> getTravels({required bool isDone}) async {
    try {
      final result = await DioClient.instance.get(
        '/api/travels',
        queryParameters: {'isDone': isDone},
      );
      if (result is! List<dynamic>) {
        throw const ApiException('여행 목록 응답 형식이 올바르지 않습니다.');
      }
      return result
          .map((item) => TravelListModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 목록을 불러오지 못했습니다.');
    }
  }

  Future<TravelRecommendationCardModel> previewRecommendationCard(
    int travelId,
  ) async {
    try {
      final result = await DioClient.instance.post(
        '/api/travels/$travelId/recommendations/preview/card',
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('추천 카드 응답 형식이 올바르지 않습니다.');
      }
      return TravelRecommendationCardModel.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('추천 카드를 불러오지 못했습니다.');
    }
  }

  Future<TravelRecommendationModel> getRecommendationPreview(
    int travelId,
    String previewId,
  ) async {
    try {
      final result = await DioClient.instance.get(
        '/api/travels/$travelId/recommendations/previews/$previewId',
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('추천 코스 응답 형식이 올바르지 않습니다.');
      }
      final recommendation = TravelRecommendationModel.fromJson(result);
      if (!recommendation.days.any((day) => day.validCommitPlaces.isNotEmpty)) {
        throw const ApiException('추천 가능한 장소를 찾지 못했어요. 다시 추천해주세요.');
      }
      return recommendation;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('추천 코스를 불러오지 못했습니다.');
    }
  }

  Future<void> commitRecommendations(
    int travelId,
    TravelRecommendationModel recommendation,
  ) async {
    try {
      final request = recommendation.toCommitJson();
      final days = request['days'] as List<dynamic>;
      if (days.isEmpty) {
        throw const ApiException('저장할 수 있는 추천 장소가 없습니다. 추천을 다시 받아주세요.');
      }
      await DioClient.instance.post(
        '/api/travels/$travelId/recommendations/commit',
        data: request,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('추천 코스를 저장하지 못했습니다.');
    }
  }

  Future<LikeBasedTravelDraftModel> getLikeBasedTravelDraft(
    int sourceTravelId,
  ) async {
    try {
      final result = await DioClient.instance.get(
        '/api/like-based/travels/$sourceTravelId/draft',
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('찜 기반 여행 초안 응답 형식이 올바르지 않습니다.');
      }
      return LikeBasedTravelDraftModel.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('찜 기반 여행 초안을 불러오지 못했습니다.');
    }
  }

  Future<TravelCreateResult> createLikeBasedTravel(
    LikeBasedTravelCreateRequest request,
  ) async {
    try {
      final result = await DioClient.instance.post(
        '/api/like-based/travels',
        data: request.toJson(),
      );
      if (result is! Map<String, dynamic>) {
        throw const ApiException('찜 기반 여행 생성 응답 형식이 올바르지 않습니다.');
      }
      return TravelCreateResult.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('찜 기반 여행을 생성하지 못했습니다.');
    }
  }

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

  Future<void> _putFileToPresignedUrl(String presignedUrl, File file) async {
    final bytes = await file.readAsBytes();
    await createTransferDio(sendTimeout: _kImageTransferTimeout).put(
      presignedUrl,
      data: bytes,
      options: Options(headers: {'Content-Type': _contentTypeFor(file.path)}),
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

  Future<List<ActiveCourseSpotModel>> getActiveCourseSpots() async {
    try {
      final result = await DioClient.instance.get('/api/travels/active-spots');

      if (result is! Map<String, dynamic> || result['spots'] is! List) {
        throw const ApiException('방문 중인 스팟 응답 형식이 올바르지 않습니다.');
      }

      return (result['spots'] as List<dynamic>)
          .map((e) => ActiveCourseSpotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('방문 중인 여행 정보를 불러오지 못했습니다.');
    }
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

  Future<void> updateCourseSpots(int courseId, List<int> touristSpotIds) async {
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
    final cached = _tagRequest;
    if (cached != null) return cached;

    final request = _loadTags();
    _tagRequest = request;
    try {
      return await request;
    } catch (_) {
      if (identical(_tagRequest, request)) _tagRequest = null;
      rethrow;
    }
  }

  Future<List<TravelTagModel>> _loadTags() async {
    try {
      final result = await DioClient.instance.get('/api/tags');
      return List.unmodifiable(_parseTagList(result));
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
