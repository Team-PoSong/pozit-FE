import '../../core/network/api_exception.dart';
import '../datasources/notification/notification_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  const NotificationRepository({NotificationDatasource? datasource})
    : _datasource = datasource ?? const NotificationDatasource();

  final NotificationDatasource _datasource;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifications = await _datasource.fetchNotifications();
      return notifications.map(NotificationModel.fromJson).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('알림 응답을 처리하지 못했습니다.');
    }
  }
}
