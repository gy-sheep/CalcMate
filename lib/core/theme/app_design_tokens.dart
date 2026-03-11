import 'package:flutter/material.dart';


/// ================================================
///               Global Constants
/// ================================================

/// 카드/섹션 간 수직 간격
const double spacingSection = 16;

/// 숫자와 단위 텍스트('원', 'USD' 등) 사이 간격
const double spacingUnit = 6;

/// 행 레이블 텍스트 ("부양가족 수" 등 레이블 + 컨트롤 구조의 레이블)
const TextStyle rowLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

/// 섹션 타이틀 레이블 (생년월일, 날짜 선택 등)
const TextStyle sectionLabel = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);

/// 보조 설명 텍스트 (업데이트 시간, 단위 환율 등)
const TextStyle textStyleCaption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
);

/// 화면 좌우 기본 패딩
const double screenPaddingH = 16;

/// 카드/컨테이너 기본 borderRadius
const double radiusCard = 16;

/// 입력 필드 borderRadius
const double radiusInput = 12;

/// 본문 텍스트 (16/w600)
const TextStyle textStyle16 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

/// BMI 수치 등 대형 결과 표시 (52/w300)
const TextStyle textStyle52 = TextStyle(
  fontSize: 52,
  fontWeight: FontWeight.w300,
  height: 1.0,
);

/// 결과/변환값 텍스트 (18/w400)
const TextStyle textStyle18 = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w400,
);

/// 대형 입력값 표시 텍스트 (40/w300)
const TextStyle textLargeInput = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.w300,
);

/// 중형 결과값 텍스트 (22/w400)
const TextStyle textMediumResult = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w400,
);

/// 빈 상태 안내 메시지 텍스트 (16/w400)
const TextStyle textEmptyGuide = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

/// 입력 필드 내부 텍스트 (16/w400)
const TextStyle inputFieldInnerLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

/// 모달 버튼 레이블 (16/w400)
const TextStyle modalButtonLabel = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

/// ── 애니메이션 Duration ─────────────────────────────────────────

/// 100ms — 즉각적 반응 (리플, 토글)
const Duration durationAnimInstant = Duration(milliseconds: 100);

/// 150ms — 빠른 전환 (칩 선택, 참가자 바)
const Duration durationAnimFast = Duration(milliseconds: 150);

/// 180ms — 빠른 전환 (필드 활성화)
const Duration durationAnimQuick = Duration(milliseconds: 180);

/// 200ms — 기본 전환 (탭, 리스트 항목)
const Duration durationAnimDefault = Duration(milliseconds: 200);

/// 250ms — 중간 전환 (게이지, 오버레이)
const Duration durationAnimMedium = Duration(milliseconds: 250);

/// 300ms — 느린 전환 (화면 진입, 탭 전환)
const Duration durationAnimSlow = Duration(milliseconds: 300);

/// 400ms — 페이지 전환
const Duration durationPageTransition = Duration(milliseconds: 400);

/// ── 키패드 ────────────────────────────────────────────────────

/// 키패드 버튼 높이 — 기본 (기본·환율·부가세 계산기)
const double keypadButtonHeightLarge = 68;

/// 키패드 버튼 높이 — 중형 (단위 변환기)
const double keypadButtonHeightMedium = 56;

/// 키패드 확인 버튼 높이
const double keypadButtonHeightPrimary = 52;

/// 키패드 백스페이스 아이콘 크기
const double keypadBackspaceSize = 26;

/// 키패드 숫자 버튼 텍스트 (22/w400)
const TextStyle keypadNumberText = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w400,
);

/// 키패드 연산자/등호 버튼 텍스트 (28/w400)
const TextStyle keypadOperatorText = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w400,
);

/// ================================================
///                   CmTab
/// ================================================
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

  /// 칩 내부 패딩
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 14, vertical: 8);

  /// 칩 아이콘 크기
  static const double iconSize = 16;
}

/// ================================================
///                 CmInputCard
/// ================================================
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
    fontSize: 14,
    fontWeight: FontWeight.w800,
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

/// ================================================
///                CmResultCard
/// ================================================
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
    fontSize: 14,
    fontWeight: FontWeight.w800,
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

/// ================================================
///                 CmListCard
/// ================================================
abstract class CmListCard {
  /// borderRadius
  static const double radius = 16;

  /// 헤더 행 패딩
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  /// 항목 행 패딩
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// 구분선 두께
  static const double dividerHeight = 1;

  /// 헤더 레이블 텍스트 ("공제 합계" 등)
  static const TextStyle headerLabel = TextStyle(
    fontSize: 15,
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

/// ================================================
///               CmRoundButton
/// ================================================
class RoundButtonSize {
  const RoundButtonSize({
    required this.size,
    required this.radius,
    required this.iconSize,
  });
  final double size;
  final double radius;
  final double iconSize;
}

abstract class CmRoundButton {
  /// 소형 — 24×24
  static const RoundButtonSize small = RoundButtonSize(size: 24, radius: 12, iconSize: 16);

  /// 중형 — 32×32 (부양가족 수 조절 버튼 등)
  // static const RoundButtonSize medium = RoundButtonSize(size: 24, radius: 12, iconSize: 16);
  static const RoundButtonSize medium = RoundButtonSize(size: 28, radius: 14, iconSize: 18);

  /// 대형 — 48×48 (날짜 계산기 이동 버튼, 미세 조절 바 등)
  static const RoundButtonSize large = RoundButtonSize(size: 32, radius: 16, iconSize: 20);

  /// 내부 그림자. color는 화면별 색상을 주입한다.
  static BoxShadow innerShadow(Color color) => BoxShadow(
        color: color,
        blurRadius: 4,
        offset: const Offset(0, 2),
        blurStyle: BlurStyle.inner,
      );
}

/// ================================================
///                 CmDropdown
/// ================================================
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

/// ================================================
///                  CmSlider
/// ================================================
abstract class CmSlider {
  /// 트랙 높이
  static const double trackHeight = 4;

  /// thumb 반지름
  static const double thumbRadius = 10;

  /// 터치 오버레이 반지름
  static const double overlayRadius = 18;

  /// 슬라이더 상단 간격 (콘텐츠 → 슬라이더)
  static const double topSpacing = 12;

  /// 범위 라벨 좌우 패딩
  static const double labelPaddingH = 4;

  /// 범위 레이블 텍스트 (최솟값·최댓값 표시)
  static const TextStyle rangeLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

/// ================================================
///                CmStepValue
/// ================================================
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

/// ================================================
///                   CmIcon
/// ================================================
abstract class CmIcon {
  /// 입력 카드 내부 아이콘 (편집 아이콘 등)
  static const double inputCard = 16;

  /// 툴팁 아이콘
  static const double tooltip = 16;

  /// 소형 아이콘 (새로고침, 닫기 등)
  static const double small = 20;

  /// CupertinoActivityIndicator 반지름
  static const double activityIndicator = 10;
}

/// ================================================
///                  CmKeypad
/// ================================================
abstract class CmKeypad {
  /// 모달 내부 패딩
  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 12, 16, 0);

  /// 입력 표시 영역 패딩
  static const EdgeInsets displayPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  /// 입력 표시 → 키패드 간격
  static const double displaySpacing = 16;

  /// 키패드 행 간격
  static const double rowSpacing = 8;

  /// 버튼 좌우 간격
  static const double buttonSpacingH = 4;

  /// 버튼 borderRadius
  static const double buttonRadius = 12;

  /// 확인 버튼 하단 safe area 추가 여백
  static const double bottomPadding = 16;
}

/// ================================================
///                CmBottomBar
/// ================================================
abstract class CmBottomBar {
  /// 내부 패딩
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  /// 레이블과 아이콘 사이 간격
  static const double labelIconSpacing = 4;
}

/// ================================================
///              CmLoadingOverlay
/// ================================================
abstract class CmLoadingOverlay {
  /// 다이얼로그 borderRadius
  static const double radius = 16;

  /// 내부 패딩
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24, vertical: 20);

  /// 배경 블러 sigma
  static const double blurSigma = 10;

  /// 스피너 크기
  static const double spinnerSize = 20;

  /// 스피너 선 두께
  static const double spinnerStroke = 2;

  /// 스피너 ↔ 텍스트 간격
  static const double spinnerTextSpacing = 14;

  /// 텍스트 스타일
  static const TextStyle text = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
}

/// ================================================
///                  CmAppBar
/// ================================================
abstract class CmAppBar {
  /// 뒤로가기 아이콘 크기
  static const double backIconSize = 20;

  /// 타이틀 텍스트
  static const TextStyle titleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
}

/// ================================================
///                  CmSheet
/// ================================================
abstract class CmSheet {
  /// 시트 상단 borderRadius
  static const double radius = 20;

  /// 시트 내부 패딩
  static const EdgeInsets padding = EdgeInsets.all(16);

  /// 리스트형 시트 높이 비율 (MediaQuery 기준)
  static const double listHeightRatio = 0.6;

  /// 핸들 너비
  static const double handleWidth = 40;

  /// 핸들 높이
  static const double handleHeight = 4;

  /// 핸들 borderRadius
  static const double handleRadius = 2;

  /// 핸들 위 여백 (시트 상단 → 핸들)
  static const double handleTopSpacing = 12;

  /// 핸들 아래 여백 (핸들 → 콘텐츠)
  static const double handleBottomSpacing = 16;

  /// 시트 제목 텍스트
  static const TextStyle titleText = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

  /// 리스트 아이템 타이틀 — 기본형
  static const TextStyle itemTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  /// 리스트 아이템 서브텍스트 — 기본형
  static const TextStyle itemSubtext = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

  /// 리스트 구분선 두께
  static const double dividerThickness = 0.3;

  /// 리스트 구분선 높이
  static const double dividerHeight = 1;
}

/// ================================================
///                   CmFlag
/// ================================================
abstract class CmFlag {
  /// 국기 크기 — 중형 (기본)
  static const double medium = 32;

  /// 국기 크기 — 대형
  static const double large = 48;

  /// 코드 버튼 전체 너비 (국기 + 코드 텍스트 세로 배치)
  static const double buttonWidth = 48;

  /// 국기 ↔ 코드 텍스트 간격
  static const double codeSpacing = 4;

  /// 코드 텍스트 스타일
  static const TextStyle codeText = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}

/// ================================================
///               CmCurrencyRow
/// ================================================
abstract class CmCurrencyRow {
  /// 통화 행 좌우 패딩 (left: 16, right: 24)
  static const EdgeInsets padding = EdgeInsets.only(left: 16, right: 24);

  /// 통화 행 최소 높이
  static const double minHeight = 80;

  /// 통화 코드 버튼 ↔ 금액 표시 간격
  static const double codeSpacing = 16;

  /// 금액 표시 텍스트
  static const TextStyle amountText = TextStyle(fontSize: 28, fontWeight: FontWeight.w300);
}

/// ================================================
///               CmTextToggle
/// ================================================
abstract class CmTextToggle {
  /// 토글 옵션 텍스트 (선택 여부·색상은 위젯에서 copyWith)
  static const TextStyle text = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
}

/// ================================================
///               CmInfoCard
/// ================================================
abstract class CmInfoCard {
  /// 카드 내부 패딩
  static const EdgeInsets padding = EdgeInsets.all(20);

  /// 대형 결과값 (세는 나이 등)
  static const TextStyle displayText = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    height: 1.1,
  );

  /// 카드 제목 날짜 텍스트 ("2026년 6월 18일" 등)
  static const TextStyle titleText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
  );

  /// 인라인 태그 borderRadius
  static const double tagRadius = 6;

  /// 인라인 태그 라벨 텍스트
  static const TextStyle tagLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// 보조 텍스트 (요일, 단위 등)
  static const TextStyle captionText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// 본문 텍스트 (요일 등)
  static const TextStyle bodyText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
}

/// ================================================
///               CmCheckbox
/// ================================================
abstract class CmCheckbox {
  /// 체크박스 크기 — 소형
  static const double sizeSmall = 16;

  /// 체크박스 크기 — 중형 (기본)
  static const double sizeMedium = 18;

  /// 체크박스 크기 — 대형
  static const double sizeLarge = 20;

  /// 라벨 텍스트 — 소형 (컴팩트 행, 인라인 보조)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// 라벨 텍스트 — 중형 (기본)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// 라벨 텍스트 — 대형 (카드·섹션 단위)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );
}

/// ================================================
///             CmBirthdayMiniCard
/// ================================================
abstract class CmBirthdayMiniCard {
  /// 카드 타이틀 ("오늘이 생일이에요!" 등)
  static const TextStyle titleText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  /// 레이블 ("다음 생일" 등)
  static const TextStyle labelText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// 결과값 ("D-숫자" 등)
  static const TextStyle resultText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
  );

  /// 서브텍스트 (날짜 등)
  static const TextStyle subText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}

/// ================================================
///               CmCalendarCard
/// ================================================
abstract class CmCalendarCard {
  /// 카드 내부 패딩
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  /// 카드 borderRadius
  static const double radius = 16;

  /// 연도 텍스트 ("2026년")
  static const TextStyle yearText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// 월일 텍스트 ("3월 10일")
  static const TextStyle dateText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
  );

  /// 요일 텍스트 ("화요일")
  static const TextStyle weekdayText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// 화살표 아이콘 크기
  static const double chevronSize = 18;
}

