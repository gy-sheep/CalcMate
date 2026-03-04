import 'package:flutter/material.dart';

/// 앱 전체 디자인 토큰.
///
/// 각 화면의 `_k*` / 하드코딩 값 대신 이 클래스의 상수를 참조한다.
/// 배경 그라디언트·액센트 컬러 등 화면별 고유 색상은 각 화면에 유지한다.
abstract class AppTokens {
  // ── Typography ───────────────────────────────────────────────
  /// AppBar 타이틀 폰트 크기
  static const double fontSizeAppBarTitle = 18;

  /// AppBar 타이틀 폰트 웨이트
  static const FontWeight weightAppBarTitle = FontWeight.w600;

  /// 레이블 (힌트, 소제목 등) 폰트 크기
  static const double fontSizeLabel = 12;

  /// 본문 폰트 크기
  static const double fontSizeBody = 14;

  /// 값 표시 폰트 크기
  static const double fontSizeValue = 16;

  // ── Shape ────────────────────────────────────────────────────
  /// 카드·컨텐츠 컨테이너 borderRadius
  static const double radiusCard = 16;

  /// Bottom Sheet 상단 borderRadius
  static const double radiusBottomSheet = 20;

  /// 칩·세그먼트 borderRadius
  static const double radiusChip = 20;

  /// 태그·뱃지 borderRadius
  static const double radiusTag = 6;

  /// AppBar 아이콘 박스 borderRadius
  static const double radiusAppBarIcon = 7;

  /// 입력 필드·검색창 borderRadius
  static const double radiusInput = 12;

  // ── Spacing ──────────────────────────────────────────────────
  /// 화면 수평 패딩
  static const double paddingScreenH = 16;

  /// 카드 내부 패딩
  static const double paddingCardInner = 16;

  /// AppBar 수평 패딩
  static const double paddingAppBarH = 16;

  /// AppBar 수직 패딩
  static const double paddingAppBarV = 12;

  // ── Component ────────────────────────────────────────────────
  /// AppBar 아이콘 박스 크기 (width & height)
  static const double sizeAppBarIcon = 28;

  /// AppBar 아이콘 내부 아이콘 크기
  static const double sizeAppBarIconInner = 15;

  /// 키패드 버튼 높이 (기본·환율·부가세 계산기)
  static const double heightButtonLarge = 68;

  /// 키패드 버튼 높이 (단위 변환기)
  static const double heightButtonMedium = 56;

  /// 세그먼트 컨트롤 높이
  static const double heightSegment = 36;
}
