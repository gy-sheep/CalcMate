# 단위 변환기 구현 명세

> **브랜치**: `feat/unit-converter`
> **목적**: 단위 변환기 로직 구현 — Domain 모델/UseCase, ViewModel(State/Intent), 스와이프 카테고리 전환, 키패드 입력 연결

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `domain/models/unit_converter_state.dart` | [신규] Freezed State |
| `domain/models/unit_definition.dart` | [신규] 단위 정의 모델 |
| `domain/usecases/convert_unit_usecase.dart` | [신규] 변환 로직 (비율 기반 + 온도/연비 특수 공식) |
| `core/constants/unit_definitions.dart` | [신규] 10개 카테고리 단위 상수 정의 |
| `presentation/unit_converter/unit_converter_viewmodel.dart` | [신규] Notifier + Intent + State |
| `presentation/unit_converter/unit_converter_screen.dart` | [수정] ConsumerWidget 전환, TabBarView 스와이프 |
| `test/domain/usecases/convert_unit_usecase_test.dart` | [신규] TDD 테스트 |

**데이터 흐름**

```
[Screen] ──keyTapped/unitTapped/swipe──→ [ViewModel.handleIntent()]
                                              │
                                              ├─ 입력값 갱신
                                              ├─ ConvertUnitUseCase.execute()
                                              └─ state = state.copyWith(...)
                                              │
[Screen] ←──ref.watch(provider)──────── [UnitConverterState]
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| `UnitConverterScreen`이 StatefulWidget으로 내부 상태만 관리 | 비즈니스 로직과 UI가 결합되어 있어 테스트 불가 |
| 더미 데이터 하드코딩 (`_UnitCategory`, `_UnitItem`) | 실제 변환 로직 없음, 모든 값이 `'0'` |
| 카테고리 전환이 탭 터치만 지원 | 스와이프 UX 부재 |

---

## 목표

- 아무 단위 행을 탭하여 활성화한 뒤 키패드로 값을 입력하면, 모든 단위의 변환 결과가 실시간으로 업데이트된다
- 단위 리스트 영역을 좌우 스와이프하면 카테고리가 전환되고, 카테고리 탭과 양방향 연동된다
- 온도/연비 등 특수 변환 공식이 정확하게 동작한다
- 결과 표시 규칙 (천 단위 콤마, 지수 표기법 등)이 스펙대로 적용된다
- 자릿수 제한 (정수 12, 소수 8) 초과 시 토스트로 안내한다

---

## 구현 범위

### 1. `domain/models/unit_definition.dart` — 단위 정의 모델

카테고리와 개별 단위의 정보를 담는 불변 모델. Freezed는 사용하지 않고 `const` 클래스로 정의한다 (변환 상수이므로 런타임 변경 없음).

**주요 구성 요소**

- `UnitCategory`: 카테고리 정보 (name, icon, units, defaultCode)
- `UnitDef`: 개별 단위 정보 (code, label, ratio)
  - `ratio`: 기준 단위 대비 변환 비율 (온도/연비는 `null` — 특수 공식 사용)

**설계 결정**

- 기존 화면의 `_UnitCategory`, `_UnitItem` 더미 클래스를 대체한다
- `ratio`가 `null`이면 특수 변환 대상으로 판별 — UseCase에서 분기 처리

---

### 2. `core/constants/unit_definitions.dart` — 단위 상수

10개 카테고리의 모든 단위를 `List<UnitCategory>` 상수로 정의한다. 스펙 문서의 변환 비율 표를 그대로 옮긴다.

**설계 결정**

- `core/constants/`에 배치: Domain 모델은 순수하게 유지하고, 상수 데이터는 core에서 관리
- 화면 코드의 더미 데이터(`_categories`)를 완전히 대체

---

### 3. `domain/usecases/convert_unit_usecase.dart` — 변환 로직

활성 단위의 입력값을 기준으로 모든 단위의 변환 결과를 계산한다.

**주요 구성 요소**

- `execute(String categoryName, String fromCode, double value, List<UnitDef> units) → Map<String, double>`: 전체 단위에 대한 변환 결과 맵 반환

**변환 로직 분기**

| 카테고리 | 방식 |
|----------|------|
| 일반 (길이, 질량, 넓이 등) | `value × (fromUnit.ratio / toUnit.ratio)` |
| 온도 | 직접 변환 공식 (°C ↔ °F ↔ K) |
| 연비 | 직접/역수 혼합 공식 (km/L ↔ L/100km ↔ mpg) |

**설계 결정**

- 온도/연비는 내부에 `_convertTemperature()`, `_convertFuelEfficiency()` 헬퍼를 둔다
- 연비 입력값 `0`일 때 역수 변환은 `0`을 반환 (0 나누기 방지)
- 결과는 `double` 원시값으로 반환 — 포맷팅은 ViewModel에서 처리

---

### 4. `domain/models/unit_converter_state.dart` — Freezed State

단위 변환기 전체 UI 상태를 표현하는 불변 객체.

**주요 구성 요소**

- `selectedCategoryIndex` (int, 기본값 `0`): 현재 선택된 카테고리 인덱스
- `activeUnitCode` (String): 현재 활성화된 단위 코드
- `input` (String, 기본값 `'0'`): 활성 단위의 입력값 (raw 문자열, 콤마 미포함)
- `convertedValues` (Map<String, String>): 각 단위 코드별 포맷팅된 변환 결과
- `toastMessage` (String?): 자릿수 초과 등 안내 메시지

**설계 결정**

- `convertedValues`를 `Map<String, String>`으로 정의: 이미 포맷팅된 문자열을 저장하여 View에서 추가 변환 없이 바로 표시
- `input`은 raw 문자열 유지 — ViewModel에서 콤마 포맷팅 후 활성 행에 표시

---

### 5. `presentation/unit_converter/unit_converter_viewmodel.dart` — ViewModel + Intent

**Intent 목록**

| Intent | 설명 |
|--------|------|
| `keyTapped(String key)` | 키패드 버튼 입력 (0-9, `.`, `⌫`, `AC`, `+/-`) |
| `categorySelected(int index)` | 카테고리 탭 선택 또는 스와이프 전환 |
| `unitTapped(String code)` | 단위 행 탭 (활성 단위 변경) |
| `arrowTapped(int direction)` | ▲(-1) / ▼(+1) 활성 단위 이동 |

**주요 내부 메서드**

- `_onKeyTap(String key)`: 입력값 갱신 + 자릿수 제한 검증 + 변환 결과 재계산
- `_onCategorySelected(int index)`: 카테고리 변경, 입력값 `'0'` 초기화, 기본 활성 단위 설정
- `_onUnitTapped(String code)`: 활성 단위 전환, 현재 변환 결과를 새 활성 단위의 input으로 역산
- `_onArrow(int direction)`: 활성 단위 위/아래 이동
- `_recalculate()`: `ConvertUnitUseCase`를 호출하고 결과를 포맷팅하여 `convertedValues` 갱신
- `_formatResult(double value)`: 스펙의 결과 표시 규칙에 따른 포맷팅
- `_formatInput(String raw)`: 천 단위 콤마 적용

**설계 결정**

- 환율 계산기(`CurrencyCalculatorViewModel`)의 키패드 입력 패턴을 재사용: `_onKeyTap` 내 자릿수 제한, `isResult` 리셋 로직 동일
- 포맷팅은 ViewModel 책임 — View는 `state.convertedValues[code]`를 그대로 표시

---

### 6. `presentation/unit_converter/unit_converter_screen.dart` — UI 리팩터링

기존 StatefulWidget을 ConsumerStatefulWidget으로 전환하고, ViewModel Provider를 구독한다.

**주요 변경점**

- 내부 상태 변수(`_selectedCategoryIndex`, `_activeUnitCode`) 제거 → `ref.watch(provider)`로 대체
- 더미 데이터(`_UnitCategory`, `_UnitItem`, `_categories`) 제거 → `unitCategories` 상수 사용
- 버튼 `onTap` → `vm.handleIntent(intent)` 호출로 위임

**스와이프 카테고리 전환 구현**

- `TabController` + `TabBarView`로 단위 리스트 영역을 페이지화
  - `TabController`를 `TickerProviderStateMixin`과 함께 사용
  - `TabBarView`의 각 페이지에 해당 카테고리의 `_UnitList` 배치
- 카테고리 탭(`_CategoryTabs`)과 양방향 연동
  - `TabController.addListener()`: 스와이프로 페이지 변경 시 ViewModel에 `categorySelected` Intent 전달
  - `ref.listen(provider.select((s) => s.selectedCategoryIndex))`: ViewModel의 카테고리 변경 시 `TabController.animateTo()` 호출
- 키패드는 `TabBarView` 외부에 배치하여 스와이프 충돌 없음
- 세로 스크롤(`ListView`)과 수평 스와이프(`TabBarView`)는 Flutter 제스처 시스템이 방향을 자동 판별

---

## 구현 순서

```
1. UnitDef / UnitCategory 모델 정의
   └─ domain/models/unit_definition.dart

2. 10개 카테고리 단위 상수 정의
   └─ core/constants/unit_definitions.dart
   └─ 스펙 문서의 변환 비율 표 그대로 옮기기

3. ConvertUnitUseCase 테스트 먼저 작성 (TDD)
   └─ 일반 변환, 온도 변환, 연비 변환, 0 입력, 극값 케이스

4. ConvertUnitUseCase 구현 (테스트 통과 목표)

5. UnitConverterState 정의 (Freezed)
   └─ build_runner 실행하여 .freezed.dart 생성

6. UnitConverterIntent + UnitConverterViewModel 구현
   └─ 각 Intent별 state 전이 로직
   └─ 결과 포맷팅 로직 (_formatResult)

7. UnitConverterScreen 리팩터링
   └─ ConsumerStatefulWidget 전환
   └─ TabController + TabBarView 스와이프 구현
   └─ 카테고리 탭 양방향 연동
   └─ 키패드 onTap → handleIntent 연결
   └─ 더미 데이터 제거, 상수/State로 대체
```

---

## 범위 외 (이번 작업 제외)

- 단위 즐겨찾기/순서 커스터마이즈 — 추후 Phase에서 검토
- 단위 변환 히스토리 — 별도 기능으로 분리 예정
- 전환 애니메이션 고도화 (페이지 전환 시 단위 리스트 fade 등) — UI 안정화 후 추가 검토
