import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel/travel_detail_model.dart';
import 'package:pozit/data/models/travel/travel_info_card_model.dart';
import 'package:pozit/data/models/travel/travel_member_model.dart';

TravelDetailModel _detail({
  int completionRate = 60,
  int totalSpotCount = 12,
  int totalPozingCount = 48,
  List<TravelMemberModel> members = const [],
}) {
  return TravelDetailModel(
    travelId: 1,
    title: '경주 여행',
    destination: '경주',
    startDate: DateTime(2026, 6, 5),
    endDate: DateTime(2026, 6, 7),
    status: AppTravelStatus.inProgress,
    isPublic: false,
    backgroundImageUrl: '',
    inviteCode: 'AB12C',
    completionRate: completionRate,
    totalSpotCount: totalSpotCount,
    totalPozingCount: totalPozingCount,
    tags: const ['기록', '미식'],
    members: members,
  );
}

void main() {
  test('fromTravelDetail은 장소/기록/완주율을 매핑한다', () {
    final info = TravelInfoCardModel.fromTravelDetail(_detail());

    expect(info.destination, '경주');
    expect(info.visitedPlaceCount, 12);
    expect(info.recordCount, 48);
    expect(info.completionRate, closeTo(0.6, 1e-9));
    expect(info.tags, ['기록', '미식']);
  });

  test('companionCount는 members 수를 사용한다', () {
    final info = TravelInfoCardModel.fromTravelDetail(
      _detail(
        members: const [
          TravelMemberModel(userId: 1, nickname: '김윤지', isLeader: true),
          TravelMemberModel(userId: 2, nickname: '박서현', isLeader: false),
          TravelMemberModel(userId: 3, nickname: '이하림', isLeader: false),
        ],
      ),
    );

    expect(info.companionCount, 3);
  });
}
