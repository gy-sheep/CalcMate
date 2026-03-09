import 'package:flutter/material.dart';

/// 앱 전체 디자인 토큰.
///
/// 각 화면의 `_k*` / 하드코딩 값 대신 이 클래스의 상수를 참조한다.
/// 배경 그라디언트·액센트 컬러 등 화면별 고유 색상은 각 화면에 유지한다.
abstract class AppTokens {
  // ── Semantic TextStyle ───────────────────────────────────────
  /// AppBar 타이틀
  static const TextStyle textStyleAppBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// 카드 타이틀 (메인 화면 CalcModeCard 등)
  static const TextStyle textStyleCardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 바텀 시트 제목
  static const TextStyle textStyleSheetTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 섹션 헤더 ("기준 금액", "참여자 목록")
  static const TextStyle textStyleSectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// 일반 본문
  static const TextStyle textStyleBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 입력창 힌트
  static const TextStyle textStyleHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 보조 설명, 단위
  static const TextStyle textStyleCaption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 보조 수치 (AgeRow value 등)
  static const TextStyle textStyleValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// 칩·탭 레이블
  static const TextStyle textStyleChip = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 아이콘·국기 하단 식별 레이블 — 소형
  static const TextStyle textStyleLabelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  /// 아이콘·국기 하단 식별 레이블 — 중형 (기본)
  static const TextStyle textStyleLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// 아이콘·국기 하단 식별 레이블 — 대형
  static const TextStyle textStyleLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// 결과값 표시 — 56sp (기본 계산기·나이·날짜 기간)
  static const TextStyle textStyleResult56 = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    height: 1.1,
  );

  /// 결과값 표시 — 52sp (BMI 수치)
  static const TextStyle textStyleResult52 = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w300,
    height: 1.0,
  );

  /// 결과값 표시 — 48sp (날짜 D-Day)
  static const TextStyle textStyleResult48 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 40sp (부가세·날짜 계산)
  static const TextStyle textStyleResult40 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 36sp (더치페이 1인·할인 최종가)
  static const TextStyle textStyleResult36 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 32sp (더치페이 총액)
  static const TextStyle textStyleResult32 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 28sp (환율 금액)
  static const TextStyle textStyleResult28 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 24sp (할인 입력)
  static const TextStyle textStyleResult24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
  );

  /// 결과값 표시 — 22sp (부가세 합계·할인 보조)
  static const TextStyle textStyleResult22 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  /// 결과값 표시 — 18sp (단위 변환)
  static const TextStyle textStyleResult18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  /// 키패드 숫자 버튼
  static const TextStyle textStyleKeypadNumber = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  /// 키패드 연산자/등호 버튼
  static const TextStyle textStyleKeypadOperator = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

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

  /// 칩 내부 패딩 (카테고리 탭, 선택 칩 등)
  static const EdgeInsets paddingChip = EdgeInsets.symmetric(horizontal: 14, vertical: 8);

  /// 숫자 입력 필드 내부 패딩 (더치페이 총금액, 할인 계산기 등)
  static const EdgeInsets paddingInputField = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  /// 결과 카드 내부 패딩 (나이 계산기 AgeCard, 할인 계산기 ResultCard 등)
  static const EdgeInsets paddingCard = EdgeInsets.all(20);

  // ── Component ────────────────────────────────────────────────
  /// AppBar 뒤로가기 아이콘 크기
  static const double sizeAppBarBackIcon = 20;

  /// 국기 아이콘 — 소형 (밀집 목록, 칩 등)
  static const double sizeFlagSmall = 24;

  /// 국기 아이콘 — 중형 (기본)
  static const double sizeFlagMedium = 32;

  /// 국기 아이콘 — 대형 (강조 표시)
  static const double sizeFlagLarge = 48;

  /// 키패드 버튼 높이 (기본·환율·부가세 계산기)
  static const double heightButtonLarge = 68;

  /// 키패드 버튼 높이 (단위 변환기)
  static const double heightButtonMedium = 56;

  /// 세그먼트 컨트롤 높이
  static const double heightSegment = 36;

  /// 키패드 입력 영역 밑줄 두께
  static const double thicknessInputUnderline = 1.5;

  /// 슬라이더 트랙 높이
  static const double heightSliderTrack = 4;

  /// 슬라이더 thumb 반지름
  static const double radiusSliderThumb = 10;

  /// 키패드 백스페이스 아이콘 크기
  static const double sizeKeypadBackspace = 26;

  /// 아이콘 — 극소형 (칩 내부 아이콘 등)
  static const double sizeIconXSmall = 16;

  /// 아이콘 — 소형
  static const double sizeIconSmall = 20;

  /// 아이콘 — 중형
  static const double sizeIconMedium = 22;

  /// 아이콘 컨테이너 크기 (메인 카드·건강 정보 카드 등)
  static const double sizeIconContainer = 44;

  /// 아이콘 컨테이너 borderRadius
  static const double radiusIconContainer = 10;

  /// 아이콘 — 스텝 버튼 (±, ◀▶ 등)
  static const double sizeIconStep = 18;

  /// 아이콘 — 드롭다운 화살표
  static const double sizeIconDropdown = 18;

  /// 체크박스 — 소형 (컴팩트 행, 인라인 보조)
  static const double sizeCheckboxSmall = 16;

  /// 체크박스 — 중형 (기본)
  static const double sizeCheckboxMedium = 18;

  /// 체크박스 — 대형 (카드·섹션 단위)
  static const double sizeCheckboxLarge = 20;

  /// 체크박스 옆 라벨 — 소형 (컴팩트 행, 인라인 보조)
  static const TextStyle textStyleCheckboxLabelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// 체크박스 옆 라벨 — 중형 (기본)
  static const TextStyle textStyleCheckboxLabelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// 체크박스 옆 라벨 — 대형 (카드·섹션 단위)
  static const TextStyle textStyleCheckboxLabelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );


  /// CupertinoActivityIndicator 반지름
  static const double radiusActivityIndicator = 10;
}
