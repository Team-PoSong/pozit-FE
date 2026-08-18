import '../../../core/network/api_exception.dart';
import '../../datasources/travel/public_travel_datasource.dart';
import '../../models/travel/public_travel_detail_model.dart';

class PublicTravelRepository {
  const PublicTravelRepository({
    this.datasource = const PublicTravelDatasource(),
  });

  final PublicTravelDatasource datasource;

  Future<PublicTravelDetailModel> getTravelDetail(int travelId) async {
    try {
      return await datasource.getTravelDetail(travelId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('공개 여행 상세 응답을 처리하지 못했습니다.');
    }
  }
}
