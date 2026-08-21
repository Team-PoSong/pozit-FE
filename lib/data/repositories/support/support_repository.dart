import '../../../core/network/api_exception.dart';
import '../../datasources/support/support_datasource.dart';
import '../../models/support/support_info_model.dart';

class SupportRepository {
  const SupportRepository({SupportDatasource? datasource})
    : _datasource = datasource ?? const SupportDatasource();

  final SupportDatasource _datasource;

  Future<SupportInfoModel> getInfo() async {
    try {
      return await _datasource.getInfo();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('서비스 안내 응답을 처리하지 못했습니다.');
    }
  }

  Future<void> sendFeedback(String content) {
    return _datasource.sendFeedback(content);
  }
}
