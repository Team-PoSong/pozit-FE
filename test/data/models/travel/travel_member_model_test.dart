import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/data/models/travel/travel_member_model.dart';

Map<String, dynamic> _memberJson({int userId = 1, String role = 'LEADER'}) {
  return {'userId': userId, 'nickname': '김윤지', 'role': role};
}

void main() {
  group('TravelMemberModel.fromJson', () {
    test('userId를 그대로 파싱한다', () {
      final member = TravelMemberModel.fromJson(_memberJson(userId: 42));
      expect(member.userId, 42);
    });

    for (final role in ['LEADER', 'leader', 'OWNER', 'HOST', 'admin']) {
      test('role "$role"은 리더로 정규화된다', () {
        final member = TravelMemberModel.fromJson(_memberJson(role: role));
        expect(member.isLeader, isTrue);
      });
    }

    for (final role in ['MEMBER', 'member', 'GUEST', 'UNKNOWN_VALUE']) {
      test('role "$role"은 리더가 아니다', () {
        final member = TravelMemberModel.fromJson(_memberJson(role: role));
        expect(member.isLeader, isFalse);
      });
    }
  });
}
