# 카드 리스트 리팩터링 기획

> **브랜치**: `feat/calc-mode-card-refactor`
> **목적**: Phase 1 진입 전 선행 작업 — 하드코딩된 카드 목록을 데이터 주도(data-driven) 구조로 전환

---

## 프로젝트 구조 및 작업 범위

아래 구조에서 `[신규]`는 새로 생성되는 파일, `[수정]`은 기존 파일 변경을 나타낸다.

```
lib/
├── core/
│   ├── config/
│   │   └── calc_mode_config.dart       [신규] 13개 항목 상수
│   ├── di/
│   │   └── providers.dart
│   ├── network/
│   │   └── error_interceptor.dart
│   └── theme/
│       └── app_theme.dart
│
├── domain/
│   └── models/
│       └── calc_mode_entry.dart        [신규] CalcModeEntry Freezed 모델
│           calc_mode_entry.freezed.dart [자동생성] build_runner
│
├── presentation/
│   ├── main/
│   │   ├── main_screen.dart            [수정] ConsumerWidget 전환
│   │   └── main_screen_viewmodel.dart  [신규] Notifier + State + Intent
│   ├── calculator/
│   │   └── basic_calculator_screen.dart
│   └── widgets/
│       └── calc_mode_card.dart         [변경 없음] props만 entry에서 주입
│
└── main.dart
```

**데이터 흐름 (리팩터링 후)**

```
kCalcModeEntries (config)
        │
        ▼
MainScreenViewModel (Notifier)
  └─ state: MainScreenState { entries, isScrolled }
        │
        ▼
MainScreen (ConsumerWidget)  ──Intent──▶  ViewModel.handleIntent()
  └─ ListView
       └─ CalcModeCard(entry)
```

---

## 배경 및 문제

현재 `main_screen.dart`는 13개의 `CalcModeCard` 위젯을 빌드 메서드 내에 직접 나열한다.

```dart
// 현재: build() 안에 모두 하드코딩
final calcCards = [
  CalcModeCard(title: '기본 계산기', ...),
  CalcModeCard(title: '환율 계산기', ...),
  ...
];
```

**문제점**

| 문제 | 영향 |
|------|------|
| 데이터와 UI가 결합 | 항목 추가·수정 시 View 코드를 직접 건드려야 함 |
| 상태 관리 없음 | StatefulWidget + setState — Riverpod 아키텍처 미준수 |
| 라우팅 정보 분산 | 각 카드의 onTap 안에 Navigator 코드가 흩어져 있음 |
| 테스트 불가 | 카드 목록 로직을 단위 테스트할 수 없음 |

---

## 목표

- 카드 목록을 **불변 데이터 모델(CalcModeEntry)**로 정의
- **config 파일** 한 곳에서 13개 항목 관리
- `MainScreen`을 `ConsumerWidget`으로 전환해 Riverpod 상태 구독
- View는 렌더링만, 데이터·로직은 ViewModel이 담당하는 MVVM 구조 완성

---

## 구현 범위

### 1. `domain/models/calc_mode_entry.dart` — 데이터 모델

Freezed 불변 모델. 카드 한 장을 표현하는 단일 진실 공급원.

```dart
@freezed
class CalcModeEntry with _$CalcModeEntry {
  const factory CalcModeEntry({
    required String id,           // 라우팅 식별자 (예: 'basic_calculator')
    required String title,        // 카드 타이틀
    required String description,  // 카드 서브타이틀
    required IconData icon,       // 카드 아이콘
    required String imagePath,    // 배경 이미지 에셋 경로
    @Default(true) bool isVisible, // 카드 노출 여부
    required int order,           // 카드 표시 순서
  }) = _CalcModeEntry;
}
```

**설계 결정**

- `id`: 라우팅 및 Hero 태그의 기준값으로 사용 (`calc_bg_$id`, `calc_icon_$id`)
- `isVisible`: 향후 설정에서 카드 숨김 기능 지원을 위한 선행 필드
- `order`: 사용자 정렬 지원 시 기준값으로 활용

---

### 2. `core/config/calc_mode_config.dart` — 항목 상수

13개 카드 데이터를 하나의 상수 리스트로 관리.

```dart
const List<CalcModeEntry> kCalcModeEntries = [
  CalcModeEntry(
    id: 'basic_calculator',
    title: '기본 계산기',
    description: '사칙연산 및 공학 계산',
    icon: Icons.calculate,
    imagePath: 'assets/images/backgrounds/basic_calculator.png',
    order: 0,
  ),
  // ... 12개 더
];
```

**항목 목록 (순서 고정)**

| order | id | title |
|-------|----|-------|
| 0 | basic_calculator | 기본 계산기 |
| 1 | exchange_rate | 환율 계산기 |
| 2 | unit_converter | 단위 변환기 |
| 3 | vat_calculator | 부가세 계산기 |
| 4 | age_calculator | 나이 계산기 |
| 5 | date_calculator | 날짜 계산기 |
| 6 | loan_calculator | 대출 계산기 |
| 7 | salary_calculator | 실수령액 계산기 |
| 8 | discount_calculator | 할인 계산기 |
| 9 | dutch_pay | 더치페이 계산기 |
| 10 | rent_calculator | 전월세 계산기 |
| 11 | acquisition_tax | 취득세 계산기 |
| 12 | bmi_calculator | BMI 계산기 |

---

### 3. `presentation/main/main_screen_viewmodel.dart` — ViewModel

```
State:  MainScreenState (Freezed)
Intent: MainScreenIntent (sealed class)
VM:     MainScreenViewModel (Riverpod Notifier)
```

**State**

```dart
@freezed
class MainScreenState with _$MainScreenState {
  const factory MainScreenState({
    @Default([]) List<CalcModeEntry> entries,
    @Default(false) bool isScrolled,
  }) = _MainScreenState;
}
```

**Intent**

```dart
sealed class MainScreenIntent {
  const factory MainScreenIntent.scrollChanged(bool isScrolled) = _ScrollChanged;
  const factory MainScreenIntent.cardTapped(String id) = _CardTapped;
}
```

**ViewModel**

```dart
class MainScreenViewModel extends Notifier<MainScreenState> {
  @override
  MainScreenState build() => MainScreenState(entries: kCalcModeEntries);

  void handleIntent(MainScreenIntent intent) {
    switch (intent) {
      case _ScrollChanged(:final isScrolled):
        state = state.copyWith(isScrolled: isScrolled);
      case _CardTapped(:final id):
        // 라우팅 처리 (Phase 1 이후 확장)
    }
  }
}
```

---

### 4. `presentation/main/main_screen.dart` — View 전환

- `StatefulWidget` → `ConsumerWidget`
- `ScrollController` 리스너 → ViewModel Intent로 위임
- `calcCards` 하드코딩 → `ref.watch(mainScreenViewModelProvider).entries` 구독
- Hero 태그 기준: `title` → `entry.id`

**변경 전/후 구조 비교**

```
변경 전                          변경 후
───────────────────────          ───────────────────────
StatefulWidget                   ConsumerWidget
setState(_isScrolled)            handleIntent(ScrollChanged)
calcCards = [ CalcModeCard() ]   entries = state.entries
Hero tag: 'calc_bg_$title'       Hero tag: 'calc_bg_${entry.id}'
```

---

## 파일 변경 목록

| 파일 | 작업 |
|------|------|
| `domain/models/calc_mode_entry.dart` | 신규 생성 |
| `domain/models/calc_mode_entry.freezed.dart` | 자동 생성 (build_runner) |
| `core/config/calc_mode_config.dart` | 신규 생성 |
| `presentation/main/main_screen_viewmodel.dart` | 신규 생성 |
| `presentation/main/main_screen.dart` | 수정 (ConsumerWidget 전환) |

---

## 구현 순서

```
1. CalcModeEntry 모델 작성
   └─ build_runner 실행 → .freezed.dart 생성
2. kCalcModeEntries 상수 작성
3. MainScreenState / MainScreenIntent / MainScreenViewModel 작성
4. MainScreen ConsumerWidget 전환
5. 빌드 확인 (flutter run)
```

---

## 범위 외 (이번 작업 제외)

- 라우팅 로직 구현 (각 계산기 화면 연결) — Phase 1~N에서 순차 추가
- 카드 순서 변경·숨김 UI — 설정 화면 구현 시 추가
- `CalcModeCard` 위젯 자체 수정 없음 (props만 entry에서 주입)
