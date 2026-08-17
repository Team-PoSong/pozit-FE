import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class TravelInviteDatasource {
  const TravelInviteDatasource();

  Future<Map<String, dynamic>> findTravel(String inviteCode) async {
    final result = await DioClient.instance.post(
      '/api/travels/invite/find',
      data: {'inviteCode': inviteCode},
    );
    return _requireJsonObject(result, '초대 코드 조회');
  }

  Future<Map<String, dynamic>> joinTravel(int travelId) async {
    final result = await DioClient.instance.post(
      '/api/travels/invite/join',
      queryParameters: {'travelId': travelId},
    );
    return _requireJsonObject(result, '여행 참여');
  }

  Map<String, dynamic> _requireJsonObject(dynamic result, String requestName) {
    if (result is Map<String, dynamic>) return result;
    throw ApiException('$requestName 응답 형식이 올바르지 않습니다.');
  }
}
