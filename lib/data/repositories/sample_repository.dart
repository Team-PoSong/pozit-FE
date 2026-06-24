// API 연동 로직을 처리합니다.
/*
 * 서버 연동 시 주석 해제, dio_client 정의

import '../../core/network/dio_client.dart';
import '../models/sample_model.dart';

class ExampleRepository {
  ExampleRepository._();
  static final ExampleRepository instance = ExampleRepository._();

  Future<List<ExampleModel>> getExample() async {
    final data = await DioClient.instance.get('/api/v1/eg/example');
    return (data as List)
        .map((e) => ExampleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
*/