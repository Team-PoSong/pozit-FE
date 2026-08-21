import '../models/tourist_spot_model.dart';

/// 직접 만들기와 코스 수정에서 함께 사용하는 장소 목데이터입니다.
const List<TouristSpotModel> mockPopularTouristSpots = [
  TouristSpotModel(
    touristSpotId: 1,
    name: '불국사',
    address: '경북 경주시 불국로 385',
    latitude: 35.7900,
    longitude: 129.3320,
  ),
  TouristSpotModel(
    touristSpotId: 2,
    name: '미륵사지',
    address: '전북 익산시 금마면 미륵사지로 362',
    latitude: 35.9882,
    longitude: 126.9917,
  ),
  TouristSpotModel(
    touristSpotId: 3,
    name: '경주월드',
    address: '경북 경주시 보문로 544',
    latitude: 35.8364,
    longitude: 129.2827,
  ),
];
