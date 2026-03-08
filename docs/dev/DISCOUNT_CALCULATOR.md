# 할인 계산기 구현 명세

> **브랜치**: `feat/discount-calculator`
> **목적**: UI 프로토타입(StatefulWidget 인라인 로직)을 Clean Architecture(State/UseCase/ViewModel)로 전환

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `lib/domain/models/discount_calculator_state.dart` | 신규 — Freezed 상태 모델 |
| `lib/domain/models/discount_calculator_state.freezed.dart` | 자동생성 (build_runner) |
| `lib/domain/usecases/calculate_discount_usecase.dart` | 신규 — 순수 계산 로직 |
| `test/domain/usecases/calculate_discount_usecase_test.dart` | 신규 — UseCase 단위 테스트 |
| `lib/presentation/discount_calculator/discount_calculator_viewmodel.dart` | 신규 — Intent + ViewModel |
| `lib/presentation/discount_calculator/discount_calculator_screen.dart` | 수정 — ConsumerStatefulWidget 전환 |

**데이터 흐름**

```
User 탭/키패드
      │
      ▼
DiscountCalculatorScreen
      │ handleIntent(intent)
      ▼
DiscountCalculatorViewModel (AutoDisposeNotifier)
      │ state.copyWith(...)
      │ _useCase.calculate(...)  ← computed getter
      ▼
DiscountCalculatorState (Freezed)   CalculateDiscountUseCase
      │                                     │
      ▼                                     ▼
ref.watch() → rebuild              DiscountResult (순수 계산값)
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| 화면 파일에 계산 로직이 인라인으로 섞여 있음 | 테스트 불가, 재사용 불가 |
| `StatefulWidget`으로 상태 직접 관리 | Riverpod DI 혜택 없음 |
| `_getCurrencySymbol()`가 화면 파일 최상단 전역 함수 | 이동 불필요 — 화면 로컬 헬퍼로 유지 |

---

## 목표

- 계산 로직을 `CalculateDiscountUseCase`로 격리하여 단위 테스트 가능
- 상태를 `DiscountCalculatorState`(Freezed)로 불변 관리
- 화면은 상태 표시와 Intent 전달만 담당

---

## 구현 범위

### 1. `lib/domain/models/discount_calculator_state.dart` — Freezed 상태

**주요 구성 요소**

- `ActiveField` enum: `originalPrice`, `discountRate`, `extraDiscountRate`
  - 현재 포커스된 입력 필드를 나타냄. 키패드 동작과 필드 강조에 사용.
- `DiscountCalculatorState`:
  - `originalPrice` (String): 쉼표 포함 포맷된 원가 문자열 (예: `"50,000"`)
  - `discountRate` (String): 할인율 문자열 (예: `"30"`, `"12.5"`)
  - `showExtra` (bool): 추가 할인 입력란 표시 여부
  - `extraRate` (String): 추가 할인율 문자열
  - `selectedChip` (int?): 기본 할인율 칩 선택 인덱스 (null = 없음)
  - `selectedExtraChip` (int?): 추가 할인율 칩 선택 인덱스
  - `activeField` (ActiveField): 현재 활성 입력 필드

---

### 2. `lib/domain/usecases/calculate_discount_usecase.dart` — 순수 계산

**DiscountResult**

| 필드 | 타입 | 설명 |
|------|------|------|
| `hasResult` | bool | 원가 > 0 && 할인율 > 0일 때 true |
| `originalPrice` | double | 파싱된 원가 |
| `finalPrice` | double | 최종가 (할인 적용) |
| `savedAmount` | double | 할인 금액 |
| `effectiveRate` | double | 실질 할인율 % |

**CalculateDiscountUseCase.calculate()**

파라미터: `originalPrice` (String), `discountRate` (String), `extraRate` (String), `showExtra` (bool)

계산 로직:
```
price  = double.tryParse(originalPrice.replaceAll(',', '')) ?? 0
rate   = double.tryParse(discountRate) ?? 0
extra  = double.tryParse(extraRate) ?? 0

hasResult = price > 0 && rate > 0

finalPrice = price × (1 - rate/100)
if (showExtra && extra > 0) finalPrice × (1 - extra/100)

savedAmount   = price - finalPrice
effectiveRate = savedAmount / price × 100
```

**formatPrice() 헬퍼 (UseCase 내 static)**

```dart
static String formatPrice(double value) {
  // 천 단위 쉼표 포맷 (소수점 버림)
}
```

> 화면에서도 동일하게 사용할 수 있도록 static으로 공개.

---

### 3. `lib/presentation/discount_calculator/discount_calculator_viewmodel.dart` — Intent + ViewModel

**DiscountCalculatorIntent (sealed)**

| Intent | 파라미터 | 동작 |
|--------|---------|------|
| `keyPressed(String key)` | key | 활성 필드에 키 적용 |
| `chipSelected(int index, {bool isExtra})` | index, isExtra | 칩 선택 → 해당 필드 값 세팅 |
| `fieldTapped(ActiveField field)` | field | 활성 필드 변경 |
| `toggleExtraDiscount()` | — | 추가 할인 토글 (show/hide + 값 초기화) |

**DiscountCalculatorViewModel**

- `build()`: 초기 상태 반환
- `handleIntent(intent)`: switch로 Intent 처리
- computed getter `result`: `_useCase.calculate(state...)` 호출

**키 처리 규칙 (`_applyKey`)**

| 키 | 원가 필드 | 할인율 필드 |
|----|---------|-----------|
| 숫자 | 쉼표 제거 후 정수 파싱, 최대 9,999,999,999 | double 파싱, 100 미만만 허용 |
| `.` | 무시 (정수만) | 소수점 1개만 허용 |
| `00` | 빈 값이면 무시, 아니면 `00` 추가 | 동일 |
| `⌫` | 마지막 문자 삭제 | 마지막 문자 삭제 |
| `AC` | 필드 전체 초기화 | 필드 전체 초기화 |

> `_formatInputPrice`: 원가 입력 시 쉼표 포맷 재적용 (ViewModel 내 private 헬퍼)

---

### 4. `lib/presentation/discount_calculator/discount_calculator_screen.dart` — 화면

**전환 내용**

- `StatefulWidget` → `ConsumerStatefulWidget`
- `_DiscountCalculatorScreenState` 내 계산 getter/로직 → 삭제 (ViewModel로 이동)
- `_getCurrencySymbol()` — 화면 파일 최상단 전역 함수로 **유지** (이동 불필요)
- 상태 참조: `ref.watch(discountCalculatorViewModelProvider)`
- Intent 발송: `ref.read(...notifier).handleIntent(...)`

---

## 구현 순서

```
1. DiscountCalculatorState (Freezed)
   └─ ActiveField enum 포함
   └─ build_runner 실행

2. CalculateDiscountUseCase + DiscountResult
   └─ test/domain/usecases/calculate_discount_usecase_test.dart 먼저 작성 (TDD)
   └─ 테스트 케이스: 기본 할인, 중첩 할인, 엣지 케이스

3. DiscountCalculatorViewModel
   └─ sealed Intent 정의
   └─ handleIntent 구현

4. Screen 전환
   └─ StatefulWidget → ConsumerStatefulWidget
   └─ 인라인 로직 제거, ViewModel 연결
   └─ 로컬 state 제거 (activeField 등 모두 ViewModel로)
```

---

## 범위 외 (이번 작업 제외)

- 3단계 중첩 할인 — 스펙에는 있으나 UI 프로토타입이 2단계까지만 구현되어 있어 이번 작업도 2단계로 유지
- 키패드 소수점/00 버튼 동적 활성화 시각 처리 — 현재 UI 프로토타입에 없음
