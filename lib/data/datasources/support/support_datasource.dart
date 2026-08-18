import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../models/support/support_info_model.dart';

class SupportDatasource {
  const SupportDatasource();

  Future<SupportInfoModel> getInfo() async {
    final result = await DioClient.instance.get('/api/support/info');
    if (result is! Map<String, dynamic>) {
      throw const ApiException('서비스 안내 응답 형식이 올바르지 않습니다.');
    }
    return SupportInfoModel.fromJson(result);
  }

  Future<void> sendFeedback(String content) {
    return DioClient.instance.post(
      '/api/support/feedback',
      data: {'content': content},
    );
  }
}
