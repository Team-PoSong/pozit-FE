import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/travel/travel_detail_model.dart';

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
}
