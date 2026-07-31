import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class NotificationDatasource {
  const NotificationDatasource();

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final result = await DioClient.instance.get('/api/notifications');

    if (result is! List) {
      throw const ApiException('알림 목록 응답 형식이 올바르지 않습니다.');
    }

    final notifications = <Map<String, dynamic>>[];
    for (final item in result) {
      if (item is! Map<String, dynamic>) {
        throw const ApiException('알림 목록 응답 형식이 올바르지 않습니다.');
      }
      notifications.add(item);
    }

    return notifications;
  }
}
