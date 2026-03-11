# CalcMate l10n 전환 작업 계획서

## Context

Phase 12 출시 준비 항목 중 `언어 설정 실제 l10n 전환`을 진행한다.
현재 앱 전체에 **400+ 하드코딩 한국어 문자열**이 산재해 있고, 설정 화면의 언어 선택은 UI만 구현된 상태.
우선 **ko/en 2개 언어**로 인프라와 전환을 완성하고, zh/ja는 이후 별도 Phase로 분리한다.
한국 전용 기능(실수령액 공제항목, 나이 음력/띠)은 **번역만 하고** 숨기지 않는다 (e.g., `National Pension`, `Lunar calendar`).

---

## 문자열 현황 (400+개, 38개 파일)

| 영역 | 파일 | 문자열 수 | 특성 |
|------|------|----------|------|
| 단위 이름/카테고리 | `core/constants/unit_definitions.dart` | 73+10 | 데이터성, Map 구조 |
| 더치페이 | `dutch_pay/` 하위 6파일 | ~58 | UI + 공유 시트 |
| 부가세 | `vat_calculator/` 하위 파일 | ~35 | UI + 국가별 세율 |
| 설정/메인 | `settings/` 3파일 + `main/` | ~31 | UI |
| 날짜 계산기 | `date_calculator/` 하위 5파일 | ~25 | UI + 포맷 헬퍼 |
| 통화 이름 | `domain/models/currency_info.dart` | 24 | 데이터성 |
| 나이 계산기 | `domain/usecases/age_calculate_usecase.dart` | ~20 | 띠/별자리/요일 |
| 계산기 타이틀/설명 | `core/config/calc_mode_config.dart` | 20 | 메인 카드 |
| 실수령액 | `salary_calculator/` 하위 4파일 | ~19 | UI + 공제 항목명 |
| 할인 | `discount_calculator/` 하위 4파일 | ~10 | UI |
| BMI | `bmi_calculator/` 하위 3파일 | ~12 | UI + 분류 라벨 |
| 환율 | `currency/` 하위 2파일 | ~5 | UI |
| 에러 메시지 | `core/constants/error_messages.dart` | 6 | 공통 |
| 기타 | `ad_banner_placeholder`, `number_keypad`, `splash` | ~5 | 공통 |

---

## Phase 1: 인프라 구축

**목표**: gen-l10n 설정 + Riverpod 로케일 관리 + 설정 화면 연동

### 1-1. gen-l10n 설정

**신규 파일**: `l10n.yaml`
```yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

**신규 파일**: `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`
- 설정 화면 문자열 ~25개로 시작 (키 네이밍: `{screen}_{element}_{detail}`)

**수정**: `pubspec.yaml`
- `flutter:` 아래 `generate: true` 추가
- `dependencies`에 `intl: any` 추가 (flutter_localizations는 이미 있음)

### 1-2. Riverpod 로케일 Provider

**수정**: `lib/presentation/settings/settings_viewmodel.dart`
- `SettingsState`에 `Locale? locale` 필드 추가 (null = 시스템 기본)
- `SettingsIntent.localeChanged(Locale?)` 추가
- SharedPreferences `'locale'` 키로 저장/복원

```dart
// ── State ──
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    Locale? locale, // null = 시스템 기본
  }) = _SettingsState;
}
```

### 1-3. MaterialApp 연결

**수정**: `lib/main.dart`
```dart
// 변경 전
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [Locale('ko'), Locale('en')],
localeResolutionCallback: (locale, supportedLocales) => locale,

// 변경 후
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

locale: ref.watch(settingsViewModelProvider).locale,
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

### 1-4. 설정 화면 연동

**수정**: `lib/presentation/settings/settings_screen.dart`
- `_LanguageSheet` 하드코딩 → `Locale` 기반 + Intent 연결
  - 현재: `static const _languages = ['한국어', 'English', '中文', '日本語']`
  - 변경: ko/en 2개 + '시스템 기본' 옵션, 선택 시 `SettingsIntent.localeChanged` 호출
- 설정 화면 하드코딩 문자열 → `AppLocalizations.of(context)` 교체

**수정**: `lib/presentation/settings/calculator_management_screen.dart`
- `'계산기 관리'`, `'메인 화면에 표시할 계산기를 선택하세요.'`, `'전체 선택'`/`'전체 해제'` → l10n

**수정**: `lib/presentation/settings/open_source_licenses_screen.dart`
- `'오픈소스 라이선스'`, `'$count개의 라이선스'` → l10n

**검증**: 설정에서 English 선택 시 설정 화면 문자열이 영어로 전환

---

## Phase 2: Domain 계층 준비

**목표**: Domain의 하드코딩 문자열을 키/enum으로 전환 (Clean Architecture 유지)

### 2-1. NumberFormatter (`lib/domain/utils/number_formatter.dart`)
- L72: `'정의되지 않음'` → `kUndefinedResult` 상수 (`'__UNDEFINED__'`)
- Presentation에서 상수 감지 후 `AppLocalizations` 변환

### 2-2. DigitLimitPolicy (`lib/domain/utils/digit_limit_policy.dart`)
- 현재: `toastOnInteger`, `toastOnFractional` 에 한국어 문자열 직접 저장
  - L19: `'최대 12자리까지 입력 가능합니다'`
  - L20: `'소수점 이하 8자리까지 입력 가능합니다'`
- 변경: `check()` → `DigitCheckResult` enum 반환으로 변경
  ```dart
  enum DigitCheckResult { integerExceeded, fractionalExceeded, decimalNotAllowed }
  ```
- 4개 ViewModel에서 enum → `AppLocalizations` 변환:
  - `basic_calculator_viewmodel.dart`
  - `currency_calculator_viewmodel.dart`
  - `vat_calculator_viewmodel.dart`
  - `unit_converter_viewmodel.dart`

### 2-3. 에러 메시지 (`lib/core/constants/error_messages.dart`)
- 6개 상수 → `.arb` 키 기반 전환
  - `exchangeRateLoadFailed`, `exchangeRateUsingFallback`
  - `networkTimeout`, `networkUnavailable`, `serverError(code)`, `unknownError`

### 2-4. BMI 카테고리 (`lib/domain/usecases/bmi_calculate_usecase.dart`)
- `'저체중'`, `'정상 체중'`, `'과체중'`, `'비만'` 등 → enum/코드화
- 현재 `BmiCategory`에 한국어 `label`/`range` 문자열이 직접 들어있음
- Domain은 코드만 반환, Presentation에서 l10n 매핑

### 2-5. UseCase 내 한국어
- `evaluate_expression_usecase.dart` L99: `FormatException('숫자가 필요합니다')` — 내부 예외, 사용자 미노출이면 유지
- `convert_unit_usecase.dart` L12-13: `'온도'`, `'연비'` — 카테고리 코드로 비교 변경
- `age_calculate_usecase.dart`: 띠(12), 별자리(12), 요일(8) → `.arb`/DataStrings

**검증**: 기존 UseCase 테스트 통과 (문자열 비교 → enum/상수 비교)

---

## Phase 3: 데이터성 문자열 분리

**목표**: 단위 이름(83), 통화 이름(24), 계산기 타이틀(20) 번역 인프라

### 3-1. DataStrings 유틸 생성

**신규**: `lib/core/l10n/data_strings.dart`
- 로케일별 번역 Map
- `unitLabel(code, locale)` — 73개 단위
- `categoryName(code, locale)` — 10개 카테고리 (길이, 질량, 온도...)
- `currencyName(code, locale)` — 24개 통화

### 3-2. CalcModeEntry 타이틀/설명 (`lib/core/config/calc_mode_config.dart`)
- 10개 계산기 `title`/`description` → `.arb` 키 기반 조회
  ```
  calc_basicCalculator_title: "기본 계산기" / "Basic Calculator"
  calc_basicCalculator_description: "사칙연산 및 공학 계산" / "Arithmetic & scientific calculations"
  ```

### 3-3. Presentation 적용
- 단위 변환기: `DataStrings.unitLabel()` 사용
- 환율 피커: `DataStrings.currencyName()` 사용
- 메인 카드: `.arb`에서 타이틀/설명 조회

**검증**: 메인 카드·단위 변환기·환율 피커에서 영어 표시 확인

---

## Phase 4: 통화/숫자 포맷

**목표**: 로케일 인식 통화 포맷 도입

### 4-1. CurrencyFormatter 생성

**신규**: `lib/core/l10n/currency_formatter.dart`
- ko: `"12,500 원"` (접미사) / en: `"₩12,500"` (접두사)
- `intl` 패키지의 `NumberFormat.currency()` 활용

### 4-2. `원` 하드코딩 교체

`'원'` 하드코딩 위치 (전부 교체):
- `equal_split_view.dart`: L117, L280, L282, L291, L471, L501, L554
- `salary_display.dart`: L83, L91
- `result_card.dart` (salary): L62, L72
- `deduction_card.dart`: L58, L80
- `discount_calculator_screen.dart`: L21 (`'KR': '원'`)
- `dutch_pay_state.dart`: L10 (`'100원 단위'`, `'1,000원 단위'`)
- `result_bar_section.dart`: L50, L107

**검증**: 영어 전환 시 `₩12,500` 형태로 표시

---

## Phase 5: 화면별 문자열 전환

### 5-1. 설정/메인/스플래시 (~35개)

| 파일 | 문자열 |
|------|--------|
| `main_screen.dart` | `'순서 편집'`, `'완료'`, `'설정'` |
| `splash_screen.dart` | `'생활 속 모든 계산'` |
| `ad_banner_placeholder.dart` | `'광고'` |
| `number_keypad.dart` | `'확인'` (기본 confirmLabel) |

### 5-2. 더치페이 (~58개, 최대 규모)

| 파일 | 주요 문자열 |
|------|------------|
| `equal_split_view.dart` | `'총 금액'`, `'인원'`, `'정산 단위'`, `'팁 추가'`, `'직접입력'`, `'1인당'`, `'계산한 사람'`, `'결과 공유'` 등 |
| `participants_bar.dart` | `'최대 10명까지 추가할 수 있어요'`, `'최소 1명은 있어야 해요'`, 삭제 다이얼로그 |
| `result_bar_section.dart` | `'결과'`, `'합계'`, `'결과 공유'` |
| `dutch_pay_screen.dart` | `'더치페이'` |
| `dutch_pay_viewmodel.dart` | `'메뉴 ${s.items.length + 1}'` |
| `dutch_pay_state.dart` | `'100원 단위'`, `'1,000원 단위'` |

### 5-3. 부가세 + 실수령액 + 할인 (~60개)

| 파일 | 주요 문자열 |
|------|------------|
| `vat_calculator_viewmodel.dart` | `'오류'`, `'세율은 0~99% 범위로 입력하세요'` |
| `deduction_card.dart` | `'국민연금'`, `'건강보험'`, `'장기요양'`, `'고용보험'`, `'소득세'`, `'지방소득세'`, `'공제 합계'` |
| `salary_display.dart` | `'연봉'`, `'월급'` |
| `result_card.dart` (salary) | `'연 실수령'`, `'연 환산'`, `'실수령액'` |
| `discount_result_card.dart` | `'할인 금액'`, `'실질 할인율'`, `'최종가'` |
| `discount_rate_section.dart` | `'할인율'` |
| `extra_discount_section.dart` | `'추가 할인 제거'`, `'추가 할인'`, `'추가 할인율'` |
| `original_price_field.dart` | `'원가'` |

### 5-4. 날짜 + 나이 + BMI + 환율 (~60개)

| 파일 | 주요 문자열 |
|------|------------|
| `date_format_utils.dart` | 요일 배열, `'년'`, `'월'`, `'일'`, `'요일'` |
| `date_tab_bar.dart` | `'기간 계산'`, `'날짜 계산'`, `'D-Day'` |
| `dday_mode_view.dart` | `'목표 날짜'`, `'기준일'`, `'전'`/`'후'`, 주/개월 결과 |
| `period_mode_view.dart` | `'시작 날짜'`, `'종료 날짜'`, `'시작일 포함'`, 결과 문자열 |
| `date_calc_mode_view.dart` | `'기준 날짜'`, `'일/주/개월/년'`, `'이후'`/`'이전'` |
| `bmi_calculator_screen.dart` | `'키 입력'`, `'몸무게 입력'`, `'취소'`/`'확인'`, `'키'`/`'몸무게'`, WHO 기준 라벨 |
| `bmi_healthy_weight_card.dart` | `'건강 체중 범위'`, `'현재 체중이 건강 범위 안에 있습니다'` |
| `currency_picker_sheet.dart` | `'통화 검색 (USD, 달러...)'`, `'기준 통화로 사용 중입니다'`, `'이미 선택된 통화입니다'` |

**.arb 키 네이밍**: `{screen}_{element}_{detail}` (예: `dutchPay_label_totalAmount`)

---

## Phase 6: UI 레이아웃 대응

**목표**: 영어 텍스트 길이 차이로 인한 오버플로우 방어

- `FittedBox` / `Flexible` / `TextOverflow.ellipsis` 적용
- 날짜 포맷: `DateFormat`(intl) 로케일별 자동 적용
- 대상: 더치페이 `_Row`, 부가세 `ReceiptRow`, 실수령액 `DeductionCard`, 프리셋 칩 등

**검증**: ko/en 전환하며 전 화면 레이아웃 확인 (영어 기준 최장 텍스트)

---

## Phase 7: 테스트 및 마무리

- `CurrencyFormatter`, `DataStrings` 단위 테스트
- `.arb` 키 일관성 검증 (모든 arb 파일 키 수 동일)
- 기존 테스트 업데이트 (Domain 리팩토링 반영)
- `PROGRESS.md` 완료 처리

---

## 커밋 전략

| 순서 | Phase | 커밋 메시지 |
|------|-------|-----------|
| 1 | 1 | `feat: l10n 인프라 구축 (gen-l10n, Riverpod locale, 설정 연동)` |
| 2 | 2 | `refactor: Domain 계층 하드코딩 문자열 → 상수/enum 전환` |
| 3 | 3 | `feat: 데이터성 문자열 번역 맵 (단위/통화/카테고리)` |
| 4 | 4 | `feat: 로케일 인식 통화 포맷터 도입` |
| 5 | 5-1 | `feat: 설정/메인/스플래시 l10n 적용` |
| 6 | 5-2 | `feat: 더치페이 l10n 적용` |
| 7 | 5-3 | `feat: 부가세/실수령액/할인 l10n 적용` |
| 8 | 5-4 | `feat: 날짜/나이/BMI/환율 l10n 적용` |
| 9 | 6 | `fix: 다국어 UI 레이아웃 대응` |
| 10 | 7 | `test: l10n 테스트 추가 및 마무리` |

---

## 주의사항

1. **한국 전용 기능**: 번역만 진행, 숨기지 않음 (e.g., `National Pension`, `Lunar calendar`)
2. **const 손실**: `const Text('설정')` → `Text(l10n.settings_title)`로 `const` 제거됨 (성능 영향 미미)
3. **커밋 순서**: Phase 2(Domain) → Phase 5(화면) 순서 필수 (테스트 호환성)
4. **convert_unit_usecase 카테고리 비교**: `'온도'`/`'연비'` 문자열 비교를 코드 기반으로 변경 필수

---

## 향후 작업 (이번 범위 밖)

- zh/ja 번역: `app_zh.arb`, `app_ja.arb` 생성 + `DataStrings` zh/ja 맵 추가
- 한국 전용 기능 안내 문구 추가 (필요 시)
