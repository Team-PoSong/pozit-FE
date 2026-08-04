import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
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

  Future<List<TravelTagModel>> getTags() async {
    try {
      final result = await DioClient.instance.get('/api/tags');

      if (result is! List) {
        throw const ApiException('태그 목록 응답 형식이 올바르지 않습니다.');
      }

      return result
          .map((e) => TravelTagModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('태그 목록을 불러오지 못했습니다.');
    }
  }
}
