import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pozit/screens/travel_creation/travel_creation_data.dart';
import 'package:pozit/screens/travel_creation/travel_creation_pipeline.dart';

void main() {
  group('TravelCreationPipeline.buildCreateRequest', () {
    test('직접 만들기 입력을 여행 생성 API 형식으로 변환한다', () {
      final request = TravelCreationPipeline.buildCreateRequest(
        TravelCreationDraft(
          destination: '서울특별시',
          regionCode: '11000',
          dateRange: DateTimeRange(
            start: DateTime(2026, 8, 1),
            end: DateTime(2026, 8, 3),
          ),
          name: '서울 주말 여행',
          tags: const {'맛집', '힐링'},
          tagIds: const [1, 2],
          transportation: '대중교통',
          densityLevel: 2,
        ),
      );

      expect(request.toJson(), {
        'title': '서울 주말 여행',
        'destination': '서울특별시',
        'regionCode': '11000',
        'startDate': '2026-08-01',
        'endDate': '2026-08-03',
        'transportation': 'PUBLIC',
        'travelStyle': 'TIGHT',
        'tagIds': [1, 2],
      });
    });

    test('API 지역 코드가 없으면 요청을 만들지 않는다', () {
      final draft = TravelCreationDraft(
        destination: '서울특별시',
        dateRange: DateTimeRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 2),
        ),
        name: '서울 여행',
        tags: const {'맛집'},
        tagIds: const [1],
      );

      expect(
        () => TravelCreationPipeline.buildCreateRequest(draft),
        throwsStateError,
      );
    });

    test('API 태그 ID가 없으면 요청을 만들지 않는다', () {
      final draft = TravelCreationDraft(
        destination: '서울특별시',
        regionCode: '11000',
        dateRange: DateTimeRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 2),
        ),
        name: '서울 여행',
        tags: const {'맛집'},
      );

      expect(
        () => TravelCreationPipeline.buildCreateRequest(draft),
        throwsStateError,
      );
    });
  });
}
