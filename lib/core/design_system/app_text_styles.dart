import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 텍스트 스타일 정의
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle headline = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    height: 20 / 20,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    height: 20 / 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    height: 24 / 14,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    height: 14 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    height: 14 / 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
  );
}