import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel_invite/travel_invite_search_model.dart';

void main() {
  group('TravelInviteSearchModel.fromJson', () {
    test('신규 여행 조회 응답을 파싱한다', () {
      final model = TravelInviteSearchModel.fromJson({
        'inviteStatus': 'JOINABLE',
        'travelStatus': 'BEFORE',
        'message': '성공적으로 조회했어요.',
        'travelId': 1,
        'title': '서울 주말 여행',
        'destination': '서울특별시',
        'leader': '닉네임',
        'memberCount': 3,
        'tags': ['맛집', '힐링'],
        'startDate': '2026-08-01',
        'endDate': '2026-08-03',
        'backgroundImageUrl': 'https://example.com/travel.jpg',
      });

      expect(model.status, TravelInviteSearchStatus.joinable);
      expect(model.travelStatus, AppTravelStatus.upcoming);
      expect(model.backgroundImageUrl, 'https://example.com/travel.jpg');
      expect(model.travelId, 1);
      expect(model.tags, ['맛집', '힐링']);
    });

    test('초대 상태와 여행 상태 enum 전체를 매핑한다', () {
      const inviteCases = {
        'JOINABLE': TravelInviteSearchStatus.joinable,
        'ALREADY_JOINED': TravelInviteSearchStatus.alreadyJoined,
        'UNAVAILABLE': TravelInviteSearchStatus.unavailable,
      };
      const travelCases = {
        'BEFORE': AppTravelStatus.upcoming,
        'IN_PROGRESS': AppTravelStatus.inProgress,
        'DONE': AppTravelStatus.completed,
      };

      for (final inviteCase in inviteCases.entries) {
        for (final travelCase in travelCases.entries) {
          final model = TravelInviteSearchModel.fromJson({
            'inviteStatus': inviteCase.key,
            'travelStatus': travelCase.key,
            'message': '조회 성공',
            'travelId': 1,
            'title': '서울 주말 여행',
            'destination': '서울특별시',
            'leader': '닉네임',
            'memberCount': 3,
            'tags': <String>[],
            'startDate': '2026-08-01',
            'endDate': '2026-08-03',
            'backgroundImageUrl': null,
          });

          expect(model.status, inviteCase.value);
          expect(model.travelStatus, travelCase.value);
        }
      }
    });

    test('알 수 없는 초대 상태는 파싱하지 않는다', () {
      expect(
        () => TravelInviteSearchModel.fromJson({
          'inviteStatus': 'UNKNOWN',
          'travelStatus': 'BEFORE',
          'message': '알 수 없는 메시지',
          'travelId': 1,
          'title': '서울 주말 여행',
          'destination': '서울특별시',
          'leader': '닉네임',
          'memberCount': 3,
          'tags': <String>[],
          'startDate': '2026-08-01',
          'endDate': '2026-08-03',
          'backgroundImageUrl': null,
        }),
        throwsFormatException,
      );
    });
  });
}
