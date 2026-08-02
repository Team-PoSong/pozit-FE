# 카카오맵 SDK(kakao_map_sdk)용 keep 규칙입니다. 릴리스 빌드에서 코드 축소/난독화를
# 켰을 때 지도 렌더링이 깨지지 않도록 필요합니다.
-keep class com.kakao.vectormap.** { *; }
-keep interface com.kakao.vectormap.**
