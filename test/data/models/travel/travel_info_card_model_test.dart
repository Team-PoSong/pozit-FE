import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/core/design_system/app_travel_status.dart';
import 'package:pozit/data/models/travel/travel_course_model.dart';
import 'package:pozit/data/models/travel/travel_detail_model.dart';
import 'package:pozit/data/models/travel/travel_info_card_model.dart';
import 'package:pozit/data/models/travel/travel_member_model.dart';

CourseSpotModel _spot(int touristSpotId, {required bool visited}) {
  return CourseSpotModel(
    courseSpotId: touristSpotId,
    touristSpotId: touristSpotId,
    name: '스팟$touristSpotId',
    latitude: 0,
    longitude: 0,
    orderIndex: 0,
    status: visited ? 'visited' : 'notVisited',
  );
}

TravelDetailModel _detail({
  int completionRate = 60,
  int totalSpotCount = 12,
  int totalPozingCount = 48,
  List<TravelMemberModel> members = const [],
  List<TravelCourseModel> courses = const [],
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
    courses: courses,
  );
}

void main() {
  test('fromTravelDetail은 방문 완료한 장소 수만 visitedPlaceCount로 매핑한다', () {
    final info = TravelInfoCardModel.fromTravelDetail(
      _detail(
        courses: [
          TravelCourseModel(
            courseId: 1,
            dayNumber: 1,
            date: DateTime(2026, 6, 5),
            spots: [
              _spot(1, visited: true),
              _spot(2, visited: true),
              _spot(3, visited: false),
            ],
          ),
        ],
      ),
    );

    expect(info.destination, '경주');
    expect(info.visitedPlaceCount, 2);
    expect(info.recordCount, 48);
    expect(info.completionRate, closeTo(0.6, 1e-9));
    expect(info.tags, ['기록', '미식']);
  });

  test('courses가 비어 있으면 visitedPlaceCount는 0이다', () {
    final info = TravelInfoCardModel.fromTravelDetail(_detail());

    expect(info.visitedPlaceCount, 0);
  });

  test('tags를 명시하면 detail.tags 대신 그 값을 사용한다', () {
    final info = TravelInfoCardModel.fromTravelDetail(
      _detail(),
      tags: ['힐링'],
    );

    expect(info.tags, ['힐링']);
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
