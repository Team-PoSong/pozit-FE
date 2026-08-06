import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/tourist_spot_rank_model.dart';

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
}
