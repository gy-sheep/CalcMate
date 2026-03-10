# 더치페이 계산기 구현 명세

> **브랜치**: `dev`
> **목적**: 균등 분배 / 개별 계산 두 모드를 제공하는 더치페이 계산기 구현

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `pubspec.yaml` | 수정 — `share_plus`, `path_provider` 추가 |
| `lib/domain/models/dutch_pay_state.dart` | 신규 — Freezed 상태 모델 (DutchPayState, EqualSplitState, IndividualSplitState, DutchParticipant, DutchItem, RemUnit) |
| `lib/domain/usecases/dutch_pay_equal_split_usecase.dart` | 신규 — 균등 분배 계산 로직 |
| `lib/domain/usecases/dutch_pay_individual_split_usecase.dart` | 신규 — 개별 계산 로직 |
| `lib/presentation/dutch_pay/dutch_pay_viewmodel.dart` | 신규 — Intent + ViewModel |
| `lib/presentation/dutch_pay/dutch_pay_screen.dart` | 수정 — 프로토타입을 ViewModel 연결 후 레이아웃만 담당하도록 리팩터 |
| `lib/presentation/dutch_pay/widgets/dutch_pay_tab_bar.dart` | 신규 — 커스텀 탭바 위젯 |
| `lib/presentation/dutch_pay/widgets/dutch_pay_keypad.dart` | 신규 — 숫자 키패드 위젯 |
| `lib/presentation/dutch_pay/widgets/equal_split_view.dart` | 신규 — 균등 분배 탭 콘텐츠 |
| `lib/presentation/dutch_pay/widgets/individual_split_view.dart` | 신규 — 개별 계산 탭 콘텐츠 |
| `lib/presentation/dutch_pay/widgets/dutch_card.dart` | 신규 — 그라데이션 테두리 카드 공통 위젯 |
| `lib/presentation/dutch_pay/widgets/participant_chip.dart` | 신규 — 참여자 칩 위젯 |
| `lib/presentation/dutch_pay/widgets/share_sheet.dart` | 신규 — 공유 바텀시트 (영수증 미리보기 + 공유) |
| `test/domain/usecases/dutch_pay_equal_split_usecase_test.dart` | 신규 — 균등 분배 UseCase 단위 테스트 |
| `test/domain/usecases/dutch_pay_individual_split_usecase_test.dart` | 신규 — 개별 계산 UseCase 단위 테스트 |

**데이터 흐름**

```
[DutchPayScreen / 위젯들]
        │  handleIntent(intent)
        ▼
[DutchPayViewModel (Notifier)]
        │  useCase.execute()
        ├─▶ [EqualSplitUseCase]   → EqualSplitResult (computed getter)
        └─▶ [IndividualSplitUseCase] → IndividualSplitResult (computed getter)
        │
        ▼
[DutchPayState 갱신] ──→ [화면 리렌더]
```

---

## 목표

- Domain UseCase에 순수 계산 로직 캡슐화 (단위 테스트 가능)
- 프로토타입 StatefulWidget 로직을 ViewModel로 이전
- 위젯 파일 분리 (`widgets/` 폴더)
- 공유 기능 실제 동작 (`RepaintBoundary` → PNG → `share_plus`)

---

## 구현 범위

### 1. `lib/domain/models/dutch_pay_state.dart`

**주요 구성 요소**

- `RemUnit` enum: `hundred(100)` / `thousand(1000)` — 정산 단위
- `DutchParticipant` (Freezed): `name: String`
- `DutchItem` (Freezed): `name`, `amount`, `assignees`
- `EqualSplitState` (Freezed): 균등 분배 입력 상태 전체
- `IndividualSplitState` (Freezed): 개별 계산 입력 상태 전체
- `DutchPayState` (Freezed): 탭 인덱스 + isKorea + 두 서브 상태

**설계 결정**

- 두 모드를 단일 DutchPayState로 통합: ViewModel 하나로 관리 → 탭 전환 시 state 초기화가 단순
- DutchParticipant / DutchItem도 Freezed: copyWith 지원으로 불변 업데이트 용이

---

### 2. `lib/domain/usecases/dutch_pay_equal_split_usecase.dart`

**주요 구성 요소**

- `EqualSplitResult`: `total`, `people`, `rounded`, `organizer`, `isEven`, `perPersonWithTip`
- `EqualSplitUseCase.execute()`: 균등 분배 계산
  - KR: `rounded = floor(total / people / remUnit.value) * remUnit.value`, `organizer = total - rounded * (people - 1)`
  - Non-KR: `perPersonWithTip = (total * (1 + tipRate / 100)) / people`

---

### 3. `lib/domain/usecases/dutch_pay_individual_split_usecase.dart`

**주요 구성 요소**

- `IndividualSplitResult`: `totalAmount`, `personAmounts (List<int>)`
- `IndividualSplitUseCase.execute()`: 항목별 담당자에게 금액 배분
  - `base = amount ~/ assignees.length`, `rem = amount % assignees.length`
  - 첫 번째 담당자에게 rem 귀속

---

### 4. `lib/presentation/dutch_pay/dutch_pay_viewmodel.dart`

**주요 구성 요소**

- `DutchPayIntent` sealed class — 모든 사용자 액션 타입 정의
- `dutchPayViewModelProvider` — `NotifierProvider.autoDispose`
- `DutchPayViewModel` — `handleIntent()` + computed getters

**Computed getters**
- `equalSplitResult` → `EqualSplitResult?` (total == 0이면 null)
- `individualSplitResult` → `IndividualSplitResult`
- `canSubmitItem` → bool
- `fmt(int n)` → 천 단위 콤마 포맷

---

## 구현 순서

```
1. pubspec.yaml — share_plus, path_provider 추가
2. domain/models/dutch_pay_state.dart — Freezed 모델
3. domain/usecases/dutch_pay_equal_split_usecase.dart
4. domain/usecases/dutch_pay_individual_split_usecase.dart
5. test/ — TDD: 두 UseCase 테스트 작성
6. flutter pub run build_runner build
7. flutter test — 통과 확인
8. presentation/dutch_pay/dutch_pay_viewmodel.dart
9. presentation/dutch_pay/widgets/ — 6개 위젯 파일
10. presentation/dutch_pay/dutch_pay_screen.dart — 리팩터
```

---

## 범위 외 (이번 작업 제외)

- 대출 계산기 구현 — Phase 13으로 이동
- 다크 모드 대응 — 향후 테마 통합 시 일괄 적용
