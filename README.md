# Pozit 🧭

> 여행의 순간을 오늘의 기록으로

위치 기반으로 일행과 함께 여행을 기록하는 국내 여행 플랫폼입니다.
여행 전 취향 기반 큐레이션, 여행 중 위치 기반 기록(Pozing), 여행 후 자동 브이로그 생성까지 여행의 전 과정을 하나의 흐름으로 연결합니다.

<br>

## 📁 프로젝트 구조

```
pozit/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── design_system/      # 앱 전역 상수
│   │   │   └── widgets/        # 공통 컴포넌트
│   │   └── network/            # 공통 유틸리티 함수
│   ├── data/
│   │   ├── models/             # 데이터 모델 클래스
│   │   └── repositories/       # Repository 구현체
│   └── presentation/
│       ├── home/               # 홈 화면
│       ├── travel/             # 내 여행 화면
│       ├── explore/            # 탐색 화면
│       └── mypage/             # 마이페이지 화면
├── assets/
│   ├── images/
│   ├── fonts/
│   └── icons/
├── test/
├── pubspec.yaml
└── README.md
```

<br>

## ⚙️ 기술 스택

- **Framework**: Flutter
- **Language**: Dart
- **지도**: Kakao Map API
- **공공데이터**: 한국관광공사 OpenAPI

<br>

---

## 🌿 Git 컨벤션

### Branch 전략

```
main
├── develop
│   ├── feature/#이슈 번호_기능명
│   ├── fix/#이슈 번호_버그명
│   └── refactor/#이슈 변호_리팩토링명
```

| 브랜치                  | 설명 |
|----------------------|------|
| `main`               | 배포 브랜치 |
| `develop`            | 개발 통합 브랜치 |
| `feature/#이슈 변호_이름`  | 기능 개발 |
| `fix/#이슈 변호_이름`      | 버그 수정 |
| `refactor/#이슈 번호_이름` | 리팩토링 |

<br>

### Commit Message

```
<type>: <# 이슈 번호> <subject>

<body> (선택)
```

**type 목록**

| type | 설명 |
|------|------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 기능 변경 없는 코드 구조 개선 |
| `chore` | 패키지 설정, 빌드 업무, 기타 단순 작업 |
| `docs` | 문서 작성 및 수정 |
| `mod` | 기존 기능의 로직 변경 또는 수정 |

**예시**

```
feat: #3 위치 기반 Pozing 촬영 기능 구현

관광지 반경 내 진입 시 Pozing이 자동 활성화되도록 구현
```

<br>

### Issue & PR

- Issue와 PR 제목은 `[type] #이슈 변호 작업 내용` 형식으로 작성합니다.
- Issue와 PR을 작성할 시 Assignee를 반드시 본인으로 설정합니다.
- PR 작성 시 Reviewer을 팀원으로 설정합니다.
- PR은 반드시 리뷰 승인 후 머지합니다.
- PR 머지 전 로컬에서 빌드 확인을 필수로 합니다.

**예시**

```
[feat] #3 위치 기반 Pozing 촬영 기능 구현
[fix] #7 여행 생성 시 날짜 선택 오류 수정
```

<br>

### Labels

| 라벨 | 설명 |
|------|------|
| ✨ FEAT | 새로운 기능 추가 |
| 🐛 BUG | 버그 수정 |
| 🛠 MOD | 기존 기능의 로직 변경 또는 수정 |
| ♻️ REFACTOR | 기능 변경 없는 코드 구조 개선 |
| ⚙️ CHORE | 패키지 설정, 빌드 업무, 기타 단순 작업 |
| 📝 DOCS | 문서 작성 및 수정 |
| 🔥 CRITICAL | 즉시 해결해야 하는 치명적인 문제 |
| ⚡️ HIGH | 우선순위가 높은 작업 |
| 🌱 LOW | 여유가 있을 때 처리해도 되는 작업 |
| 🚧 in-progress | 현재 작업 중인 이슈 |
| ✅ merged | 머지 완료 상태 |
| 📦 on-hold | 외부 요인이나 논의 필요로 중단된 상태 |

> 라벨은 이슈 등록 및 PR 등록 시에 선택합니다.

<br>

---

## 🎨 코드 컨벤션 (Flutter / Dart)

### 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스, enum, typedef | `UpperCamelCase` | `TravelCard`, `UserStatus` |
| 함수, 변수, 매개변수 | `lowerCamelCase` | `getTravelList()`, `userName` |
| 상수 | `lowerCamelCase` | `defaultPadding` |
| 파일명 | `snake_case` | `travel_card.dart` |
| 디렉토리명 | `snake_case` | `travel_detail/` |
| private 멤버 | `_lowerCamelCase` | `_isLoading` |

<br>

### 파일 및 Import 순서

파일 상단 import는 아래 순서로 그룹화하고, 각 그룹 사이에 빈 줄을 추가합니다.

```dart
// 1. dart 기본 라이브러리
import 'dart:async';

// 2. Flutter 패키지
import 'package:flutter/material.dart';

// 3. 외부 pub 패키지
import 'package:riverpod/riverpod.dart';

// 4. 내부 패키지 (절대 경로)
import 'package:pozit/core/theme/app_colors.dart';
import 'package:pozit/domain/entities/travel.dart';
```

<br>

### 위젯 작성 규칙

- 위젯은 기능 단위로 분리하고, 하나의 파일에 **하나의 public 위젯**만 작성합니다.
- 재사용 가능한 위젯은 `core/widgets/`에 위치시킵니다.
- `const` 생성자를 사용할 수 있는 경우 반드시 `const`를 사용합니다.
- 위젯 트리가 깊어지면 별도 메서드가 아닌 **별도 위젯 클래스**로 분리합니다.

```dart
// ✅ Good
class TravelCard extends StatelessWidget {
  const TravelCard({super.key, required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TravelCardContent(travel: travel),
    );
  }
}

// ❌ Bad - 메서드로 위젯 분리
Widget _buildTravelCard(Travel travel) {
  return Card(...);
}
```

<br>

### 코드 스타일

- 함수와 클래스 사이에 **빈 줄 1개**를 추가합니다.
- `var` 사용을 지양하고, **타입을 명시**합니다.
- `null` 안전성을 위해 `!` 연산자 사용을 최소화하고, `??`, `?.`를 적극 활용합니다.
- 문자열은 **작은따옴표(`'`)**를 사용합니다.

```dart
// ✅ Good
String userName = '홍길동';
final List<Travel> travelList = [];
final String? location = travel.location ?? '위치 없음';

// ❌ Bad
var userName = "홍길동";
var travelList = [];
final String location = travel.location!;
```

<br>

### 주석

- 클래스와 public 함수에는 **`///` doc comment**를 작성합니다.
- 코드 수정 시 수정한 부분에 주석을 추가합니다.
- 임시 코드는 `// TODO:` 또는 `// FIXME:` 태그를 사용합니다.

```dart
/// 여행 정보를 나타내는 카드 위젯
///
/// [travel] 표시할 여행 데이터
class TravelCard extends StatelessWidget { ... }

// TODO: 위치 권한 거부 시 예외 처리 추가
// FIXME: 날짜 선택 시 간헐적으로 null 반환 문제
```

<br>