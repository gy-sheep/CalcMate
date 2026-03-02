# 리팩토링 체크리스트

> **작성일**: 2026-03-02
> **대상**: 환율 계산기 중심, 기본 계산기와의 공통화 포함
> **상태**: 미착수

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

### R-03. Intent 패턴 통일

- **브랜치**: `refactor/sealed-intent`
- **현재 상태**: 계산기마다 Intent 정의 방식이 다름
  - 기본: Sealed 클래스 + Factory 패턴 (`CalculatorIntent`)
  - 환율: 일반 클래스 상속 (`ExchangeRateIntent`)
- **개선 방향**: 환율 Intent를 Sealed 클래스 방식으로 통일
- **재사용 대상**: 모든 계산기 ViewModel

---

### R-04. 에러 처리 강화

- **브랜치**: `refactor/error-handling`
- **현재 상태**:
  - 에러 메시지 하드코딩 (`currency_calculator_viewmodel.dart:208` — `'환율 정보를 불러올 수 없습니다'`)
  - `_refreshRates()`에서 예외 무시 (catch 블록 비어있음, `viewmodel.dart:179`)
  - 예외 로깅 없음
- **개선 방향**:
  - `lib/core/constants/error_messages.dart` — 에러 메시지 상수화
  - `lib/domain/exceptions/` — 예외 클래스 정의 (`NetworkException`, `CacheException`)
  - catch 블록에 로깅 추가

---

## 중간 우선순위

### R-05. 입력 유틸리티 공용화

- **브랜치**: `refactor/input-utils`
- **현재 상태**: 아래 메서드들이 양쪽 ViewModel에 동일하게 구현됨
  - `_endsWithOperator()` — 환율 `viewmodel.dart:337`, 기본 `viewmodel.dart:280`
  - `_lastNumberSegment()` — 환율 `viewmodel.dart:343`, 기본 `viewmodel.dart:286`
  - `_resolvePercent()` — 환율 `viewmodel.dart:355`, 기본 `viewmodel.dart:302`
  - `_addCommas()` — 환율 `viewmodel.dart:394`, 기본 `screen.dart`에서 유사 구현
- **개선 방향**: `lib/domain/utils/calculator_input_utils.dart`로 추출
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

### R-07. 캐시 TTL / Firestore 경로 상수화

- **브랜치**: `refactor/config-constants`
- **현재 상태**:
  - 캐시 TTL: `exchange_rate_local_datasource.dart:9` — `_ttlMs = 3600000`
  - Firestore 경로: `exchange_rate_remote_datasource.dart:8-9` — `_collection`, `_document`
- **개선 방향**: `lib/core/constants/cache_config.dart`, `firebase_config.dart`로 분리

---

## 낮음 우선순위

### R-08. Toast 공용 컴포넌트

- **브랜치**: `refactor/common-toast`
- **현재 상태**: 2개의 다른 Toast 구현
  - `_showToast()` — Screen, bottom 위치, 1500ms (`screen.dart:86-114`)
  - `_showCenterToast()` — PickerSheet, center 위치, 1000ms (`screen.dart:674-697`)
- **개선 방향**: `lib/presentation/common/widgets/app_toast.dart` — 위치·지연 파라미터화
- **재사용 대상**: 앱 전체

---

### R-09. 숫자 포맷팅 유틸리티

- **브랜치**: `refactor/number-formatter`
- **현재 상태**: `_formatAmount()`, `_formatResult()`, `_addCommas()`가 ViewModel에 산재
- **개선 방향**: `lib/domain/utils/number_formatter.dart`로 통합
- **재사용 대상**: 단위변환, 부가세 등 숫자 표시가 필요한 계산기

---

### R-10. UI 매직넘버 상수화

- **브랜치**: `refactor/ui-constants`
- **현재 상태**: 토스트 지연(1500ms), 키패드 버튼 높이(68), BottomSheet 비율(0.6), 새로고침 최소 시간(800ms) 등 하드코딩
- **개선 방향**: `lib/core/constants/ui_constants.dart`로 분리

---

### R-11. 통화 목록 외부화

- **브랜치**: `refactor/currency-data`
- **현재 상태**: 24개 `CurrencyInfo` 리스트가 Screen 파일에 하드코딩 (`screen.dart:25-50`)
- **개선 방향**: 향후 다국어 대응 시 JSON 파일 분리 (현재는 낮은 우선순위)

---

## 진행 기록

| 날짜 | 항목 | 상태 |
|------|------|------|
| — | — | — |
