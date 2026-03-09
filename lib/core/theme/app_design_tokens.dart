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

  // ── Bottom Sheet Component ────────────────────────────────────
  /// 바텀시트 핸들 너비
  static const double widthSheetHandle = 36;

  /// 바텀시트 핸들 높이
  static const double heightSheetHandle = 4;

  /// 바텀시트 핸들 borderRadius
  static const double radiusSheetHandle = 2;

  /// 바텀시트 핸들 하단 margin (핸들 → 첫 콘텐츠 간격)
  static const double spacingSheetHandle = 20;

  /// 바텀시트 주요 액션 버튼 높이 (확인, 완료, 공유 등)
  static const double heightButtonPrimary = 52;

  // ── Control ───────────────────────────────────────────────────
  /// 공통 컨트롤 높이 (드롭다운, 조절 바 버튼 등)
  static const double heightControl = 44;

  /// 스텝 버튼 크기 — 정사각형 (±, ▲▼ 등)
  static const double sizeStepButton = 36;

  /// 스텝 버튼 borderRadius
  static const double radiusStepButton = 8;

  // ── Slider ────────────────────────────────────────────────────
  /// 슬라이더 터치 오버레이 반지름
  static const double radiusSliderOverlay = 18;

  // ── Animation ─────────────────────────────────────────────────
  /// 버튼·칩 상태 전환 (빠름)
  static const Duration durationFast = Duration(milliseconds: 150);

  /// 카드·오버레이 전환 (보통)
  static const Duration durationNormal = Duration(milliseconds: 200);

  /// 페이지·탭 전환
  static const Duration durationPage = Duration(milliseconds: 280);

}

// ════════════════════════════════════════════════════════════════
// 아래는 Q&A 방식으로 순차 확정된 신규 토큰
// ════════════════════════════════════════════════════════════════
/// 탭바 토큰.
abstract class CmTab {
  /// 탭바 레이블 (활성: w700 / 비활성: w500 은 위젯에서 copyWith)
  static const TextStyle text = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// 탭바 활성 배경 borderRadius
  static const double radius = 20;

  /// 탭바 행 높이
  static const double height = 48;
}

/// 금액·값을 표시하고 탭하면 키패드가 열리는 입력 카드 토큰.
abstract class CmInputCard {
  /// 내부 패딩
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 18);

  /// borderRadius
  static const double radius = 16;

  /// 타이틀 하단 간격 (타이틀 → 입력값)
  static const double titleSpacing = 8;

  /// 서브텍스트 상단 간격 (입력값 → 서브텍스트)
  static const double subSpacing = 4;

  /// 카드 상단 타이틀 ("총 금액", "기준 급여" 등)
  static const TextStyle titleText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// 입력값 숫자 텍스트
  static const TextStyle inputText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
  );

  /// 단위 텍스트 ("원", "USD" 등)
  static const TextStyle unitText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 보조 텍스트 ("월 3,750,000 원" 등)
  static const TextStyle subText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

/// 목록형 카드 토큰 (공제 내역 등 헤더 + 항목 행 구조).
abstract class CmListCard {
  /// borderRadius
  static const double radius = 16;

  /// 헤더 행 패딩
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  /// 항목 행 패딩
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// 헤더 레이블 텍스트 ("공제 합계" 등)
  static const TextStyle headerLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// 헤더 합계 금액 텍스트
  static const TextStyle headerValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// 항목 레이블 텍스트 ("국민연금" 등)
  static const TextStyle itemLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 항목 금액 텍스트
  static const TextStyle itemValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}

/// 결과 카드 토큰.
abstract class CmResultCard {
  /// 내부 패딩
  static const EdgeInsets padding = EdgeInsets.all(20);

  /// borderRadius
  static const double radius = 16;

  /// 타이틀 하단 간격 (타이틀 → 결과 숫자)
  static const double titleSpacing = 8;

  /// 보조 텍스트 상단 간격 (결과 숫자 → 보조 텍스트)
  static const double subSpacing = 6;

  /// 카드 상단 타이틀 ("실수령액" 등)
  static const TextStyle titleText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// 결과 숫자 텍스트
  static const TextStyle resultText = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
  );

  /// 단위 텍스트 ("원" 등)
  static const TextStyle unitText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// 보조 텍스트 ("연 실수령", "연 환산" 등)
  static const TextStyle subText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

/// 라운드 버튼 사이즈 토큰 (size + radius + iconSize 세트).
class _RoundButtonSize {
  const _RoundButtonSize({
    required this.size,
    required this.radius,
    required this.iconSize,
  });
  final double size;
  final double radius;
  final double iconSize;
}

/// 라운드 버튼 토큰. 사용처에 따라 small·medium·large를 선택한다.
abstract class CmRoundButton {
  /// 소형 — 24×24
  static const _RoundButtonSize small = _RoundButtonSize(size: 24, radius: 12, iconSize: 16);

  /// 중형 — 32×32 (부양가족 수 조절 버튼 등)
  // static const _RoundButtonSize medium = _RoundButtonSize(size: 24, radius: 12, iconSize: 16);
  static const _RoundButtonSize medium = _RoundButtonSize(size: 28, radius: 14, iconSize: 18);

  /// 대형 — 48×48 (날짜 계산기 이동 버튼, 미세 조절 바 등)
  static const _RoundButtonSize large = _RoundButtonSize(size: 32, radius: 16, iconSize: 20);

  /// 내부 그림자. color는 화면별 색상을 주입한다.
  static BoxShadow innerShadow(Color color) => BoxShadow(
        color: color,
        blurRadius: 4,
        offset: const Offset(0, 2),
        blurStyle: BlurStyle.inner,
      );
}

/// 드롭다운 버튼 토큰.
abstract class CmDropdown {
  /// 높이
  static const double height = 44;

  /// borderRadius
  static const double radius = 10;

  /// 레이블 텍스트
  static const TextStyle text = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// 화살표 아이콘 크기
  static const double iconSize = 18;
}

/// 슬라이더 토큰.
abstract class CmSlider {
  /// 트랙 높이
  static const double trackHeight = 4;

  /// thumb 반지름
  static const double thumbRadius = 10;

  /// 터치 오버레이 반지름
  static const double overlayRadius = 18;

  /// 범위 레이블 텍스트 (최솟값·최댓값 표시)
  static const TextStyle rangeLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

/// 스텝버튼 사이 값 표시 토큰 ("1명", "2명" 등).
abstract class CmStepValue {
  /// 값 텍스트 스타일
  static const TextStyle text = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// 값 표시 영역 너비
  static const double width = 44;

  /// 좌우 마진
  static const double horizontalMargin = 6;
}

/// 아이콘 크기 토큰. 사용처 기반으로 네이밍한다.
abstract class CmIcon {
  /// 입력 카드 내부 아이콘 (편집 아이콘 등)
  static const double inputCard = 16;

  /// 툴팁 아이콘
  static const double tooltip = 16;
}

/// 행 레이블 텍스트 ("부양가족 수" 등 레이블 + 컨트롤 구조의 레이블)
const TextStyle rowLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);
