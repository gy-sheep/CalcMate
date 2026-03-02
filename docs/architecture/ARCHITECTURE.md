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
    └── widgets/       # 공통 위젯
```

### 계층별 책임

| 계층 | 디렉토리 | 책임 |
|-----|---------|-----|
| **Core** | `core/` | 공통 유틸리티, 테마, DI 설정 |
| **Data** | `data/` | API 클라이언트, DTO, Repository 구현체 |
| **Domain** | `domain/` | Entity, Repository 인터페이스, UseCase (순수 Dart) |
| **Presentation** | `presentation/` | Widget(View), ViewModel(Riverpod Notifier), State |
