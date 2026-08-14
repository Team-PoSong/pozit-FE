import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user/notification_settings_model.dart';
import '../../models/user/user_profile_model.dart';

class UserDatasource {
  const UserDatasource();

  Future<UserProfileModel> getMe() async {
    final result = await DioClient.instance.get('/api/users/me');
    if (result is! Map<String, dynamic>) {
      throw const ApiException('내 정보 응답 형식이 올바르지 않습니다.');
    }
    return UserProfileModel.fromJson(result);
  }

  Future<void> updateNickname(String nickname) {
    return DioClient.instance.patch(
      '/api/users/me',
      data: {'nickname': nickname},
    );
  }

  Future<void> updateNotificationSettings(NotificationSettingsModel settings) {
    return DioClient.instance.patch(
      '/api/users/me/notification-settings',
      data: settings.toJson(),
    );
  }

  Future<void> withdraw({
    String? appleAuthorizationCode,
    String? applePlatform,
  }) {
    assert(
      (appleAuthorizationCode == null) == (applePlatform == null),
      'Apple 탈퇴 인증 코드와 플랫폼은 함께 전달해야 합니다.',
    );
    final isAppleWithdrawal =
        appleAuthorizationCode != null && applePlatform != null;
    return DioClient.instance.delete(
      '/api/users/me',
      data: isAppleWithdrawal
          ? {
              'appleAuthorizationCode': appleAuthorizationCode,
              'applePlatform': applePlatform,
            }
          : null,
    );
  }
}
