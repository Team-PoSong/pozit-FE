import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/support/support_info_model.dart';

void main() {
  test('구조화된 약관 응답을 모델로 변환한다', () {
    final info = SupportInfoModel.fromJson({
      'serviceTerm': {
        'title': '서비스 이용약관',
        'version': '1.0',
        'effectiveDate': '2026-07-01',
        'sections': [
          {'title': '제1조 (목적)', 'content': '본 약관은...'},
        ],
      },
      'privacyPolicy': {
        'title': '개인정보처리방침',
        'version': '1.0',
        'effectiveDate': '2026-07-01',
        'sections': [
          {'title': '제1조', 'content': '개인정보는...'},
        ],
      },
    });

    expect(info.serviceTerm.effectiveDate, DateTime(2026, 7, 1));
    expect(info.serviceTerm.sections.single.title, '제1조 (목적)');
    expect(info.privacyPolicy.sections.single.content, '개인정보는...');
  });
}
