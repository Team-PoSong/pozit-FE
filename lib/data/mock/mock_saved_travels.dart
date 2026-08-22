import 'package:flutter/material.dart';

import '../../core/design_system/app_images.dart';
import '../../core/design_system/app_travel_status.dart';
import '../models/saved_travel_model.dart';
import '../models/travel/travel_info_card_model.dart';

/// 바텀 네비게이션 바 플로팅 동작을 스크롤로 확인해 보기 위한 더미 여행 목록입니다.
List<SavedTravelModel> buildMockSavedTravels() {
  const destinations = [
    ('강릉 데이트', '강원 강릉'),
    ('부산 여행', '부산 해운대'),
    ('제주 힐링', '제주 제주'),
    ('경주 나들이', '경북 경주'),
    ('전주 한옥마을', '전북 전주'),
    ('여수 밤바다', '전남 여수'),
    ('속초 바다여행', '강원 속초'),
    ('통영 미식투어', '경남 통영'),
    ('서울 도심 나들이', '서울 종로'),
    ('가평 캠핑', '경기 가평'),
    ('춘천 드라이브', '강원 춘천'),
    ('군산 근대문화', '전북 군산'),
    ('포항 호미곶', '경북 포항'),
    ('거제 섬투어', '경남 거제'),
    ('대구 골목여행', '대구 중구'),
    ('인천 을왕리', '인천 중구'),
    ('안동 문화유산', '경북 안동'),
    ('보성 녹차밭', '전남 보성'),
  ];

  final statuses = AppTravelStatus.values;

  return List.generate(destinations.length, (index) {
    final (title, location) = destinations[index];
    final status = statuses[index % statuses.length];
    final startDate = DateTime(2026, 9, 1).add(Duration(days: index * 3));
    final endDate = startDate.add(const Duration(days: 1));

    return SavedTravelModel(
      id: 'mock-travel-$index',
      title: title,
      location: location,
      dateText: '${startDate.month}/${startDate.day} ~ ${endDate.month}/${endDate.day}',
      author: '포송',
      info: TravelInfoCardModel(
        destination: location,
        startDate: startDate,
        endDate: endDate,
        companionCount: 2 + (index % 4),
        tags: const ['힐링', '미식'],
        visitedPlaceCount: index % 5,
        recordCount: index % 3,
        completionRate: status == AppTravelStatus.completed ? 1.0 : 0.0,
      ),
      courses: const [],
      status: status,
      dDay: status == AppTravelStatus.upcoming ? 'D-${index + 1}' : null,
      backgroundImage: index.isEven
          ? const AssetImage(AppImages.travelMockup)
          : null,
      tags: const ['힐링', '미식'],
      participantCount: 2 + (index % 4),
    );
  });
}
