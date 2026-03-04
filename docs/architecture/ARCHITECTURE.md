# CalcMate 아키텍처

## Clean Architecture — 3계층 분리

프로젝트는 Clean Architecture 원칙에 따라 3개 계층으로 엄격히 분리한다.

```
Presentation → Domain ← Data
```

- **Domain**은 순수 Dart로만 구성하며, 외부 프레임워크에 의존하지 않는다.
- **Data**는 Domain이 정의한 Repository 인터페이스를 구현한다.
- **Presentation**은 Domain의 UseCase와 Entity만 참조한다.

---

## MVVM + Intent 패턴

| 구성 요소 | 역할 | 구현 방식 |
|----------|------|----------|
| **View** | 상태를 구독하고 Intent를 전달하는 역할만 한다 | `ConsumerWidget` |
| **ViewModel** | `handleIntent()`로 액션을 받아 State를 계산 | `Riverpod Notifier` |
| **Intent** | 가능한 모든 사용자 액션을 타입으로 정의 | `sealed class` |
| **State** | UI 상태 전체를 담는 단일 진실 공급원 | `Freezed` 불변 객체 |

### 데이터 흐름 (기본 패턴)

```
[Screen (ConsumerWidget)]
        │  handleIntent(intent)
        ▼
[ViewModel (Notifier)]
        │  UseCase.execute()
        ▼
[UseCase]
        │  Repository.method()
        ▼
[Repository 구현체]
        │  DataSource 호출
        ▼
[State 갱신] ──→ [Screen 리렌더]
```

---

## 프로젝트 구조

### 디렉토리 규칙

- 디렉토리명은 `snake_case`를 사용한다.
- 기능별로 `presentation/{기능명}/` 하위에 Screen과 ViewModel을 함께 둔다.

### 전체 구조

```
lib/
├── core/
│   ├── config/        # 앱 전역 상수 (e.g. kCalcModeEntries)
│   ├── di/            # 의존성 주입 (Riverpod Provider)
│   ├── navigation/    # 라우팅 설정
│   ├── network/       # 네트워크 공통 설정 (Interceptor 등)
│   └── theme/         # 라이트/다크 테마
├── data/
│   ├── datasources/   # Remote/Local DataSource 구현체
│   ├── dto/           # Data Transfer Object (Freezed + json_serializable)
│   └── repositories/  # Repository 구현체
├── domain/
│   ├── models/        # Entity (Freezed 불변 모델)
│   ├── repositories/  # Repository 인터페이스
│   └── usecases/      # UseCase (비즈니스 로직 단위)
└── presentation/
    ├── {기능명}/       # 기능별 Screen + ViewModel
    │   ├── feature_screen.dart
    │   ├── feature_viewmodel.dart
    │   ├── feature_state.dart
    │   └── widgets/   # 기능 전용 위젯
    └── widgets/       # 공통 위젯
```

### 위젯 파일 분리 규칙

- **Spec 기반 UI 프로토타이핑 단계**: 한 파일에 작성 가능 (빠른 시안 확인 목적)
- **실제 구현 단계** (ViewModel 연결, 로직 통합): 반드시 `widgets/` 폴더로 분리
- **스크린 파일**: 레이아웃 조합만 담당 (목표 150줄 이내)
- **개별 위젯**: `widgets/` 하위에 파일당 하나의 공개 위젯 클래스
- **공용 위젯 승격 기준**: 2개 이상의 기능에서 사용하되, 아래 조건을 충족할 때만 승격
  - 레이아웃·배열·동작 차이는 **파라미터(콜백, 설정 객체 등)로 커스터마이징** 가능하도록 설계
  - 분기 로직이 과도해지면 공용화하지 않고 기능별 위젯으로 유지
  - 예: NumberPad는 키 목록, 콜백, 버튼 스타일을 외부에서 주입받는 구조로 설계

### AppBar 패턴

계산기 화면의 AppBar는 **`Scaffold.appBar`** 슬롯을 사용한다. 커스텀 AppBar 위젯 파일을 별도로 만들지 않는다.

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(title, style: TextStyle(...)),
    centerTitle: false,  // 타이틀 좌측 정렬
  ),
  body: Container(
    decoration: BoxDecoration(gradient: ...),
    child: SafeArea(
      child: Column(...),  // AppBar 위젯 없이 콘텐츠만
    ),
  ),
)
```

- `extendBodyBehindAppBar: true` — 그라디언트가 상태바 뒤까지 자연스럽게 채워진다.
- `SafeArea`는 body 안에 유지한다. Scaffold가 MediaQuery를 조정하므로 AppBar 높이까지 자동으로 피해준다.
- 화면마다 색상이 다른 경우(예: 나이 계산기)는 `color` 파라미터로 대응하고, 별도 위젯 파일은 만들지 않는다.

---

### 계층별 책임

| 계층 | 디렉토리 | 책임 |
|-----|---------|-----|
| **Core** | `core/` | 공통 유틸리티, 테마, DI 설정 |
| **Data** | `data/` | API 클라이언트, DTO, Repository 구현체 |
| **Domain** | `domain/` | Entity, Repository 인터페이스, UseCase (순수 Dart) |
| **Presentation** | `presentation/` | Widget(View), ViewModel(Riverpod Notifier), State |
