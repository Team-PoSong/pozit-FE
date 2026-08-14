import '../../../core/network/api_exception.dart';
import '../../datasources/user/user_datasource.dart';
import '../../models/user/notification_settings_model.dart';
import '../../models/user/user_profile_model.dart';

class UserRepository {
  const UserRepository({UserDatasource? datasource})
    : _datasource = datasource ?? const UserDatasource();

  final UserDatasource _datasource;

  Future<UserProfileModel> getMe() async {
    try {
      return await _datasource.getMe();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('내 정보 응답을 처리하지 못했습니다.');
    }
  }

  Future<void> updateNickname(String nickname) {
    return _datasource.updateNickname(nickname);
  }

  Future<void> updateNotificationSettings(NotificationSettingsModel settings) {
    return _datasource.updateNotificationSettings(settings);
  }

  Future<void> withdraw({
    String? appleAuthorizationCode,
    String? applePlatform,
  }) {
    return _datasource.withdraw(
      appleAuthorizationCode: appleAuthorizationCode,
      applePlatform: applePlatform,
    );
  }
}
