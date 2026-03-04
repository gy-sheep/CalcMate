# 나이 계산기 구현 명세

> **브랜치**: `feat/age-calculator`
> **목적**: 음력 변환 기능 구현 및 AgeCalculateUseCase 테스트 작성

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `lib/domain/usecases/lunar_converter.dart` | [신규] 음력↔양력 변환 래퍼 |
| `lib/domain/models/age_calculator_state.dart` | [수정] `convertedSolarDate` 필드 추가 |
| `lib/domain/usecases/age_calculate_usecase.dart` | [수정] 음력 모드 나이 계산 반영 |
| `lib/presentation/age_calculator/age_calculator_viewmodel.dart` | [수정] 음력 모드 ViewModel 로직 |
| `lib/presentation/age_calculator/age_calculator_screen.dart` | [수정] ConsumerStatefulWidget, 레이아웃만 |
| `lib/presentation/age_calculator/age_calculator_colors.dart` | [신규] 나이 계산기 전용 색상 상수 |
| `lib/presentation/age_calculator/widgets/app_bar_row.dart` | [신규] AppBar 행 |
| `lib/presentation/age_calculator/widgets/picker_section.dart` | [신규] 피커 영역 (연/월/일 + 음력 토글) |
| `lib/presentation/age_calculator/widgets/picker.dart` | [신규] ListWheelScrollView 개별 피커 |
| `lib/presentation/age_calculator/widgets/lunar_info.dart` | [신규] 음력 모드: 변환 날짜 + 윤달 체크 |
| `lib/presentation/age_calculator/widgets/empty_state.dart` | [신규] 초기 상태 UI |
| `lib/presentation/age_calculator/widgets/result_scroll_view.dart` | [신규] 결과 카드 스크롤 영역 |
| `lib/presentation/age_calculator/widgets/age_card.dart` | [신규] 세는 나이 메인 카드 |
| `lib/presentation/age_calculator/widgets/age_info_card.dart` | [신규] 정보 행 (만 나이/연 나이/요일) |
| `lib/presentation/age_calculator/widgets/zodiac_card.dart` | [신규] 띠 카드 |
| `lib/presentation/age_calculator/widgets/constellation_card.dart` | [신규] 별자리 카드 |
| `lib/presentation/age_calculator/widgets/days_lived_card.dart` | [신규] 살아온 날 카드 |
| `lib/presentation/age_calculator/widgets/next_birthday_card.dart` | [신규] 다음 생일 D-day 카드 |
| `test/domain/usecases/age_calculate_usecase_test.dart` | [신규] UseCase 단위 테스트 |

**데이터 흐름**

```
[Screen] 피커 스크롤 (음력 연·월·일 + 윤달 체크)
    │
    ▼
[ViewModel] handleIntent()
    │  LunarConverter.lunarToSolar(year, month, day, isLeap)
    │  → convertedSolarDate: DateTime
    │  LunarConverter.leapMonthOf(year, month) → bool (윤달 활성 여부)
    │  LunarConverter.daysInLunarMonth(year, month, isLeap) → int (피커 일수)
    │
    ▼
[State] AgeCalculatorState
    ├── year, month, day, isLeapMonth  ← 음력 입력값
    └── convertedSolarDate: DateTime?  ← 변환된 양력 날짜 (음력 모드에만 존재)
    │
    ▼
[ViewModel.ageResult]
    │  birthDate = calendarType == solar ? DateTime(year,month,day)
    │                                    : convertedSolarDate
    │
    ▼
[AgeCalculateUseCase] execute(birthDate, today)
    │
    ▼
[AgeResult] → Screen 카드 렌더링
```

---

## 배경 및 문제

현재 음력 모드는 "다음 업데이트에 지원됩니다" 안내만 표시하고 양력과 동일하게 계산된다.

| 문제 | 영향 |
|------|------|
| 음력→양력 변환 미구현 | 음력 생년월일 입력 시 잘못된 나이 계산 |
| 윤달 여부 판단 로직 없음 | 윤달 체크박스 비활성 상태로 고정 |
| 음력 월별 일수 계산 없음 | 음력 피커가 항상 양력 일수 표시 |
| 변환된 양력 날짜 미표시 | 스펙의 "양력 YYYY년 MM월 DD일" 안내 없음 |

---

## 목표

- 음력 생년월일을 입력하면 정확한 양력 날짜로 변환하여 나이 계산
- 해당 연·월에 윤달이 있는 경우에만 윤달 체크박스 활성화
- 음력 피커의 일 범위를 해당 음력 달의 실제 일수(29/30일)로 동적 조정
- 음력 모드에서 변환된 양력 날짜를 피커 하단에 실시간 표시
- AgeCalculateUseCase 단위 테스트 작성

---

## 구현 범위

### 1. `lib/domain/usecases/lunar_converter.dart` — 음력 변환 래퍼

`korean_lunar_utils` 패키지를 Domain 계층에서 직접 의존하지 않도록 래핑.
패키지 교체 시 이 파일만 수정하면 된다.

**주요 구성 요소**

- `LunarConverter.toSolar(year, month, day, isLeap)`: 음력→양력 변환. 범위 초과 시 null 반환
- `LunarConverter.leapMonthOf(lunarYear, lunarMonth)`: 해당 연·월이 윤달인지 여부
- `LunarConverter.daysInMonth(lunarYear, lunarMonth, isLeap)`: 해당 음력 달의 일수 (29 or 30)

**설계 결정**

- 정적 메서드로 구성: 상태 없는 변환 유틸리티이므로 인스턴스 불필요
- 예외 → null 반환: 범위 초과(1900 이전, 2049 이후) 시 RangeError를 catch하여 null 반환, ViewModel에서 처리

---

### 2. `lib/domain/models/age_calculator_state.dart` — State 확장

음력 모드에서 변환된 양력 날짜를 State에 보관한다.

**주요 구성 요소**

- `convertedSolarDate: DateTime?`: 음력 모드에서만 값을 가짐. 양력 모드에서는 null

**설계 결정**

- State에 보관하는 이유: ViewModel의 `ageResult` getter와 Screen의 날짜 표시가 모두 이 값을 참조. 매번 재계산하지 않기 위해 State에 캐싱

---

### 3. `lib/presentation/age_calculator/age_calculator_viewmodel.dart` — ViewModel 수정

**주요 변경 사항**

- `handleIntent(_YearChanged | _MonthChanged | _DayChanged | _LeapMonthToggled)`: 음력 모드일 때 `LunarConverter.toSolar()` 호출 후 `convertedSolarDate` 갱신
- `ageResult` getter: `calendarType == lunar`이면 `convertedSolarDate`를 `birthDate`로 사용
- `maxDaysForCurrentMonth()`: 음력 모드이면 `LunarConverter.daysInMonth()` 반환
- `hasLeapMonth`: 현재 연·월에 윤달이 있는지 여부 (Screen의 윤달 체크박스 활성화 조건)

---

### 4. `lib/presentation/age_calculator/age_calculator_screen.dart` — 음력 UI

**주요 변경 사항**

- `_LunarInfo` 위젯: 기존 "지원 예정" 안내 → 변환된 양력 날짜 표시 + 윤달 체크박스
- `_PickerSection`: 음력 모드에서 일 피커의 `itemCount`를 `vm.maxDaysForCurrentMonth()` 기준으로 동적 설정
- 윤달 체크박스: `vm.hasLeapMonth`가 true일 때만 활성화 표시, false면 dimmed

---

### 5. `test/domain/usecases/age_calculate_usecase_test.dart` — 테스트

**테스트 케이스 (예정)**

| 케이스 | 검증 항목 |
|--------|-----------|
| 생일이 지난 경우 | 만 나이 = 올해 - 출생연도 |
| 생일이 안 지난 경우 | 만 나이 = 올해 - 출생연도 - 1 |
| 오늘이 생일 | 만 나이 정상, isBirthdayToday = true |
| 세는 나이 | 올해 - 출생연도 + 1 |
| 연 나이 | 올해 - 출생연도 |
| 윤년 2/29 생일 | 비윤년 다음 생일 → 3/1 처리 |
| 설날 기준 띠 보정 | 양력 1~2월 생, 설날 이전 → 전년도 띠 |
| 살아온 날 | 출생일~오늘 일수 |
| 다음 생일 D-day | 정확한 일수 |

---

## 구현 순서

```
1. LunarConverter 작성 (도메인 래퍼)
   └─ toSolar / leapMonthOf / daysInMonth

2. AgeCalculatorState 수정
   └─ convertedSolarDate: DateTime? 필드 추가
   └─ build_runner codegen

3. AgeCalculatorViewModel 수정
   └─ 음력 모드 변환 로직 (각 Intent 핸들러)
   └─ maxDaysForCurrentMonth(), hasLeapMonth getter

4. AgeCalculatorScreen 수정
   └─ _LunarInfo: 변환된 날짜 표시 + 윤달 체크박스
   └─ 일 피커 itemCount 동적 처리

5. AgeCalculateUseCase 테스트 작성
```

---

## 범위 외 (이번 작업 제외)

- 음력 다음 생일 D-day 음력 기준 계산 — 스펙에 명시되어 있으나 변환 정확도 검증 후 별도 진행
- 2050년 이후 범위 지원 — `korean_lunar_utils` 패키지 제한 (1900~2049)
