# 기본 계산기 구현 명세

> **브랜치**: `feat/basic-calculator`, `refactor/basic_calculator_keypad_function`
> **목적**: 사칙연산, 괄호, 퍼센트/나머지 연산을 지원하는 기본 계산기 구현

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `domain/models/calculator_state.dart` | Freezed State |
| `domain/usecases/evaluate_expression_usecase.dart` | 재귀 하강 파서 (괄호, mod 지원) |
| `domain/utils/calculator_input_utils.dart` | 수식 입력 유틸 (괄호/음수 판별, resolvePercent) |
| `domain/utils/number_formatter.dart` | 결과 포맷팅 (소수점 최대 9자리) |
| `presentation/calculator/basic_calculator_viewmodel.dart` | Notifier + sealed Intent |
| `presentation/calculator/basic_calculator_screen.dart` | ConsumerWidget, 레이아웃만 |
| `presentation/calculator/basic_calculator_colors.dart` | 계산기 전용 색상 상수 |
| `presentation/calculator/widgets/display_panel.dart` | 수식 + 입력값 디스플레이 |
| `presentation/calculator/widgets/button_pad.dart` | 5×4 키패드 버튼 |
| `presentation/calculator/basic_calculator_screen.dart` | AppBar 인라인 (`Scaffold.appBar`) |
| `test/domain/usecases/evaluate_expression_usecase_test.dart` | UseCase TDD (29케이스) |
| `test/domain/utils/calculator_input_utils_test.dart` | 유틸 TDD (35케이스) |
| `test/presentation/calculator/basic_calculator_viewmodel_test.dart` | ViewModel TDD (52케이스) |

---

## 목표

- 숫자·연산자 입력 시 수식을 조합한다
- `()` 스마트 괄호로 문맥에 따라 `(` 또는 `)` 를 자동 삽입한다
- `%` 는 문맥에 따라 퍼센트 또는 나머지 연산(mod)으로 동작한다
- `=` 탭 시 수식을 계산하고, 미닫힌 괄호를 자동으로 닫는다
- `AC` 는 항상 전체 초기화한다 (C 전환 없음)
- `⌫` 는 마지막 입력 문자를 한 글자씩 제거한다
- 결과 상태에서 `=` 반복 시 마지막 연산을 재적용한다

---

## 구현 범위

### 1. `domain/models/calculator_state.dart` — UI 상태 정의

Freezed 불변 객체로 계산기 전체 UI 상태를 표현한다.

- `input` (String, 기본값 `'0'`): 메인 디스플레이에 표시되는 입력값 또는 결과
- `expression` (String, 기본값 `''`): 계산 완료 후 서브 디스플레이에 표시되는 수식
- `isResult` (bool, 기본값 `false`): 계산 완료 상태 여부

---

### 2. `domain/usecases/evaluate_expression_usecase.dart` — 계산 로직

수식 문자열을 입력받아 `double` 계산 결과를 반환한다. 외부 라이브러리 없이 순수 Dart로 구현한다.

**파싱 방식**: 재귀 하강 파서

```
expression = term (('+' | '-') term)*
term       = atom (('*' | '/' | '%') atom)*
atom       = ['-'] number | ['-'] '(' expression ')'
```

- `parseExpression`: `+`, `-` 처리
- `parseTerm`: `*`, `/`, `%`(mod) 처리 (같은 우선순위)
- `parseAtom`: 숫자, 단항 `-`, `(subexpression)`

**설계 결정**

- 외부 패키지 미사용: 의존성 최소화
- 0 나누기: `double.infinity` 반환 (ViewModel에서 "정의되지 않음" 표시)
- `5.` 같은 trailing dot: `double.parse`가 `5`로 처리
- 환율/부가세 계산기에서도 재사용 — 하위 호환성 유지

---

### 3. `domain/utils/calculator_input_utils.dart` — 수식 입력 유틸

**기존 메서드**:
- `endsWithOperator(String s)` — 연산자로 끝나는지 확인
- `lastNumberSegment(String s)` — 마지막 숫자 세그먼트 반환
- `resolvePercent(String raw)` — `%` 기호를 실제 값으로 변환

**추가된 메서드**:
- `unclosedParenCount(String s)` — 닫히지 않은 `(` 개수
- `isNegativePending(String s)` — 음수 대기 상태 판별 (`-`, `5×-`, `-0`, `5×-0` 등)
- `hasOperator(String s)` — 수식에 연산자 존재 여부 (맨 앞 음수 부호 제외)

**`resolvePercent` 리라이트**:
- 괄호 depth를 추적하는 좌→우 파서로 변경
- `%` 뒤에 숫자가 바로 오면 mod → 그대로 통과 (evaluator가 처리)
- `%` 뒤에 연산자/`=`/끝 → 퍼센트 변환:
  - `+`/`-` 뒤 숫자: base 기준 퍼센트 (`A+B%` → `A+(A×B/100)`)
  - `×`/`÷` 또는 단독: `÷100`
  - `)%`: 매칭 `(` 앞 문맥 확인 — `+`/`-` 문맥이면 base 기준, 그 외 `÷100`

---

### 4. `presentation/calculator/basic_calculator_viewmodel.dart` — ViewModel + Intent

**Intent 목록** (`CalculatorIntent`, sealed class):

| Intent | 설명 |
|--------|------|
| `numberPressed(String digit)` | 숫자 버튼 탭 |
| `operatorPressed(String op)` | 연산자 버튼 탭 (÷ × - +) |
| `equalsPressed()` | = 버튼 탭 |
| `clearPressed()` | AC 버튼 탭 |
| `backspacePressed()` | ⌫ 버튼 탭 |
| `decimalPressed()` | . 버튼 탭 |
| `percentPressed()` | % 버튼 탭 |
| `parenthesesPressed()` | () 스마트 괄호 버튼 탭 |

**핸들러별 핵심 로직**:

| 핸들러 | 핵심 로직 |
|--------|-----------|
| `_onClear` | 항상 전체 초기화 (AC/C 분기 없음) |
| `_onParentheses` | 문맥 판단: 초기`0`→`(` 대체, 연산자/`(` 뒤→`(` 추가, 숫자/`)` 뒤+미닫힌→`)`, 숫자/`)`/`%` 뒤→`×(` |
| `_onOperator` | 초기`0`에서 `-`만 허용, `(` 뒤 `-`만 허용, 연산자 뒤 `-`는 음수 대기, 음수 대기에서 다른 연산자는 취소+교체, 같은 연산자 반복 무시 |
| `_onDecimal` | `(` 뒤→`0.`, 음수 대기→`-0.`, `)` 뒤→`×0.`, `%` 뒤→`×0.` |
| `_onPercent` | 연산자 뒤→교체, `%` 중복→마지막 피연산자만 괄호 감싸기, `(` 뒤→`0%`, 결과 상태→수식 초기화 |
| `_onNumber` | `)` 뒤→암묵적 `×` 삽입, `-0` 상태→숫자 교체 |
| `_onEquals` | 숫자만/불완전 수식 무시, 미닫힌 괄호 자동 닫기, 반복 `=` 지원 |
| `_onBackspace` | 한 글자 제거, 한 자리→`0`, 결과 상태→전체 초기화 |

**설계 결정**:
- 연산자는 `String`으로 받아 수식 문자열에 누적 — `÷`·`×`는 UseCase 진입 전 `/`·`*`로 변환
- `isNegativePending` 등 복잡한 문맥 판단은 `CalculatorInputUtils`에 위임

---

### 5. `presentation/calculator/basic_calculator_screen.dart` — 화면

**버튼 레이아웃** (5×4):

```
⌫  │  AC  │  %  │  ÷
7  │   8  │  9  │  ×
4  │   5  │  6  │  -
1  │   2  │  3  │  +
() │   0  │  .  │  =
```

- `ConsumerWidget` 기반, `ref.watch`로 상태 구독
- 버튼 `onTap` → `vm.handleIntent(_intentFor(label))` 호출
- AC 항상 고정 표시 (C 전환 없음)
- 음수는 그대로 표시 (괄호 자동 감싸기 없음)

**디스플레이**:
- 천 단위 콤마 자동 적용
- 동적 폰트 사이즈 (최대 80pt ~ 최소 10pt)
- 입력값 오른쪽 기준 가로 스크롤
- 수식 줄바꿈 (연산자 앞에서 최대 2줄) + 가로 스크롤
- 다크 그라디언트 테마 (딥 네이비 → 다크 그린)

---

## 범위 외 (이번 작업 제외)

- 계산 히스토리 — 별도 Phase에서 구현
- 공학용 계산기 기능 (sin, cos, 제곱근 등) — 별도 계산기 화면으로 분리 예정
- 애니메이션 (숫자 전환 효과 등) — UI 안정화 후 추가 검토
