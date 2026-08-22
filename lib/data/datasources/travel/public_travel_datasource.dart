import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/travel/public_travel_detail_model.dart';
import '../../models/like/liked_travel_model.dart';

class PublicTravelDatasource {
  const PublicTravelDatasource();

  Future<List<LikedTravelModel>> getTravels() async {
    final result = await DioClient.instance.get('/api/public/travels');
    if (result is! List) {
      throw const ApiException('공개 여행 목록 응답 형식이 올바르지 않습니다.');
    }
    return result
        .map((item) => LikedTravelModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PublicTravelDetailModel> getTravelDetail(int travelId) async {
    final result = await DioClient.instance.get(
      '/api/public/travels/$travelId',
    );
    if (result is! Map<String, dynamic>) {
      throw const ApiException('공개 여행 상세 응답 형식이 올바르지 않습니다.');
    }
    return PublicTravelDetailModel.fromJson(result);
  }
}
