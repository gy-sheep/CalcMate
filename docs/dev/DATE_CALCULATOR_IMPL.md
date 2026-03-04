# 날짜 계산기 구현 명세

> **Feature**: `Phase 6 — 날짜 계산기`
> **Branch**: `feat/date-calculator`
> **Status**: 완료

---

## 파일 구조

```
lib/
  domain/
    models/
      date_calculator_state.dart          # Freezed State
      date_calculator_state.freezed.dart  # 생성 파일
    usecases/
      date_calculate_usecase.dart         # 순수 계산 로직 + Result 타입
  presentation/
    date_calculator/
      date_calculator_viewmodel.dart      # AutoDisposeNotifier + sealed Intent
      date_calculator_screen.dart         # ConsumerStatefulWidget, 레이아웃만
      date_calculator_colors.dart         # 날짜 계산기 전용 색상 상수
      widgets/
        date_tab_bar.dart                 # 3개 모드 탭 (탄성 스트레치 애니메이션)
        period_mode_view.dart             # "기간 계산" 모드 UI
        date_calc_mode_view.dart          # "날짜 계산" 모드 UI
        dday_mode_view.dart               # "D-Day" 모드 UI
        date_keypad.dart                  # 키패드 + 방향 토글
        date_card.dart                    # 날짜 표시 카드
        result_card.dart                  # 결과 카드

test/
  domain/
    usecases/
      date_calculate_usecase_test.dart    # 28 케이스

docs/
  specs/DATE_CALCULATOR.md               # 기획 명세
  dev/DATE_CALCULATOR_IMPL.md            # 이 파일
```

---

## 1. Domain: DateCalculatorState

```dart
@freezed
class DateCalculatorState with _$DateCalculatorState {
  const factory DateCalculatorState({
    @Default(0) int mode,                     // 0=기간, 1=날짜계산, 2=D-Day
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(false) bool includeStartDay,
    required DateTime calcBase,
    @Default('100') String calcNumberInput,   // 키패드 입력 버퍼 (문자열)
    @Default(0) int calcDirection,            // 0=더하기, 1=빼기
    @Default(0) int calcUnit,                 // 0=일, 1=주, 2=월, 3=년
    required DateTime ddayTarget,
    required DateTime ddayReference,
    @Default(true) bool ddayRefIsToday,
  }) = _DateCalculatorState;
}
```

---

## 2. Domain: DateCalculateUseCase

### Result 타입

| 타입 | 용도 |
|------|------|
| `PeriodResult` | 기간 계산 결과 (총 일수, 주+일, 월+일, 년+월+일) |
| `DDayResult` | D-Day 결과 (부호 포함 일수, 주+일, 월+일) |

### 메서드

| 메서드 | 입력 | 출력 |
|--------|------|------|
| `calculatePeriod(start, end, includeStartDay)` | DateTime×2, bool | PeriodResult |
| `calculateDate(base, number, unit, direction)` | DateTime, int×3 | DateTime |
| `calculateDDay(target, reference)` | DateTime×2 | DDayResult |

### 계산 규칙

**기간 계산**:
- `start > end` 허용 → 내부 swap 후 절댓값
- `totalDays = to.difference(from).inDays + (includeStartDay ? 1 : 0)`
- 주+일: `totalDays ~/ 7` / `totalDays % 7`
- 개월: 달력 기준 (`_fullMonths`) → 나머지 일수
- 연+월+일: 달력 기준 계층 분해

**날짜 계산**:
- unit=0 (일): `base.add(Duration(days: ±n))`
- unit=1 (주): `base.add(Duration(days: ±n * 7))`
- unit=2 (월): `_addMonths(base, ±n)` — 말일 초과 시 마지막 날 클램프
- unit=3 (년): `_addMonths(base, ±n * 12)`

**D-Day**:
- `totalDays = target.difference(reference).inDays`
- 양수=미래, 음수=과거, 0=당일
- 주+일 / 월+일: abs 기반 달력 계산

---

## 3. Presentation: ViewModel

### sealed Intent 11종

```
modeChanged            periodStartChanged     periodEndChanged
includeStartDayToggled calcBaseChanged        keyPressed
calcDirectionChanged   calcUnitChanged        numberStepped
ddayTargetChanged      ddayReferenceChanged
```

### 초기값 (build())
- `periodStart` = 오늘, `periodEnd` = 오늘+30일
- `calcBase` = 오늘, `calcNumberInput` = '100'
- `ddayTarget` = 오늘+100일, `ddayReference` = 오늘

### 키 입력 규칙 (`_handleKey`)
- `'0'` 상태에서 숫자 입력 → 교체 (선행 0 방지)
- 결과값 > 9999이면 입력 무시
- `'⌫'` → 한 자리 제거, 1자리면 `'0'`
- `'+/-'` → `calcDirection` 토글 (0↔1), `calcNumberInput` 변경 없음
- `numberStepped(delta)` → `calcNumber + delta`, 0~9999 클램프

### Computed getters
- `periodResult` — PeriodResult
- `calcResult` — DateTime
- `ddayResult` — DDayResult
- `calcNumber` — `int.tryParse(calcNumberInput) ?? 0`

---

## 4. Presentation: Screen

### 테마 컬러

| 상수 | 값 | 용도 |
|------|-----|------|
| `_bg1` | `0xFFFBF0F0` | 배경 그라디언트 상단 |
| `_bg2` | `0xFFF5E2E2` | 배경 그라디언트 중간 |
| `_bg3` | `0xFFEDD1D1` | 배경 그라디언트 하단 |
| `_accent` | `0xFF9E4A50` | 액센트 (결과값, 요일, 활성 상태) |
| `_textPrimary` | `0xFF4A2030` | 주 텍스트 (진한 와인 로즈) |
| `_textSecondary` | `0xFF7A4455` | 보조 텍스트 (웜 모브 로즈) |
| `_textTertiary` | `0xFFB08898` | 힌트/비활성 텍스트 (소프트 더스티 로즈) |
| `_divider` | `0xFFE2C4CC` | 구분선 (매우 연한 로즈) |
| 키패드 배경 | `white 22%` + BackdropFilter blur(20) | 유리 효과 |

### 날짜 피커

```dart
showDatePicker(
  builder: (context, child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF9E4A50),
        onPrimary: Colors.white,
        surface: Color(0xFFFBF0F0),
      ),
    ),
    child: child!,
  ),
)
```

### 탭바 애니메이션
- 탄성 스트레치: 왼쪽 엣지 easeInCubic, 오른쪽 엣지 easeOutCubic
- 배경 칩 글로우 + 언더라인 글로우 + 텍스트 스케일 (활성 +8%)

---

## 테스트 커버리지

| 그룹 | 케이스 수 |
|------|-----------|
| calculatePeriod — totalDays | 4 |
| calculatePeriod — weeks | 2 |
| calculatePeriod — months | 3 |
| calculatePeriod — years | 3 |
| calculateDate — 일 단위 | 2 |
| calculateDate — 주 단위 | 2 |
| calculateDate — 월 단위 | 4 |
| calculateDate — 년 단위 | 2 |
| calculateDDay | 6 |
| **합계** | **28** |
