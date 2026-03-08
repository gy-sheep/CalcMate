# BMI 계산기 구현 명세

> **브랜치**: `feat/bmi-calculator`
> **목적**: UI 프로토타입(StatefulWidget 인라인 로직)을 Clean Architecture(State/UseCase/ViewModel)로 전환하고, locale 자동 감지·단위 저장 기능 구현

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `lib/domain/models/bmi_calculator_state.dart` | 신규 — Freezed 상태 모델 |
| `lib/domain/models/bmi_calculator_state.freezed.dart` | 자동생성 (build_runner) |
| `lib/domain/usecases/bmi_calculate_usecase.dart` | 신규 — BMI 계산 + 범주 판정 + 건강 체중 역산 |
| `test/domain/usecases/bmi_calculate_usecase_test.dart` | 신규 — UseCase 단위 테스트 |
| `lib/presentation/bmi_calculator/bmi_calculator_viewmodel.dart` | 신규 — Intent + ViewModel |
| `lib/presentation/bmi_calculator/bmi_calculator_screen.dart` | 수정 — ConsumerStatefulWidget 전환 |
| `lib/presentation/bmi_calculator/widgets/bmi_gauge.dart` | 신규 — 아크 게이지 위젯 분리 |
| `lib/presentation/bmi_calculator/widgets/bmi_input_slider.dart` | 신규 — 슬라이더 카드 위젯 분리 |
| `lib/presentation/bmi_calculator/widgets/bmi_healthy_weight_card.dart` | 신규 — 건강 체중 범위 카드 분리 |
| `lib/presentation/bmi_calculator/widgets/bmi_category_grid.dart` | 신규 — 범주 안내 그리드 분리 |

**데이터 흐름**

```
User 슬라이더 드래그 / 값 직접 입력 / 단위 토글
      │
      ▼
BmiCalculatorScreen (ConsumerStatefulWidget)
      │ handleIntent(intent)
      ▼
BmiCalculatorViewModel (AutoDisposeNotifier)
      │ state.copyWith(...)
      │ _useCase.calculate(...)  ← computed getter
      ▼
BmiCalculatorState (Freezed)       BmiCalculateUseCase
      │                                    │
      ▼                                    ▼
ref.watch() → rebuild             BmiResult (순수 계산값)
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| 화면 파일에 BMI 계산·범주 판정·단위 변환 로직이 인라인으로 섞여 있음 | 테스트 불가, 재사용 불가 |
| `StatefulWidget`으로 상태 직접 관리 | Riverpod DI 혜택 없음 |
| `BmiCategoryDef`, 범주 리스트 등이 화면 파일 내 private 상수 | Domain 계층에서 접근 불가 |
| locale 기반 단위 자동 감지와 SharedPreferences 저장이 미구현 | 스펙 미충족 |
| 886줄 단일 파일 | 유지보수 어려움 |

---

## 목표

- BMI 계산·범주 판정·건강 체중 역산 로직을 `BmiCalculateUseCase`로 격리하여 단위 테스트 가능
- 상태를 `BmiCalculatorState`(Freezed)로 불변 관리
- locale 감지로 단위계(metric/imperial) 기본값 자동 설정
- 단위 선택값을 SharedPreferences에 저장·복원
- 화면 파일을 위젯 분리하여 스크린 150줄 이내 목표
- 화면은 상태 표시와 Intent 전달만 담당

---

## 구현 범위

### 1. `lib/domain/usecases/bmi_calculate_usecase.dart` — BMI 계산 로직

Domain 계층의 순수 계산 로직. 외부 프레임워크 의존 없음.

**BmiCategoryDef (Domain 모델)**

기존 화면 파일의 `BmiCategoryDef` 클래스를 이 파일로 이동. public으로 공개.

```dart
class BmiCategoryDef {
  const BmiCategoryDef({
    required this.label,
    required this.rangeLabel,
    required this.color,
    required this.min,
    required this.max,
  });
  final String label;
  final String rangeLabel;
  final Color color;       // Flutter 의존 — 편의상 유지 (순수 int로 바꿀 수도 있으나 과도)
  final double min;
  final double max;
  bool contains(double bmi) => bmi >= min && bmi < max;
}
```

> `Color`는 `dart:ui` 의존이지만, Flutter 앱에서만 사용하고 Domain 순수성보다 실용성을 우선한다.

**BmiStandard enum**: `global`, `asian`

**범주 상수**: `kGlobalCategories`, `kAsianCategories`, `kAsianCountryCodes` — 기존과 동일하되 public const.

**BmiResult**

| 필드 | 타입 | 설명 |
|------|------|------|
| `bmi` | double | BMI 수치 |
| `category` | BmiCategoryDef | 현재 범주 |
| `categories` | List\<BmiCategoryDef\> | 적용 기준의 전체 범주 목록 |
| `healthyWeightMinKg` | double | 정상 범주 하한 체중 (kg) |
| `healthyWeightMaxKg` | double | 정상 범주 상한 체중 (kg) |
| `isInHealthyRange` | bool | 현재 체중이 건강 범위 내인지 |
| `standard` | BmiStandard | 적용 기준 |

**BmiCalculateUseCase.calculate()**

파라미터: `heightCm` (double), `weightKg` (double), `standard` (BmiStandard)

```
bmi = weightKg / (heightCm / 100)²
categories = standard == asian ? kAsianCategories : kGlobalCategories
category = categories.lastWhere((c) => bmi >= c.min)
normal = categories.firstWhere((c) => c.label.startsWith('정상'))
healthyMin = normal.min × (heightCm/100)²
healthyMax = (normal.max == ∞ ? 상한값 : normal.max) × (heightCm/100)²
isInRange = weightKg >= healthyMin && weightKg <= healthyMax
```

**static 헬퍼**

- `standardForCountryCode(String? code)` → `BmiStandard`
- `defaultIsMetric(String? countryCode)` → `bool` (US → false, 그 외 → true)

---

### 2. `lib/domain/models/bmi_calculator_state.dart` — Freezed 상태

```dart
@freezed
class BmiCalculatorState with _$BmiCalculatorState {
  const factory BmiCalculatorState({
    @Default(170.0) double heightCm,
    @Default(65.0) double weightKg,
    @Default(true) bool isMetric,
    @Default(BmiStandard.global) BmiStandard standard,
  }) = _BmiCalculatorState;
}
```

> 내부 저장은 항상 kg·cm. `isMetric`은 표시 단위만 제어.

---

### 3. `lib/presentation/bmi_calculator/bmi_calculator_viewmodel.dart` — Intent + ViewModel

**BmiCalculatorIntent (sealed)**

| Intent | 파라미터 | 동작 |
|--------|---------|------|
| `heightChanged(double cm)` | heightCm | 키 변경 (항상 cm) |
| `weightChanged(double kg)` | weightKg | 몸무게 변경 (항상 kg) |
| `heightEdited(String input)` | 사용자 입력값 | 다이얼로그 입력 → cm 변환 후 clamp |
| `weightEdited(String input)` | 사용자 입력값 | 다이얼로그 입력 → kg 변환 후 clamp |
| `unitToggled()` | — | metric ↔ imperial 전환 + SharedPreferences 저장 |
| `initialized(Locale locale)` | locale | 최초 진입 시 locale 기반 기본값 설정 |

**BmiCalculatorViewModel**

- `build()`: SharedPreferences에서 저장된 단위 읽기 → 없으면 locale 기본값
- `handleIntent(intent)`: switch로 Intent 처리
- computed getter `result`: `_useCase.calculate(state.heightCm, state.weightKg, state.standard)` 호출
- `_saveUnitPreference()`: 단위 변경 시 SharedPreferences 저장

---

### 4. 위젯 분리

기존 `bmi_calculator_screen.dart`의 private 위젯들을 `widgets/` 폴더로 분리.

| 파일 | 원본 클래스 | 변경 |
|------|-----------|------|
| `widgets/bmi_gauge.dart` | `_BmiGauge` + `_GaugePainter` | public `BmiGauge` + `GaugePainter` |
| `widgets/bmi_input_slider.dart` | `_InputSlider` | public `BmiInputSlider` |
| `widgets/bmi_healthy_weight_card.dart` | `_HealthyWeightCard` | public `BmiHealthyWeightCard` |
| `widgets/bmi_category_grid.dart` | `_CategoryGrid` | public `BmiCategoryGrid` |

### 5. `bmi_calculator_screen.dart` — 화면 전환

- `StatefulWidget` → `ConsumerStatefulWidget`
- 인라인 계산 로직 제거 → ViewModel `result` getter 사용
- locale 감지: `didChangeDependencies`에서 `initialized` Intent 1회 발송
- 바늘 애니메이션: Screen에서 `AnimationController` 유지 (UI 전용 관심사)
- 색상 상수 `_k*`는 화면 파일 상단에 유지
- 직접 입력 다이얼로그도 화면에 유지 (UI 전용)

---

## 구현 순서

```
1. BmiCalculateUseCase + BmiCategoryDef + BmiResult
   └─ test/domain/usecases/bmi_calculate_usecase_test.dart 먼저 작성 (TDD)
   └─ 테스트 케이스: BMI 계산, 글로벌 범주, 아시아 범주, 건강 체중 역산, 엣지 케이스

2. BmiCalculatorState (Freezed)
   └─ build_runner 실행

3. BmiCalculatorViewModel
   └─ sealed Intent 정의
   └─ handleIntent 구현
   └─ SharedPreferences 저장/복원

4. 위젯 분리
   └─ _BmiGauge → widgets/bmi_gauge.dart
   └─ _InputSlider → widgets/bmi_input_slider.dart
   └─ _HealthyWeightCard → widgets/bmi_healthy_weight_card.dart
   └─ _CategoryGrid → widgets/bmi_category_grid.dart

5. Screen 전환
   └─ ConsumerStatefulWidget 전환
   └─ 인라인 로직 제거, ViewModel 연결
   └─ locale 기반 초기화
```

---

## 범위 외 (이번 작업 제외)

- 다국어 번역 (범주명·레이블) — 추후 i18n 작업에서 일괄 처리
- ft·in 분리 입력 다이얼로그 (현재 ft 단일 입력) — 필요 시 후속 개선
- BMI 이력 저장/그래프 — 별도 Phase
