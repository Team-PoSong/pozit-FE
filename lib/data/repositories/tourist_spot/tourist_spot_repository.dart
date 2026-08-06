import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/tourist_spot_model.dart';
import '../../models/tourist_spot_rank_model.dart';
import '../../models/tourist_spot_search_result_model.dart';

class TouristSpotRepository {
  const TouristSpotRepository();

  Future<TouristSpotRankPage> getHostTouristSpotsRank({
    String? regionCode,
    int cursor = 1,
  }) async {
    try {
      final result = await DioClient.instance.get(
        '/api/course-spots/ranks',
        queryParameters: {
          if (regionCode != null) 'regionCode': regionCode,
          'cursor': cursor,
        },
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('인기 관광지 랭킹 응답 형식이 올바르지 않습니다.');
      }

      return TouristSpotRankPage.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('인기 관광지 랭킹을 불러오지 못했습니다.');
    }
  }

  Future<TouristSpotSearchPage> searchCourseSpots({
    required String keyword,
    int cursor = 1,
    int size = 10,
  }) async {
    try {
      final result = await DioClient.instance.get(
        '/api/course-spots/search',
        queryParameters: {'keyword': keyword, 'cursor': cursor, 'size': size},
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('관광지 검색 응답 형식이 올바르지 않습니다.');
      }

      return TouristSpotSearchPage.fromJson(result);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('관광지를 검색하지 못했습니다.');
    }
  }

  /// 검색 결과에서 선택한 장소를 Pozit TouristSpot으로 저장합니다.
  /// 저장 응답에는 좌표가 없으므로, 직전 검색 결과([selected])에 담겨 있던
  /// 좌표를 contentId로 매칭해 그대로 합쳐 돌려줍니다.
  Future<List<TouristSpotModel>> saveSelectedSpots(
    List<TouristSpotSearchResultModel> selected,
  ) async {
    if (selected.isEmpty) return const [];

    try {
      final result = await DioClient.instance.post(
        '/api/course-spots',
        data: {'contentIds': selected.map((s) => s.contentId).toList()},
      );

      if (result is! Map<String, dynamic>) {
        throw const ApiException('관광지 저장 응답 형식이 올바르지 않습니다.');
      }

      final selectedByContentId = {
        for (final spot in selected) spot.contentId: spot,
      };
      final savedSpots = result['spots'] as List<dynamic>? ?? const [];

      return savedSpots.map((e) {
        final json = e as Map<String, dynamic>;
        final matched = selectedByContentId[json['contentId'] as String];
        return TouristSpotModel(
          touristSpotId: json['touristSpotId'] as int,
          name: json['title'] as String,
          address: json['address'] as String? ?? '',
          latitude: matched?.latitude ?? 0,
          longitude: matched?.longitude ?? 0,
        );
      }).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('선택한 관광지를 저장하지 못했습니다.');
    }
  }
}
