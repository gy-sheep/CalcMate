# 리팩토링 체크리스트

> **작성일**: 2026-03-02
> **대상**: 환율 계산기 중심, 기본 계산기와의 공통화 포함
> **상태**: 진행 중

---

## 높음 우선순위

### R-01. 색상 상수 통합

- **브랜치**: `refactor/theme-colors`
- **현재 상태**: 환율·기본 계산기가 각각 Screen 파일 상단에 색상 로컬 정의
  - `currency_calculator_screen.dart:55-61` — `_gradientTop`, `_gradientBottom`, `_colorNumber` 등
  - `basic_calculator_screen.dart:9-10` — 별도 그라디언트 색상
- **개선 방향**: `lib/core/theme/calculator_colors.dart` 생성, 계산기별 색상 프로필 정의
- **재사용 대상**: 모든 계산기 (13종)

---

### R-02. 키패드 위젯 공용화

- **브랜치**: `refactor/common-keypad`
- **현재 상태**: 동일 구조의 키패드 위젯이 양쪽에 별도 구현 (45줄+ 중복)
  - 환율: `_NumberPad` + `_KeypadButton` (`currency_calculator_screen.dart:534-648`)
  - 기본: `_CalculatorKeypad` + `_CalcButton` (`basic_calculator_screen.dart:278-`)
  - 구조 동일 (5×4 레이아웃, `_BtnType` enum, 색상 매핑), 마지막 행만 다름 (`00` vs `+/-`)
- **개선 방향**: `lib/presentation/common/widgets/calculator_keypad.dart` 생성
  - `CalcKeypadConfig` 클래스로 행/열 정의를 외부에서 주입
  - 공용 `CalcButton` 위젯
- **재사용 대상**: 모든 키패드 사용 계산기

---

### R-03. Intent 패턴 통일 ✅

- **브랜치**: `refactor/sealed-intent`, `refactor/sealed-intent-v2`
- **완료**: 모든 Intent를 Sealed 클래스 + Factory 패턴으로 통일
  - 서브클래스 private 전환 (`_KeyTapped`, `_FromCurrencyChanged` 등)
  - Factory constructor 추가 (`ExchangeRateIntent.keyTapped()` 등)
  - Screen 호출부 Factory 방식으로 변경
  - `MainScreenIntent` 서브클래스 `implements` → `extends` 통일

---

### R-04. 에러 처리 강화 ✅

- **브랜치**: `refactor/error-handling`
- **완료**:
  - `lib/core/constants/error_messages.dart` — 에러 메시지 상수화 (`ErrorMessages`)
  - `lib/domain/exceptions/app_exceptions.dart` — `AppException` sealed class 계층 (`NetworkException`, `CacheException`, `DataNotFoundException`)
  - `error_interceptor.dart` — 하드코딩 메시지 → `ErrorMessages` 상수 참조
  - `exchange_rate_repository_impl.dart` — `Exception` → `DataNotFoundException`, catch에 `debugPrint` 추가
  - `exchange_rate_local_datasource.dart` — catch에 `debugPrint` 추가
  - `currency_calculator_viewmodel.dart` — 하드코딩 메시지 → `ErrorMessages` 상수, catch에 `debugPrint` 추가

---

## 중간 우선순위

### R-05. 입력 유틸리티 공용화 ✅

- **브랜치**: `refactor/input-utils`
- **완료**:
  - `lib/domain/utils/calculator_input_utils.dart` — `CalculatorInputUtils` 클래스 생성
  - `endsWithOperator()`, `lastNumberSegment()`, `resolvePercent()` 3개 메서드 공용화 (`formatResult`, `addCommas`는 R-09에서 `NumberFormatter`로 이동)
  - `currency_calculator_viewmodel.dart` — 중복 메서드 제거 (`_formatAmount`는 R-09에서 `NumberFormatter`로 이동)
  - `basic_calculator_viewmodel.dart` — 중복 4개 메서드 제거
- **재사용 대상**: 수식 입력이 있는 모든 계산기

---

### R-06. 자릿수 제한 정책 통일

- **브랜치**: `refactor/input-limit-policy`
- **현재 상태**:
  - 환율: 정수 12자리, 소수 8자리 제한 + 토스트 안내 (`viewmodel.dart:282-298`)
  - 기본: 제한 없음 (오버플로우 위험)
- **개선 방향**: 공용 `InputLimitPolicy` 클래스 도입, 기본 계산기에도 적용
- **재사용 대상**: 모든 키패드 입력 계산기

---

### R-07. 캐시 TTL / Firestore 경로 상수화 ✅

- **브랜치**: `refactor/config-constants`
- **완료**:
  - `lib/core/constants/cache_config.dart` — `CacheConfig.exchangeRateCacheKey`, `exchangeRateTtlMs`
  - `lib/core/constants/firebase_config.dart` — `FirebaseConfig.exchangeRateCollection`, `exchangeRateDocument`
  - `exchange_rate_local_datasource.dart` — 로컬 상수 → `CacheConfig` 참조
  - `exchange_rate_remote_datasource.dart` — 로컬 상수 → `FirebaseConfig` 참조

---

## 낮음 우선순위

### R-08. Toast 공용 컴포넌트 ✅

- **브랜치**: `dev`
- **완료**:
  - `lib/core/utils/app_toast.dart` — `showAppToast(context, message)` 공용 함수
  - 전체 계산기 Screen에서 중복 `_showToast` 제거 → `showAppToast` 사용

---

### R-12. 스크롤 페이드 그라디언트 공통화 ✅

- **브랜치**: `dev`
- **완료**:
  - `lib/presentation/widgets/scroll_fade_view.dart` — `ScrollFadeView` 위젯 (동적 스크롤 감지, GlobalKey 지원)
  - `lib/presentation/widgets/app_animated_tab_bar.dart` — `AppAnimatedTabBar` 공용 탭바
  - 전체 계산기(환율·날짜·나이·할인·더치페이)에 동적 스크롤 페이드 적용 (height: 48, stops: [0, 0.6, 1])
  - `DutchPayTabBar`, `DateTabBar` → `AppAnimatedTabBar` 래퍼로 단순화

---

### R-09. 숫자 포맷팅 유틸리티 ✅

- **브랜치**: `refactor/number-formatter`
- **완료**:
  - `lib/domain/utils/number_formatter.dart` — `NumberFormatter` 클래스 생성
  - 빌딩 블록: `addCommas`, `trimTrailingZeros`, `formatScientific`, `rawFromDouble`
  - 결과 포맷터: `formatResult`, `formatAmount`, `formatUnitResult`, `formatTemperature`, `formatInput`
  - `CalculatorInputUtils`에서 `formatResult()`, `addCommas()` 제거 → `NumberFormatter`로 이동
  - `CurrencyCalculatorViewModel`에서 `_formatAmount()` 제거 → `NumberFormatter.formatAmount()` 사용
  - `UnitConverterViewModel`에서 7개 private 포맷팅 메서드 제거 → `NumberFormatter` 사용
  - `BasicCalculatorViewModel` — `NumberFormatter.formatResult()` 사용으로 변경
- **재사용 대상**: 단위변환, 부가세 등 숫자 표시가 필요한 계산기

---

### R-10. UI 매직넘버 상수화

- **브랜치**: `refactor/ui-constants`
- **현재 상태**: 토스트 지연(1500ms), 키패드 버튼 높이(68), BottomSheet 비율(0.6), 새로고침 최소 시간(800ms) 등 하드코딩
- **개선 방향**: `lib/core/constants/ui_constants.dart`로 분리

---

### R-11. 통화 목록 외부화 ✅

- **브랜치**: `refactor/currency-data`
- **완료**: `CurrencyInfo` 클래스 + `kSupportedCurrencies` 상수를 `lib/domain/models/currency_info.dart`로 분리
  - Screen 파일에서 클래스 정의(13-23행) 및 하드코딩 목록(25-50행) 제거
  - import 추가 후 `_currencyList` → `kSupportedCurrencies`로 변경

---

## 진행 기록

| 날짜 | 항목 | 상태 |
|------|------|------|
| 2026-03-02 | R-03. Intent 패턴 통일 | 완료 |
| 2026-03-02 | R-11. 통화 목록 외부화 | 완료 |
| 2026-03-02 | R-04. 에러 처리 강화 | 완료 |
| 2026-03-03 | R-03. Intent 패턴 통일 (MainScreenIntent 보완) | 완료 |
| 2026-03-03 | R-07. 캐시 TTL / Firestore 경로 상수화 | 완료 |
| 2026-03-03 | R-05. 입력 유틸리티 공용화 | 완료 |
| 2026-03-03 | R-09. 숫자 포맷팅 유틸리티 | 완료 |
| 2026-03-07 | R-08. Toast 공용 컴포넌트 | 완료 |
| 2026-03-07 | R-12. 스크롤 페이드 그라디언트 공통화 + AppAnimatedTabBar | 완료 |
