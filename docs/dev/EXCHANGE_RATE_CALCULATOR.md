# 환율 계산기 구현 명세

> **브랜치**: `feat/exchange_rate`
> **목적**: 목업 기반 환율 계산기 스크린을 Clean Architecture로 전환하고, Firebase Firestore를 통해 환율 데이터를 조회한다.

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
│   ├── datasources/
│   │   ├── exchange_rate_remote_datasource.dart        [신규] Firestore + Firebase Function 호출
│   │   └── exchange_rate_local_datasource.dart         [신규] SharedPreferences 캐시
│   ├── dto/
│   │   └── exchange_rate_dto.dart                      [신규] Firestore 문서 → Dart 매핑 DTO
│   └── repositories/
│       └── exchange_rate_repository_impl.dart          [신규] Repository 구현체 (Remote + Local 캐시)
└── presentation/
    └── currency/
        ├── currency_calculator_screen.dart             [수정] StatefulWidget → ConsumerWidget, ViewModel 연결
        └── currency_calculator_viewmodel.dart          [신규] ExchangeRateViewModel (Notifier)
```

**데이터 흐름 (구조 B: Firestore 직접 읽기)**

```
[CurrencyCalculatorScreen]
        │ handleIntent()
        ▼
[ExchangeRateViewModel]  ──── build() 시 자동 조회
        │ GetExchangeRateUseCase.execute()
        ▼
[ExchangeRateRepository] (인터페이스)
        │
        ├── 로컬 캐시 HIT (1시간 이내)
        │       └─→ SharedPreferences 반환
        │
        └── 로컬 캐시 MISS / 만료
                │
                ▼
        [RemoteDataSource]
                │
                ├── Firestore 읽기 (환율 문서)
                │       ├── TTL 유효 → 데이터 반환 + 로컬 캐시 갱신
                │       └── TTL 만료 → Firebase Function 호출 (HTTP 트리거)
                │                        → Function이 Open Exchange Rates API 호출
                │                        → Firestore 업데이트 (Double Check Locking)
                │                        → 갱신된 데이터 반환
                │
                └── 실패 시 → 만료된 로컬 캐시라도 반환 (오프라인 fallback)
```

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| `currency_calculator_screen.dart`가 목업 데이터를 파일 내에 직접 보유 | 실제 환율 반영 불가 |
| 비즈니스 로직(환산, 수식 처리)이 View에 혼재 | 테스트 불가, 재사용 불가 |
| 네트워크 오류 / 오프라인 시 대응 없음 | 앱 사용 불가 |
| ViewModel 없이 `StatefulWidget`으로만 구성 | MVVM 패턴 불일치 |
| 클라이언트에서 직접 외부 API를 호출하면 사용자 수 증가 시 API 호출 한도 초과 | 확장성 없음 |

---

## 목표

- Firebase Firestore에서 환율 데이터를 조회한다 (앱 → Firestore 직접 읽기)
- TTL 만료 시에만 Firebase Function을 트리거하여 Open Exchange Rates API를 호출한다
- Clean Architecture 3계층을 준수한다 (`Presentation → Domain ← Data`)
- 오프라인 또는 오류 시 `SharedPreferences` 로컬 캐시로 fallback 한다
- 로컬 캐시 유효 기간: **1시간** (Firestore TTL과 동일)
- Open Exchange Rates는 USD 기준 환율만 제공하므로, **교차환율 계산**으로 모든 통화 쌍 변환을 지원한다
- ViewModel이 모든 상태와 인텐트를 담당한다

---

## 핵심 설계: 교차환율 계산

Open Exchange Rates 무료 플랜은 **USD 기준 환율만 제공**한다.

```json
{
  "base": "USD",
  "rates": { "KRW": 1320, "JPY": 150, "EUR": 0.92 }
}
```

**모든 통화 쌍 변환 공식**:

```
A → B 환율 = USD→B / USD→A

예시:
KRW → JPY = 150 / 1320 = 0.1136
EUR → KRW = 1320 / 0.92 = 1434.78
JPY → USD = 1 / 150 = 0.00667
```

이 교차환율 계산은 **ViewModel에서 수행**한다. Firestore에는 USD 기준 원본 데이터를 그대로 저장하고, 변환은 클라이언트에서 처리한다.

---

## 구현 범위

### 1. `domain/models/exchange_rate_entity.dart` — 환율 Entity

Freezed 불변 객체. 도메인 계층의 환율 데이터 표현.

**주요 구성 요소**

- `base` (String): 기준 통화 코드 — 항상 `'USD'`
- `rates` (Map\<String, double\>): USD 대비 각 통화의 환율 (예: `{'KRW': 1320, 'JPY': 150}`)
- `fetchedAt` (DateTime): 조회 시각 — 로컬 캐시 유효성 판단 기준
- `timestamp` (int): Firestore 문서의 갱신 시각 (Unix ms) — Firestore TTL 판단 기준

**설계 결정**

- `fetchedAt`은 앱이 데이터를 받은 시각 (로컬 캐시용), `timestamp`는 Firestore에 저장된 원본 시각 (TTL 판단용)

---

### 2. `domain/repositories/exchange_rate_repository.dart` — Repository 인터페이스

Domain 계층이 Data 계층에 의존하지 않도록 인터페이스만 정의한다.

**주요 구성 요소**

- `getLatestRates()` → `Future<ExchangeRateEntity>`: 최신 환율 조회. 로컬 캐시 → Firestore → Function 호출 순서로 fallback

---

### 3. `domain/usecases/get_exchange_rate_usecase.dart` — 환율 조회 UseCase

Repository를 주입받아 `execute()`를 호출하는 단일 책임 UseCase.

**주요 구성 요소**

- `execute()` → `Future<ExchangeRateEntity>`: Repository의 `getLatestRates()`를 위임 호출

---

### 4. `data/dto/exchange_rate_dto.dart` — Firestore 문서 DTO

Firestore 문서 데이터를 Dart 객체로 매핑하고, Entity로 변환하는 책임을 가진다.

**Firestore 문서 구조 (참고)**

```json
{
  "base": "USD",
  "rates": { "KRW": 1320, "JPY": 150, "EUR": 0.92, ... },
  "timestamp": 1709308800000,
  "source": "open_exchange_rates"
}
```

**주요 구성 요소**

- `ExchangeRateDto` (Freezed + json_serializable): `base`, `rates`, `timestamp`, `source` 필드
- `toEntity()` 확장 메서드: DTO → `ExchangeRateEntity` 변환. `fetchedAt`을 현재 시각으로 주입

---

### 5. `data/datasources/exchange_rate_remote_datasource.dart` — Remote DataSource

Firebase Firestore 읽기 및 Firebase Function HTTP 트리거 호출을 담당한다.

**주요 구성 요소**

- `fetchFromFirestore()` → `Future<ExchangeRateDto?>`: Firestore `exchange_rates/latest` 문서 읽기
- `triggerRefresh()` → `Future<ExchangeRateDto>`: Firebase Function HTTP 엔드포인트 호출. Function이 Open Exchange Rates API를 호출하고 Firestore를 갱신한 뒤 최신 데이터를 반환

**설계 결정**

- Firestore 문서 경로: `exchange_rates/latest` (단일 문서)
- TTL 판단: `timestamp` + 1시간(3,600,000ms) < 현재 시각이면 만료
- Firestore SDK를 직접 사용 (Retrofit이 아닌 `cloud_firestore` 패키지)

---

### 6. `data/datasources/exchange_rate_local_datasource.dart` — Local DataSource

SharedPreferences를 이용한 로컬 캐시. 오프라인 fallback 역할.

**주요 구성 요소**

- `getCachedRates()` → `ExchangeRateEntity?`: 캐시된 환율 반환
- `cacheRates(ExchangeRateEntity)`: 환율 데이터 로컬 저장
- `isCacheValid()` → `bool`: 캐시 저장 시각 기준 1시간 이내인지 확인

**설계 결정**

- 캐시 키: `'exchange_rate_cache'`
- JSON 문자열로 직렬화하여 저장

---

### 7. `data/repositories/exchange_rate_repository_impl.dart` — Repository 구현체

3단계 fallback 전략을 구현하는 Repository 구현체.

**조회 전략**

```
1. 로컬 캐시 (SharedPreferences)
   └─ 유효(1시간 이내) → 즉시 반환
   └─ 만료 또는 없음 → 2단계

2. Firestore 직접 읽기
   └─ TTL 유효(1시간 이내) → 반환 + 로컬 캐시 갱신
   └─ TTL 만료 → 3단계

3. Firebase Function HTTP 트리거
   └─ Function이 Double Check Locking으로 API 호출
   └─ 갱신된 데이터 반환 + 로컬 캐시 갱신
   └─ 실패 시 → 만료된 로컬 캐시라도 반환 (오프라인 fallback)
   └─ 캐시도 없으면 → 예외 throw
```

---

### 8. `presentation/currency/currency_calculator_viewmodel.dart` — ViewModel

**주요 구성 요소**

- `ExchangeRateState` (Freezed): 아래 필드로 구성
  - `rates` (Map\<String, double\>, 기본값 `{}`): USD 기준 전체 환율 맵
  - `fromCode` (String, 기본값 `'USD'`): 출발 통화 코드
  - `toCode` (String, 기본값 `'KRW'`): 도착 통화 코드
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

**교차환율 변환 메서드**

```dart
double convert(double amount, String from, String to) {
  final fromRate = rates[from]!;  // USD → from
  final toRate = rates[to]!;      // USD → to
  return amount * (toRate / fromRate);
}
```

**설계 결정**

- `AsyncNotifier` 대신 `Notifier` 사용: UI 상태(input, isFromActive 등)와 비동기 로딩 상태를 단일 State로 관리. `isLoading` 플래그로 로딩 표현
- `rates`는 USD 기준 전체 맵 유지: 통화 전환 시 API 재호출 없이 교차환율로 즉시 계산 가능

---

### 9. `presentation/currency/currency_calculator_screen.dart` — View 수정

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
| `data/datasources/exchange_rate_remote_datasource.dart` | 신규 생성 |
| `data/datasources/exchange_rate_local_datasource.dart` | 신규 생성 |
| `data/repositories/exchange_rate_repository_impl.dart` | 신규 생성 |
| `presentation/currency/currency_calculator_viewmodel.dart` | 신규 생성 |
| `presentation/currency/currency_calculator_viewmodel.freezed.dart` | 자동 생성 (build_runner) |
| `presentation/currency/currency_calculator_screen.dart` | 수정 (ViewModel 연결) |
| `core/di/providers.dart` | 수정 (Provider 등록) |
| `pubspec.yaml` | 수정 (firebase_core, cloud_firestore 의존성 추가) |

---

## 구현 순서

```
1. Firebase 프로젝트 설정 (별도 문서: FIREBASE_EXCHANGE_RATE_BACKEND.md 참고)
   └─ Firebase 프로젝트 생성, FlutterFire 연동, Firestore 보안 규칙

2. Domain 계층
   ├─ exchange_rate_entity.dart (Freezed 모델)
   ├─ exchange_rate_repository.dart (인터페이스)
   └─ get_exchange_rate_usecase.dart

3. Data 계층
   ├─ exchange_rate_dto.dart (Freezed + json_serializable)
   ├─ exchange_rate_remote_datasource.dart (Firestore + Function 호출)
   ├─ exchange_rate_local_datasource.dart (SharedPreferences)
   ├─ build_runner 실행 → .g.dart / .freezed.dart 생성
   └─ exchange_rate_repository_impl.dart (3단계 fallback)

4. DI
   └─ providers.dart — Repository, UseCase, ViewModel Provider 등록

5. Presentation 계층
   ├─ currency_calculator_viewmodel.dart (State + Intent + Notifier)
   │   ├─ build(): getLatestRates() 호출
   │   ├─ 키 입력 처리 (_onKey 내부 로직)
   │   ├─ 교차환율 계산 (convert 메서드)
   │   └─ 통화 전환 / 스왑
   └─ currency_calculator_screen.dart
       └─ StatefulWidget → ConsumerWidget 전환

6. 수동 테스트
   └─ 실기기/에뮬레이터에서 Firestore 조회 → 교차환율 변환 → 오프라인 fallback 확인
```

---

## 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.x.x
  cloud_firestore: ^5.x.x
```

---

## 범위 외 (이번 작업 제외)

- **Firebase Function 구현** — 별도 문서 `FIREBASE_EXCHANGE_RATE_BACKEND.md`에서 다룸
- **다중 통화 동시 표시** (1 → N 변환 UI) — 현재는 1:1 변환만 지원, 추후 별도 Phase
- **통화 즐겨찾기/순서 저장** — 설정 화면 구현 이후로 연기
- **환율 변동 알림** — 별도 Phase
- **단위 테스트 작성** — UseCase/ViewModel 테스트는 구현 완료 후 별도 작성
