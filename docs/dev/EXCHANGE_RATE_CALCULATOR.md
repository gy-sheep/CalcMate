# 환율 계산기 구현 명세

> **브랜치**: `feat/exchange_rate`
> **목적**: 목업 기반 환율 계산기 스크린을 Clean Architecture로 전환하고, 실제 환율 API를 연동한다.

---

## 프로젝트 구조 및 작업 범위

아래 구조에서 `[신규]`는 새로 생성되는 파일, `[수정]`은 기존 파일 변경을 나타낸다.

```
lib/
├── core/
│   ├── di/
│   │   └── providers.dart                              [수정] exchangeRateRepositoryProvider 추가
│   └── navigation/
│       └── calc_page_route.dart                        [완료] 공통 라우트
├── domain/
│   ├── models/
│   │   └── exchange_rate_entity.dart                   [신규] ExchangeRateEntity (Freezed)
│   ├── repositories/
│   │   └── exchange_rate_repository.dart               [신규] Repository 인터페이스
│   └── usecases/
│       └── get_exchange_rate_usecase.dart               [신규] 환율 조회 UseCase
├── data/
│   ├── api/
│   │   └── exchange_rate_api.dart                      [신규] Retrofit 인터페이스
│   ├── dto/
│   │   └── exchange_rate_dto.dart                      [신규] Freezed + json_serializable DTO
│   └── repositories/
│       └── exchange_rate_repository_impl.dart          [신규] Repository 구현체 (API + 캐시)
└── presentation/
    └── currency/
        ├── currency_calculator_screen.dart             [수정] StatefulWidget → ConsumerWidget, ViewModel 연결
        └── currency_calculator_viewmodel.dart          [신규] ExchangeRateViewModel (Notifier)
```

**데이터 흐름**

```
[CurrencyCalculatorScreen]
        │ handleIntent()
        ▼
[ExchangeRateViewModel]  ──── build() 시 자동 조회
        │ GetExchangeRateUseCase.execute()
        ▼
[ExchangeRateRepository] (인터페이스)
        │
        ├── 캐시 HIT  ──→ SharedPreferences (ExchangeRateEntity)
        │
        └── 캐시 MISS / 만료
                │
                ▼
        [ExchangeRateApi] (Retrofit)
                │ GET /latest?from=KRW
                ▼
        frankfurter.app API
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| `currency_calculator_screen.dart`가 목업 데이터를 파일 내에 직접 보유 | 실제 환율 반영 불가 |
| 비즈니스 로직(환산, 수식 처리)이 View에 혼재 | 테스트 불가, 재사용 불가 |
| 네트워크 오류 / 오프라인 시 대응 없음 | 앱 사용 불가 |
| ViewModel 없이 `StatefulWidget`으로만 구성 | MVVM 패턴 불일치 |

---

## 목표

- 환율 데이터를 실제 API(`frankfurter.app`)에서 조회한다
- Clean Architecture 3계층을 준수한다 (`Presentation → Domain ← Data`)
- 오프라인 또는 API 오류 시 `SharedPreferences` 캐시로 fallback 한다
- 캐시 유효 기간: **1시간** (만료 시 백그라운드 재조회)
- ViewModel이 모든 상태와 인텐트를 담당한다

---

## 구현 범위

### 1. `domain/models/exchange_rate_entity.dart` — 환율 Entity

Freezed 불변 객체. 도메인 계층의 환율 데이터 표현.

**주요 구성 요소**

- `base` (String): 기준 통화 코드 (예: `'KRW'`)
- `rates` (Map\<String, double\>): 기준 통화 대비 각 통화의 환율 (예: `{'USD': 0.00075}`)
- `fetchedAt` (DateTime): 조회 시각 — 캐시 유효성 판단 기준

**설계 결정**

- `fetchedAt`은 Repository에서 직접 주입: API 응답의 `date` 필드(날짜 단위)가 아닌 실제 조회 시각을 기준으로 1시간 캐시 만료를 판단한다

---

### 2. `domain/repositories/exchange_rate_repository.dart` — Repository 인터페이스

Domain 계층이 Data 계층에 의존하지 않도록 인터페이스만 정의한다.

**주요 구성 요소**

- `getLatestRates({String base})` → `Future<ExchangeRateEntity>`: 최신 환율 조회. 캐시가 유효하면 캐시 반환, 만료 시 API 호출

---

### 3. `domain/usecases/get_exchange_rate_usecase.dart` — 환율 조회 UseCase

Repository를 주입받아 `execute()`를 호출하는 단일 책임 UseCase.

**주요 구성 요소**

- `execute({String base})` → `Future<ExchangeRateEntity>`: Repository의 `getLatestRates()`를 위임 호출

---

### 4. `data/dto/exchange_rate_dto.dart` — API 응답 DTO

`frankfurter.app` 응답 형식을 Dart 객체로 매핑하고, Entity로 변환하는 책임을 가진다.

**API 응답 형식 (참고)**

```json
{
  "amount": 1.0,
  "base": "KRW",
  "date": "2026-03-01",
  "rates": { "USD": 0.00069, "EUR": 0.00064, "JPY": 0.103 }
}
```

**주요 구성 요소**

- `ExchangeRateDto` (Freezed + json_serializable): `base`, `date`, `rates` 필드로 API 응답 매핑
- `toEntity()` 확장 메서드: DTO → `ExchangeRateEntity` 변환. `rates`에 기준 통화 자신(`base: 1.0`)을 추가하고 `fetchedAt`을 현재 시각으로 주입

---

### 5. `data/api/exchange_rate_api.dart` — Retrofit API 인터페이스

Retrofit을 이용한 HTTP 클라이언트 정의.

**주요 구성 요소**

- `getLatestRates(String base)` → `Future<ExchangeRateDto>`: `GET /latest?from={base}` 호출

**설계 결정**

- baseUrl: `https://api.frankfurter.app`

---

### 6. `data/repositories/exchange_rate_repository_impl.dart` — Repository 구현체

캐시 전략과 오프라인 fallback을 담당하는 Repository 구현체.

**주요 구성 요소**

- `ExchangeRateApi`: Retrofit API 클라이언트 주입
- `SharedPreferences`: 캐시 저장소 주입
- 캐시 키: `'exchange_rate_cache'`, 유효 기간: 1시간

**설계 결정**

- 캐시 우선 전략: 조회 시각 기준 1시간 이내면 API 호출 없이 캐시 반환
- 오프라인 fallback: API 실패 시 만료된 캐시라도 반환. 캐시 자체가 없으면 예외 rethrow

---

### 7. `presentation/currency/currency_calculator_viewmodel.dart` — ViewModel

**주요 구성 요소**

- `ExchangeRateState` (Freezed): 아래 필드로 구성
  - `rates` (Map\<String, double\>, 기본값 `{}`): 전체 환율 맵 (KRW 기준)
  - `fromCode` (String, 기본값 `'USD'`): 출발 통화 코드
  - `toCode` (String, 기본값 `'EUR'`): 도착 통화 코드
  - `input` (String, 기본값 `'0'`): 입력값 (수식 포함 가능)
  - `isFromActive` (bool, 기본값 `true`): 상단/하단 입력 활성 여부
  - `isResult` (bool, 기본값 `false`): = 눌러 결과 표시 중 여부
  - `isLoading` (bool, 기본값 `false`)
  - `error` (String?): 오류 메시지
  - `lastUpdated` (DateTime?): 마지막 환율 갱신 시각

- `ExchangeRateIntent` (sealed class): 아래 Intent 목록
  - `keyTapped(String key)`: 키패드 입력
  - `fromCurrencyChanged(String code)`: 출발 통화 변경
  - `toCurrencyChanged(String code)`: 도착 통화 변경
  - `swapped()`: 출발/도착 통화 교체
  - `activeRowChanged(bool isFrom)`: 활성 입력 행 전환
  - `refreshRequested()`: 환율 강제 갱신

**설계 결정**

- `AsyncNotifier` 대신 `Notifier` 사용: UI 상태(input, isFromActive 등)와 비동기 로딩 상태를 단일 State로 관리. `isLoading` 플래그로 로딩 표현
- `rates`는 KRW 기준 전체 맵 유지: 통화 전환 시 API 재호출 없이 즉시 계산 가능

---

### 8. `presentation/currency/currency_calculator_screen.dart` — View 수정

- `StatefulWidget` → `ConsumerWidget`으로 전환
- 모든 상태 참조를 `ref.watch(exchangeRateViewModelProvider)`로 교체
- 모든 사용자 액션을 `handleIntent()`로 위임
- 기존 Hero 애니메이션, 키패드 레이아웃 그대로 유지

---

## 파일 변경 목록

| 파일 | 작업 |
|------|------|
| `domain/models/exchange_rate_entity.dart` | 신규 생성 |
| `domain/models/exchange_rate_entity.freezed.dart` | 자동 생성 (build_runner) |
| `domain/models/exchange_rate_entity.g.dart` | 자동 생성 (build_runner) |
| `domain/repositories/exchange_rate_repository.dart` | 신규 생성 |
| `domain/usecases/get_exchange_rate_usecase.dart` | 신규 생성 |
| `data/dto/exchange_rate_dto.dart` | 신규 생성 |
| `data/dto/exchange_rate_dto.freezed.dart` | 자동 생성 (build_runner) |
| `data/dto/exchange_rate_dto.g.dart` | 자동 생성 (build_runner) |
| `data/api/exchange_rate_api.dart` | 신규 생성 |
| `data/api/exchange_rate_api.g.dart` | 자동 생성 (build_runner) |
| `data/repositories/exchange_rate_repository_impl.dart` | 신규 생성 |
| `presentation/currency/currency_calculator_viewmodel.dart` | 신규 생성 |
| `presentation/currency/currency_calculator_viewmodel.freezed.dart` | 자동 생성 (build_runner) |
| `presentation/currency/currency_calculator_screen.dart` | 수정 (ViewModel 연결) |
| `core/di/providers.dart` | 수정 (Provider 등록) |

---

## 구현 순서

```
1. Domain 계층
   ├─ exchange_rate_entity.dart (Freezed 모델)
   ├─ exchange_rate_repository.dart (인터페이스)
   └─ get_exchange_rate_usecase.dart

2. Data 계층
   ├─ exchange_rate_dto.dart (Freezed + json_serializable)
   ├─ exchange_rate_api.dart (Retrofit)
   ├─ build_runner 실행 → .g.dart / .freezed.dart 생성
   └─ exchange_rate_repository_impl.dart (캐시 + API)

3. DI
   └─ providers.dart — exchangeRateRepositoryProvider, exchangeRateViewModelProvider 등록

4. Presentation 계층
   ├─ currency_calculator_viewmodel.dart (State + Intent + Notifier)
   │   ├─ build(): getLatestRates() 호출
   │   ├─ 키 입력 처리 (_onKey 내부 로직)
   │   ├─ 환산 계산 (_evaluatedAmount)
   │   └─ 통화 전환 / 스왑
   └─ currency_calculator_screen.dart
       └─ StatefulWidget → ConsumerWidget 전환

5. 수동 테스트
   └─ 실기기/에뮬레이터에서 API 조회 → 환산 → 오프라인 fallback 확인
```

---

## 범위 외 (이번 작업 제외)

- **다중 통화 동시 표시** (1 → N 변환 UI) — 현재는 1:1 변환만 지원, 추후 별도 Phase
- **통화 즐겨찾기/순서 저장** — 설정 화면 구현 이후로 연기
- **환율 변동 알림** — 별도 Phase
- **단위 테스트 작성** — UseCase/ViewModel 테스트는 구현 완료 후 별도 작성
