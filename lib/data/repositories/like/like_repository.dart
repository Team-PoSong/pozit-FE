import '../../../core/network/api_exception.dart';
import '../../datasources/like/like_datasource.dart';
import '../../models/like/liked_travel_model.dart';

class LikeRepository {
  const LikeRepository({this.datasource = const LikeDatasource()});

  final LikeDatasource datasource;

  Future<List<LikedTravelModel>> getLikes() async {
    try {
      return await datasource.getLikes();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('찜 목록 응답을 처리하지 못했습니다.');
    }
  }

  Future<void> likeTravel(int travelId) => datasource.likeTravel(travelId);

  Future<void> unlikeTravel(int travelId) => datasource.unlikeTravel(travelId);
}
