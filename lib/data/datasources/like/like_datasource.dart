import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/like/liked_travel_model.dart';

class LikeDatasource {
  const LikeDatasource();

  Future<List<LikedTravelModel>> getLikes() async {
    final result = await DioClient.instance.get('/api/likes');
    if (result is! List<dynamic>) {
      throw const ApiException('찜 목록 응답 형식이 올바르지 않습니다.');
    }

    return result.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const ApiException('찜 목록 응답 형식이 올바르지 않습니다.');
      }
      return LikedTravelModel.fromJson(item);
    }).toList();
  }

  Future<void> likeTravel(int travelId) {
    return DioClient.instance.post('/api/likes/$travelId');
  }

  Future<void> unlikeTravel(int travelId) {
    return DioClient.instance.delete('/api/likes/$travelId');
  }
}
