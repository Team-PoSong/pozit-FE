import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class OnboardingRepository {
  const OnboardingRepository();

  static const List<String> requiredTermTypes = [
    'SERVICE',
    'PRIVACY',
    'LOCATION',
    'AGE_OVER_14',
  ];

  Future<void> updateNickname(String nickname) async {
    try {
      await DioClient.instance.patch(
        '/api/users/nickname',
        data: {'nickname': nickname},
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('닉네임을 설정하지 못했습니다.');
    }
  }

  Future<void> saveRequiredTermAgreements() async {
    try {
      await DioClient.instance.post(
        '/api/terms/agreements',
        data: {
          'agreements': [
            for (final termType in requiredTermTypes)
              {'termType': termType, 'agreed': true},
          ],
        },
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('약관 동의를 저장하지 못했습니다.');
    }
  }
}
