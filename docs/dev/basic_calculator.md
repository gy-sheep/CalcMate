# 기본 계산기 구현 명세

> **브랜치**: `feat/basic-calculator`
> **목적**: 기본 계산기 로직 구현 — State/Intent 정의, UseCase TDD, ViewModel 연결

---

## 프로젝트 구조 및 작업 범위

아래 구조에서 `[신규]`는 새로 생성되는 파일, `[수정]`은 기존 파일 변경을 나타낸다.

```
lib/
├── domain/
│   ├── models/
│   │   └── calculator_state.dart          [신규] Freezed State
│   └── usecases/
│       └── evaluate_expression_usecase.dart  [신규] 계산 로직
├── presentation/
│   └── calculator/
│       ├── basic_calculator_screen.dart   [수정] ConsumerWidget 전환, ViewModel 연결
│       └── basic_calculator_viewmodel.dart  [신규] Notifier + Intent
test/
└── domain/
    └── usecases/
        └── evaluate_expression_usecase_test.dart  [신규] TDD 테스트
```

**데이터 흐름**

```
[BasicCalculatorScreen]
        │  handleIntent(intent)
        ▼
[BasicCalculatorViewModel]
        │  EvaluateExpressionUseCase.execute(expression)
        ▼
[EvaluateExpressionUseCase]
        │  double result
        ▼
[CalculatorState] ──→ [BasicCalculatorScreen] 리렌더
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| `BasicCalculatorScreen`이 StatelessWidget으로 하드코딩된 UI만 존재 | 버튼 탭이 TODO 처리되어 있어 실제 계산 불가 |
| State/Intent 정의 없음 | ViewModel 연결 불가 |
| 계산 로직 없음 | 수식 평가 불가 |

---

## 목표

- 버튼 탭 시 숫자·연산자가 수식으로 조합된다
- `=` 탭 시 수식이 계산되어 결과가 표시된다
- `⌫` 탭 시 마지막 입력이 지워진다
- `AC` 탭 시 전체 초기화된다
- `+/-` 탭 시 현재 입력값의 부호가 전환된다
- `%` 탭 시 현재 입력값이 ÷100 처리된다
- 계산 완료 상태에서 숫자 입력 시 새 수식으로 시작된다

---

## 구현 범위

### 1. `domain/models/calculator_state.dart` — UI 상태 정의

Freezed 불변 객체로 계산기 전체 UI 상태를 표현한다.

```dart
@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    @Default('0') String input,      // 메인 디스플레이 (입력값 또는 결과)
    @Default('') String expression,  // 수식 표시 (계산 완료 후에만 표시)
    @Default(false) bool isResult,   // true: 계산 완료 상태
  }) = _CalculatorState;
}
```

**설계 결정**

- `input`: 현재 입력 중인 숫자 또는 계산 결과를 하나의 필드로 관리 — iOS 계산기와 동일한 단일 디스플레이 방식
- `expression`: 계산 완료 후 수식(예: `265+35=`)을 표시, `isResult`가 false이면 View에서 숨김 처리
- `isResult`: 계산 완료 여부 — 이 상태에서 숫자 입력 시 새 수식 시작 여부 판단에 사용

---

### 2. `presentation/calculator/basic_calculator_viewmodel.dart` — ViewModel + Intent

```dart
sealed class CalculatorIntent {
  const factory CalculatorIntent.numberPressed(String digit) = _NumberPressed;
  const factory CalculatorIntent.operatorPressed(String op) = _OperatorPressed;
  const factory CalculatorIntent.equalsPressed() = _EqualsPressed;
  const factory CalculatorIntent.clearPressed() = _ClearPressed;
  const factory CalculatorIntent.backspacePressed() = _BackspacePressed;
  const factory CalculatorIntent.decimalPressed() = _DecimalPressed;
  const factory CalculatorIntent.percentPressed() = _PercentPressed;
  const factory CalculatorIntent.negatePressed() = _NegatePressed;
}

class BasicCalculatorViewModel extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  void handleIntent(CalculatorIntent intent) { ... }
}
```

**설계 결정**

- `CalculatorIntent`는 `sealed class` + factory constructor 패턴 — `MainScreenViewModel`과 동일한 방식으로 일관성 유지
- 연산자는 `String`으로 받아 내부에서 수식 문자열에 누적 — `÷`·`×`는 UseCase 진입 전에 `/`·`*`로 변환

---

### 3. `domain/usecases/evaluate_expression_usecase.dart` — 계산 로직

수식 문자열을 입력받아 계산 결과를 반환한다. 외부 라이브러리 없이 순수 Dart로 구현한다.

```dart
class EvaluateExpressionUseCase {
  double execute(String expression);
}
```

**설계 결정**

- 사칙연산(`+`, `-`, `*`, `/`) 우선순위를 직접 파싱 — `math_expressions` 같은 외부 패키지 미사용 (의존성 최소화)
- 파싱 방식: 두 단계 — ① `*`·`/` 먼저 처리, ② `+`·`-` 처리 (연산자 우선순위 반영)
- 0 나누기 등 예외는 `double.infinity` 또는 별도 `CalculatorException`으로 처리

---

### 4. `presentation/calculator/basic_calculator_screen.dart` — ViewModel 연결

`StatelessWidget` → `ConsumerWidget` 전환 후 버튼 탭 이벤트를 Intent로 위임한다.

```dart
class BasicCalculatorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorViewModelProvider);
    // 디스플레이: state.input, state.expression, state.isResult
    // 버튼 탭: ref.read(...).handleIntent(intent)
  }
}
```

---

## 파일 변경 목록

| 파일 | 작업 |
|------|------|
| `domain/models/calculator_state.dart` | 신규 생성 |
| `domain/models/calculator_state.freezed.dart` | 자동 생성 (build_runner) |
| `domain/usecases/evaluate_expression_usecase.dart` | 신규 생성 |
| `presentation/calculator/basic_calculator_viewmodel.dart` | 신규 생성 |
| `presentation/calculator/basic_calculator_screen.dart` | 수정 (ConsumerWidget 전환, ViewModel 연결) |
| `test/domain/usecases/evaluate_expression_usecase_test.dart` | 신규 생성 (TDD) |

---

## 구현 순서

```
1. CalculatorState 정의 (Freezed)
   └─ build_runner 실행하여 .freezed.dart 생성

2. EvaluateExpressionUseCase 테스트 먼저 작성 (TDD)
   └─ 케이스: 덧셈, 뺄셈, 곱셈, 나눗셈, 혼합 연산, 소수점, 0 나누기

3. EvaluateExpressionUseCase 구현 (테스트 통과 목표)

4. CalculatorIntent + BasicCalculatorViewModel 구현
   └─ 각 Intent별 state 전이 로직

5. BasicCalculatorScreen ConsumerWidget 전환
   └─ 디스플레이 state 연결
   └─ 버튼 onTap → handleIntent 연결
```

---

## 범위 외 (이번 작업 제외)

- 계산 히스토리 — 별도 Phase에서 구현
- 공학용 계산기 기능 (sin, cos, 제곱근 등) — 별도 계산기 화면으로 분리 예정
- 애니메이션 (숫자 전환 효과 등) — UI 안정화 후 추가 검토
