import '../../../core/network/api_exception.dart';
import '../../datasources/travel_invite/travel_invite_datasource.dart';
import '../../models/travel_invite/travel_invite_search_model.dart';
import '../../models/travel_invite/travel_join_model.dart';

class TravelInviteRepository {
  const TravelInviteRepository({TravelInviteDatasource? datasource})
    : _datasource = datasource ?? const TravelInviteDatasource();

  final TravelInviteDatasource _datasource;

  Future<TravelInviteSearchModel> findTravel(String inviteCode) async {
    try {
      return TravelInviteSearchModel.fromJson(
        await _datasource.findTravel(inviteCode),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('초대 코드 조회 응답을 처리하지 못했습니다.');
    }
  }

  Future<TravelJoinModel> joinTravel(int travelId) async {
    try {
      return TravelJoinModel.fromJson(await _datasource.joinTravel(travelId));
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('여행 참여 응답을 처리하지 못했습니다.');
    }
  }
}
