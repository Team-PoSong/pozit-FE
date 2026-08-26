import '../../../core/network/api_exception.dart';
import '../../datasources/travel/public_travel_datasource.dart';
import '../../models/travel/public_travel_detail_model.dart';
import '../../models/travel/travel_course_model.dart';
import '../../models/like/liked_travel_model.dart';

class PublicTravelRepository {
  const PublicTravelRepository({
    this.datasource = const PublicTravelDatasource(),
  });

  final PublicTravelDatasource datasource;

  Future<List<LikedTravelModel>> getTravels() async {
    try {
      return await datasource.getTravels();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('공개 여행 목록 응답을 처리하지 못했습니다.');
    }
  }

  Future<List<LikedTravelModel>> getPopularTravelCards() async {
    try {
      return await datasource.getPopularTravelCards();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('인기 여행 카드 응답을 처리하지 못했습니다.');
    }
  }

  Future<PublicTravelDetailModel> getTravelDetail(int travelId) async {
    try {
      return await datasource.getTravelDetail(travelId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('공개 여행 상세 응답을 처리하지 못했습니다.');
    }
  }

  Future<TravelCourseModel> getCourseDetail(int courseId) async {
    try {
      return await datasource.getCourseDetail(courseId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('공개 코스 상세 응답을 처리하지 못했습니다.');
    }
  }
}
