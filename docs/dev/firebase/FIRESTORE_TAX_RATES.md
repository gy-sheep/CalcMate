# Firestore 세율 연동 구현 명세

> **브랜치**: `feat/firestore-tax-rates`
> **목적**: 실수령액 계산기의 하드코딩된 세율(4대보험 요율 + 소득세 산출 공식)을 Firestore에서 동적으로 읽어오도록 전환하여, 앱 재배포 없이 세율 변경에 대응한다

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../../architecture/ARCHITECTURE.md) 참고
> 환율 Firestore 패턴: [`FIREBASE_EXCHANGE_RATE_BACKEND.md`](FIREBASE_EXCHANGE_RATE_BACKEND.md) 참고

**데이터 흐름**

```
[Firestore tax_rates/latest]
        │
        ▼
[TaxRatesRemoteDataSource.fetchFromFirestore()]
        │
        ▼
[TaxRatesDto.fromJson() → TaxRates 변환]
        │
        ▼
[TaxRatesRepositoryImpl]
  ├── 1순위: SharedPreferences 캐시 (유효 시)
  ├── 2순위: Firestore 읽기 → 캐시 갱신
  ├── 3순위: 만료 캐시라도 반환
  └── 4순위: kFallbackTaxRates 폴백
        │
        ▼
[GetTaxRatesUseCase.execute()]
        │
        ▼
[SalaryCalculatorViewModel (AsyncNotifier)]
  │  build() → 세율 로딩 → CalculateSalaryUseCase 생성
  │  handleIntent(intent) → _recalculate()
  │
  ▼
[SalaryCalculatorState 갱신] → [화면 리렌더]
```

**작업 파일**

| 파일 | 작업 |
|------|------|
| `functions/src/index.ts` | 수정 — 간이세액표 시딩 Function 추가 |
| `functions/scripts/tax_table_2026.json` | 신규 — 2026년 간이세액표 JSON 데이터 |
| `firestore.rules` | 수정 — tax_rates 읽기 허용 규칙 추가 |
| `lib/domain/models/tax_rates.dart` | 수정 — `fromJson`/`toJson`, `incomeTaxTable` 필드 추가 |
| `lib/data/dto/tax_rates_dto.dart` | 신규 — Firestore 문서 → TaxRates 변환 DTO |
| `lib/data/datasources/tax_rates_remote_datasource.dart` | 신규 — Firestore 읽기 |
| `lib/data/datasources/tax_rates_local_datasource.dart` | 신규 — SharedPreferences 캐싱 |
| `lib/data/datasources/tax_rates_fallback.dart` | 신규 — kFallbackTaxRates 이동 |
| `lib/domain/repositories/tax_rates_repository.dart` | 신규 — Repository 인터페이스 |
| `lib/data/repositories/tax_rates_repository_impl.dart` | 신규 — 캐시 → Firestore → 폴백 정책 |
| `lib/domain/usecases/get_tax_rates_usecase.dart` | 신규 — Firestore 세율 조회 |
| `lib/domain/usecases/calculate_salary_usecase.dart` | 수정 — 간이세액표 2D 룩업 모드 추가 |
| `lib/presentation/salary_calculator/salary_calculator_viewmodel.dart` | 수정 — AsyncNotifier 전환 |
| `lib/core/di/providers.dart` | 수정 — 세율 관련 Provider 체인 추가 |
| `lib/core/constants/firebase_config.dart` | 수정 — tax_rates 상수 추가 |
| `lib/core/constants/cache_config.dart` | 수정 — 세율 캐시 키/TTL 추가 |
| `test/domain/usecases/calculate_salary_usecase_test.dart` | 수정 — 룩업 테스트 추가 |
| `test/data/repositories/tax_rates_repository_impl_test.dart` | 신규 — 캐시 정책 테스트 |

---

## 필요 데이터

세율 갱신 시 아래 데이터를 준비하여 시딩 스크립트에 반영한다.

| 제목 | 값 |
|------|-----|
| 국민연금 요율 | 0.0475 |
| 국민연금 하한액 | 390,000 |
| 국민연금 상한액 | 6,170,000 |
| 건강보험 요율 | 0.03595 |
| 장기요양 요율 (건보료 대비) | 0.1314 |
| 고용보험 요율 | 0.009 |
| 간이세액표 Excel 파일 | `근로소득 간이세액표.xlsx` |

> 4대보험 요율 6개는 스크립트에 직접 입력하고, 간이세액표는 Excel에서 자동 파싱한다.
> 자녀세액공제·1,000만원 초과 산식은 Excel에 포함되어 있으므로 별도 제공 불필요.

---

## 배경 및 문제

| 문제 | 영향 |
|------|------|
| 4대보험 요율이 `kFallbackTaxRates` 상수로 하드코딩 (2024년) | 2026년 현재 이미 요율이 변경됨 — 부정확한 계산 |
| 소득세를 산출 공식으로 추정 계산 | 저소득 구간 ~2% 오차, 고소득 구간 더 큰 오차 |
| 세율 변경 시 앱 재배포 필요 | 대응 지연, 사용자 신뢰도 저하 |

---

## 목표

- Firestore에서 4대보험 요율 + 간이세액표 데이터를 읽어와 계산에 사용
- 세율 변경 시 Firestore 문서만 업데이트하면 앱 재배포 없이 반영
- 오프라인/실패 시 로컬 캐시 → 폴백 상수로 graceful degradation
- 환율 계산기의 Firestore 패턴을 그대로 따라 코드 일관성 유지

---

## 1. 데이터 소스 및 갱신 전략

### 원본 데이터

| 데이터 | 출처 | 갱신 주기 | 갱신 방법 |
|--------|------|----------|----------|
| 간이세액표 (소득세) | 국세청 Excel (`근로소득 간이세액표.xlsx`) | 세법 개정 시 (보통 연초 2~3월) | Excel → JSON 변환 → Firestore 업로드 |
| 4대보험 요율 6개 | 각 공단 공지사항 | 매년 1월(건보/장기요양), 7월(국민연금 상·하한) | Firebase Console에서 수동 수정 |
| 1,000만원 초과 산식 | 간이세액표 Excel 동일 파일 | 간이세액표와 동일 | 간이세액표와 함께 업로드 |
| 자녀세액공제 금액 | 간이세액표 Excel `소득령 별표2` 시트 | 간이세액표와 동일 | 간이세액표와 함께 업로드 |

### 간이세액표 Excel 실제 구조

**시트 1: `소득령 별표2`** — 산출 공식 설명

- 특별소득공제 산출 공식
- 자녀세액공제: 1명 20,830원 / 2명 45,830원 / 3명+ 45,830원 + 초과 1명당 33,330원
- 11명 초과 부양가족 산식

**시트 2: `근로소득간이세액표`** — 룩업 테이블

| 항목 | 값 |
|------|-----|
| 데이터 행 | 646행 |
| 급여 범위 | 월 77만 ~ 1,000만원 (천원 단위 표기) |
| 급여 구간 | 77~150만: 5천원 / 150~300만: 1만원 / 300~1,000만: 2만원 |
| 부양가족 열 | 1~11명 (11개 열) |
| 세액 시작 | 월 106만원부터 (그 이하는 전부 0원) |
| 1,000만원 초과 | 행 651~662에 별도 산식 (텍스트) |

### 무비용 원칙 검증

세율 데이터 추가가 기존 Firebase 무료 한도에 미치는 영향:

| 항목 | 환율 (기존) | 세율 (추가) | 합계 | 무료 한도 | 사용률 |
|------|-----------|-----------|------|----------|--------|
| Functions 실행 | 720회/월 | 0회 (수동 업데이트) | 720회 | 2,000,000회/월 | 0.036% |
| Firestore 읽기 | DAU/일 | DAU/일 (24h 캐시) | DAU×2 | 50,000/일 | 실질 영향 없음 |
| Firestore 쓰기 | 24회/일 | ~0회 (연 1~2회) | ~24회 | 20,000/일 | 0.12% |
| Firestore 저장 | ~1KB | ~67KB | ~68KB | 1 GiB | 0.007% |

**모든 항목 무료 한도의 1% 미만. 기존 비용 범위를 벗어나지 않는다.**

> Firestore 읽기: 세율 캐시 TTL 24시간이고 모든 사용자가 두 계산기를 동시에 쓰지 않으므로,
> 기존 DAU 5만 기준에서 실질적으로 달라지는 게 없다.

---

## 2. Firestore 설계

### 컬렉션 구조

```
tax_rates/                              # 컬렉션
└── latest                              # 문서 (단일, ~67KB)
    │
    │── ── 4대보험 요율 ──
    ├── nationalPensionRate: 0.0475      # double — 국민연금 요율
    ├── nationalPensionMin: 390000       # int — 국민연금 하한
    ├── nationalPensionMax: 6170000      # int — 국민연금 상한
    ├── healthInsuranceRate: 0.03595     # double — 건강보험 요율
    ├── longTermCareRate: 0.1314         # double — 장기요양 요율
    ├── employmentInsuranceRate: 0.009   # double — 고용보험 요율
    │
    │── ── 간이세액표 ──
    ├── incomeTaxTable: [                # List<Map> — 646행 룩업 테이블
    │     { "min": 770, "max": 775, "taxes": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
    │     ...
    │     { "min": 2000, "max": 2010, "taxes": [19520, 14750, 6600, 3220, 0, 0, 0, 0, 0, 0, 0] },
    │     ...
    │     { "min": 9980, "max": 10000, "taxes": [...] },
    │   ]
    │
    │── ── 1,000만원 초과 산식 ──
    ├── overTenMillionBrackets: [        # List<Map> — 초과 구간 산식 상수
    │     { "min": 10000, "max": 14000, "rate": 0.35, "deduction": 15440000 },
    │     { "min": 14000, "max": 28000, "rate": 0.38, "deduction": 19940000 },
    │     { "min": 28000, "max": 30000, "rate": 0.40, "deduction": 25940000 },
    │     { "min": 30000, "max": 45000, "rate": 0.40, "deduction": 25940000 },
    │     { "min": 45000, "max": 87000, "rate": 0.42, "deduction": 35940000 },
    │     { "min": 87000, "max": 999999, "rate": 0.45, "deduction": 65940000 },
    │   ]
    │
    │── ── 자녀세액공제 ──
    ├── childTaxCredit: {                # Map — 8~20세 자녀 공제
    │     "one": 20830,
    │     "two": 45830,
    │     "perExtra": 33330
    │   }
    │
    │── ── 메타 ──
    ├── basedYear: 2026                  # int — 기준 연도
    └── updatedAt: 1709308800000         # int (Unix ms) — 마지막 갱신 시각
```

**`incomeTaxTable` 필드 규약**:
- `min`/`max`: 천원 단위 (Excel 원본 그대로). 앱에서 원 단위로 변환
- `taxes`: 부양가족 1~11명 소득세 배열 (index 0 = 1명, index 10 = 11명)
- `-` (세액 없음)은 `0`으로 저장

### 보안 규칙

`firestore.rules`에 추가:

```
match /tax_rates/{document} {
  allow read: if true;
  allow write: if false;
}
```

---

## 3. Firestore 데이터 시딩

### 3-1. Excel → JSON 변환 스크립트

간이세액표 Excel(646행 × 13열)을 수동 입력하는 것은 비현실적이므로,
Node.js 스크립트로 Excel을 파싱하여 Firestore에 업로드한다.

**스크립트 위치**: `functions/scripts/seed_tax_rates.ts`

**동작**:
1. `xlsx` 패키지로 Excel 파일 읽기
2. 시트 2 (`근로소득간이세액표`) 행 5~650 파싱 → `incomeTaxTable` JSON 배열
3. 시트 2 행 651~662 파싱 → `overTenMillionBrackets` JSON 배열
4. 시트 1 (`소득령 별표2`) → `childTaxCredit` 상수
5. 4대보험 요율 수동 입력값과 합쳐서 Firestore `tax_rates/latest` 문서에 `set()`

**실행 방법**:
```bash
cd functions
npx ts-node scripts/seed_tax_rates.ts
```

### 3-2. 4대보험 요율 (2026년 현행)

| 필드 | 값 | 비고 |
|------|-----|------|
| `nationalPensionRate` | 0.0475 | 2025년(4.5%) 대비 +0.25%p |
| `nationalPensionMin` | 390000 | 2024년(370,000) 대비 변경 |
| `nationalPensionMax` | 6170000 | 변동 없음 (2026.7월 변경 예정) |
| `healthInsuranceRate` | 0.03595 | 2025년(3.545%) 대비 +0.05%p |
| `longTermCareRate` | 0.1314 | 2025년(12.95%) 대비 인상 |
| `employmentInsuranceRate` | 0.009 | 변동 없음 |
| `basedYear` | 2026 | |

### 3-3. 향후 갱신 절차

**간이세액표 변경 시** (연 1회, 보통 2~3월):
1. 국세청에서 새 Excel 다운로드
2. `seed_tax_rates.ts` 스크립트 재실행
3. Firestore 자동 업데이트

**4대보험 요율 변경 시** (연 1~2회):
1. 각 공단 공지사항에서 새 요율 확인
2. Firebase Console → `tax_rates/latest` 문서에서 해당 필드 수동 수정

---

## 4. 설계 결정

### ADR-1: 간이세액표 2D 룩업 vs 산출 공식 유지

| | 2D 룩업 테이블 | 산출 공식 유지 |
|---|---|---|
| 정확도 | 국세청 공식 데이터와 100% 일치 | ~2% 오차 (특별소득공제 추정) |
| 데이터 크기 | ~67KB (646행 × 11열) | 상수 7개 |
| 갱신 방식 | Firestore 문서 교체 | 공식 변경 시 코드 수정 필요 |
| 구현 복잡도 | 순차 탐색 룩업 1개 | 10단계 알고리즘 유지 |

**결정**: 2D 룩업 테이블 도입. 정확도가 사용자 신뢰에 직결되고, Firestore 문서 1개로 관리할 수 있다.
산출 공식은 `incomeTaxTable`이 null일 때 폴백으로 유지한다.

### ADR-2: 캐시 TTL

4대보험 요율은 연 1~2회만 변경되므로 **24시간 TTL**로 설정한다 (환율의 1시간과 차별).

### ADR-3: ViewModel 비동기 전환

현재 `AutoDisposeNotifier` (동기) → `AutoDisposeAsyncNotifier`로 전환.
`build()`에서 세율을 비동기로 로딩하고, 로딩 완료 후 계산 수행.
UI는 `AsyncValue`로 로딩/에러/데이터 상태를 표현.
캐시 히트 시 즉시 로딩되므로 별도 shimmer 불필요.

### ADR-4: incomeTaxTable 단위

Excel 원본이 천원 단위이므로 Firestore에도 천원 단위로 저장한다.
앱에서 월급여(원 단위)를 1,000으로 나눠 룩업한다.
불필요한 데이터 변환을 줄이고, Excel 갱신 시 파싱 로직을 단순하게 유지한다.

---

## 5. 앱 구현 범위

### 5-1. `lib/domain/models/tax_rates.dart` — 모델 확장

TaxRates에 `incomeTaxTable`, `overTenMillionBrackets`, `childTaxCredit` 필드와 JSON 직렬화를 추가한다.

```dart
@freezed
class TaxRates with _$TaxRates {
  const factory TaxRates({
    required double nationalPensionRate,
    required int nationalPensionMin,
    required int nationalPensionMax,
    required double healthInsuranceRate,
    required double longTermCareRate,
    required double employmentInsuranceRate,
    required int basedYear,
    List<IncomeTaxBracket>? incomeTaxTable,
    List<OverTenMillionBracket>? overTenMillionBrackets,
    ChildTaxCredit? childTaxCredit,
  }) = _TaxRates;

  factory TaxRates.fromJson(Map<String, dynamic> json) =>
      _$TaxRatesFromJson(json);
}

@freezed
class IncomeTaxBracket with _$IncomeTaxBracket {
  const factory IncomeTaxBracket({
    required int min,       // 천원 단위
    required int max,       // 천원 단위
    required List<int> taxes,  // index 0~10 = 부양가족 1~11명
  }) = _IncomeTaxBracket;

  factory IncomeTaxBracket.fromJson(Map<String, dynamic> json) =>
      _$IncomeTaxBracketFromJson(json);
}

@freezed
class OverTenMillionBracket with _$OverTenMillionBracket {
  const factory OverTenMillionBracket({
    required int min,         // 천원 단위
    required int max,         // 천원 단위
    required double rate,     // 세율
    required int deduction,   // 누진공제액 (원)
  }) = _OverTenMillionBracket;

  factory OverTenMillionBracket.fromJson(Map<String, dynamic> json) =>
      _$OverTenMillionBracketFromJson(json);
}

@freezed
class ChildTaxCredit with _$ChildTaxCredit {
  const factory ChildTaxCredit({
    required int one,       // 자녀 1명 공제액 (20,830)
    required int two,       // 자녀 2명 공제액 (45,830)
    required int perExtra,  // 3명 이상 시 추가 1명당 (33,330)
  }) = _ChildTaxCredit;

  factory ChildTaxCredit.fromJson(Map<String, dynamic> json) =>
      _$ChildTaxCreditFromJson(json);
}
```

**설계 결정**:
- `incomeTaxTable`, `overTenMillionBrackets`, `childTaxCredit` 모두 nullable — null이면 기존 산출 공식 폴백
- 모든 하위 모델도 Freezed로 불변 보장

---

### 5-2. `lib/data/dto/tax_rates_dto.dart` — DTO

```dart
@freezed
class TaxRatesDto with _$TaxRatesDto {
  const factory TaxRatesDto({
    required double nationalPensionRate,
    required int nationalPensionMin,
    required int nationalPensionMax,
    required double healthInsuranceRate,
    required double longTermCareRate,
    required double employmentInsuranceRate,
    required int basedYear,
    List<Map<String, dynamic>>? incomeTaxTable,
    List<Map<String, dynamic>>? overTenMillionBrackets,
    Map<String, dynamic>? childTaxCredit,
    required int updatedAt,
  }) = _TaxRatesDto;

  factory TaxRatesDto.fromJson(Map<String, dynamic> json) =>
      _$TaxRatesDtoFromJson(json);
}

extension TaxRatesDtoX on TaxRatesDto {
  TaxRates toEntity() => TaxRates(
    nationalPensionRate: nationalPensionRate,
    nationalPensionMin: nationalPensionMin,
    nationalPensionMax: nationalPensionMax,
    healthInsuranceRate: healthInsuranceRate,
    longTermCareRate: longTermCareRate,
    employmentInsuranceRate: employmentInsuranceRate,
    basedYear: basedYear,
    incomeTaxTable: incomeTaxTable
        ?.map((e) => IncomeTaxBracket.fromJson(e)).toList(),
    overTenMillionBrackets: overTenMillionBrackets
        ?.map((e) => OverTenMillionBracket.fromJson(e)).toList(),
    childTaxCredit: childTaxCredit != null
        ? ChildTaxCredit.fromJson(childTaxCredit!) : null,
  );
}
```

---

### 5-3. `lib/data/datasources/tax_rates_remote_datasource.dart` — Firestore 읽기

```dart
class TaxRatesRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaxRatesRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<TaxRatesDto?> fetchFromFirestore() async {
    final doc = await _firestore
        .collection(FirebaseConfig.taxRatesCollection)
        .doc(FirebaseConfig.taxRatesDocument)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return TaxRatesDto.fromJson(doc.data()!);
  }
}
```

---

### 5-4. `lib/data/datasources/tax_rates_local_datasource.dart` — 로컬 캐시

```dart
class TaxRatesLocalDataSource {
  final SharedPreferences _prefs;

  TaxRatesLocalDataSource(this._prefs);

  TaxRates? getCachedRates() {
    final jsonStr = _prefs.getString(CacheConfig.taxRatesCacheKey);
    if (jsonStr == null) return null;
    try {
      return TaxRates.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      debugPrint('[TaxRatesLocal] cache parse failed: $e');
      return null;
    }
  }

  bool isCacheValid() {
    final ts = _prefs.getInt(CacheConfig.taxRatesCacheTimestampKey);
    if (ts == null) return false;
    return DateTime.now().millisecondsSinceEpoch - ts < CacheConfig.taxRatesTtlMs;
  }

  Future<void> cacheRates(TaxRates rates) async {
    await _prefs.setString(
        CacheConfig.taxRatesCacheKey, jsonEncode(rates.toJson()));
    await _prefs.setInt(CacheConfig.taxRatesCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch);
  }
}
```

---

### 5-5. `lib/data/datasources/tax_rates_fallback.dart` — 폴백 상수

`tax_rates.dart`에서 `kFallbackTaxRates`를 이 파일로 이동한다.

```dart
/// 2026년 기준 오프라인 폴백 상수.
/// Firestore·캐시 모두 실패 시 사용.
const kFallbackTaxRates = TaxRates(
  nationalPensionRate: 0.0475,
  nationalPensionMin: 390000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03595,
  longTermCareRate: 0.1314,
  employmentInsuranceRate: 0.009,
  basedYear: 2026,
  incomeTaxTable: null,  // 폴백은 산출 공식 사용
  overTenMillionBrackets: null,
  childTaxCredit: null,
);
```

---

### 5-6. `lib/domain/repositories/tax_rates_repository.dart` — 인터페이스

```dart
abstract class TaxRatesRepository {
  Future<TaxRates> getLatestRates();
}
```

---

### 5-7. `lib/data/repositories/tax_rates_repository_impl.dart` — 구현체

```dart
class TaxRatesRepositoryImpl implements TaxRatesRepository {
  final TaxRatesRemoteDataSource _remote;
  final TaxRatesLocalDataSource _local;

  TaxRatesRepositoryImpl({
    required TaxRatesRemoteDataSource remote,
    required TaxRatesLocalDataSource local,
  }) : _remote = remote, _local = local;

  @override
  Future<TaxRates> getLatestRates() async {
    // 1. 캐시 유효 → 즉시 반환
    if (_local.isCacheValid()) {
      return _local.getCachedRates()!;
    }

    try {
      // 2. Firestore 읽기
      final dto = await _remote.fetchFromFirestore();
      if (dto != null) {
        final entity = dto.toEntity();
        await _local.cacheRates(entity);
        return entity;
      }
    } catch (e) {
      debugPrint('[TaxRatesRepo] Firestore fetch failed: $e');
    }

    // 3. 만료 캐시라도 반환
    final expired = _local.getCachedRates();
    if (expired != null) return expired;

    // 4. 모든 소스 실패 → 폴백 상수
    return kFallbackTaxRates;
  }
}
```

---

### 5-8. `lib/domain/usecases/get_tax_rates_usecase.dart`

```dart
class GetTaxRatesUseCase {
  final TaxRatesRepository _repository;

  GetTaxRatesUseCase(this._repository);

  Future<TaxRates> execute() => _repository.getLatestRates();
}
```

---

### 5-9. `lib/domain/usecases/calculate_salary_usecase.dart` — 간이세액표 룩업 추가

`_calcIncomeTax`에 간이세액표 룩업 분기를 추가한다.

```dart
int _calcIncomeTax(int monthSalary, int dependents) {
  // 간이세액표가 있으면 룩업
  if (_rates.incomeTaxTable != null && _rates.incomeTaxTable!.isNotEmpty) {
    return _lookupIncomeTax(monthSalary, dependents);
  }
  // 없으면 기존 산출 공식 사용 (폴백)
  return _calcIncomeTaxByFormula(monthSalary, dependents);
}

/// 간이세액표 2D 룩업.
/// monthSalary: 원 단위, 테이블: 천원 단위.
int _lookupIncomeTax(int monthSalary, int dependents) {
  final salaryInThousand = monthSalary ~/ 1000;
  final depIndex = (dependents.clamp(1, 11) - 1);
  final table = _rates.incomeTaxTable!;

  // 테이블 범위 내 → 순차 탐색
  for (final bracket in table) {
    if (salaryInThousand >= bracket.min && salaryInThousand < bracket.max) {
      return bracket.taxes[depIndex];
    }
  }

  // 1,000만원 초과 → 초과 산식 적용
  if (_rates.overTenMillionBrackets != null) {
    return _calcOverTenMillion(monthSalary, dependents);
  }

  // 테이블 최저 미만 → 세액 0
  return 0;
}

/// 1,000만원 초과 산식.
/// Excel 행 651~662: "(10,000천원인 경우의 해당 세액) + 누진세율 적용"
int _calcOverTenMillion(int monthSalary, int dependents) {
  final depIndex = (dependents.clamp(1, 11) - 1);
  final table = _rates.incomeTaxTable!;

  // 10,000천원(1,000만원) 행의 세액을 기준값으로 사용
  final baseTax = table.last.taxes[depIndex];

  // 초과 구간 산식 적용
  final salaryInThousand = monthSalary ~/ 1000;
  for (final bracket in _rates.overTenMillionBrackets!) {
    if (salaryInThousand >= bracket.min && salaryInThousand < bracket.max) {
      final excess = monthSalary - 10000000;  // 1,000만원 초과분 (원)
      final adjusted = (excess * 0.98).floor();  // 98% 적용
      final additionalTax = (adjusted * bracket.rate - bracket.deduction).floor();
      return baseTax + additionalTax;
    }
  }

  return baseTax;
}
```

**설계 결정**: 기존 `_calcIncomeTax`를 `_calcIncomeTaxByFormula`로 이름 변경하고, 새 `_calcIncomeTax`에서 테이블 유무에 따라 분기한다.

---

### 5-10. `salary_calculator_viewmodel.dart` — AsyncNotifier 전환

```dart
final salaryCalculatorViewModelProvider =
    AsyncNotifierProvider.autoDispose<SalaryCalculatorViewModel, SalaryCalculatorState>(
        SalaryCalculatorViewModel.new);

class SalaryCalculatorViewModel
    extends AutoDisposeAsyncNotifier<SalaryCalculatorState> {
  late final CalculateSalaryUseCase _useCase;

  @override
  Future<SalaryCalculatorState> build() async {
    final getTaxRates = ref.read(getTaxRatesUseCaseProvider);
    final taxRates = await getTaxRates.execute();

    _useCase = CalculateSalaryUseCase(taxRates);

    const initial = SalaryCalculatorState();
    return _recalculate(initial);
  }

  void handleIntent(SalaryCalculatorIntent intent) {
    final current = state.valueOrNull;
    if (current == null) return;

    switch (intent) {
      case _TabSwitched(:final mode):
        _onTabSwitched(current, mode);
      case _SalaryChanged(:final salary):
        state = AsyncData(
            _recalculate(current.copyWith(salary: salary.clamp(0, 9999999999))));
      case _DirectInput(:final salary):
        state = AsyncData(
            _recalculate(current.copyWith(salary: salary.clamp(0, 9999999999))));
      case _DependentsChanged(:final dependents):
        state = AsyncData(
            _recalculate(current.copyWith(dependents: dependents.clamp(1, 11))));
    }
  }

  // _onTabSwitched, _recalculate 는 기존 로직 유지 (state → AsyncData 래핑)
}
```

---

### 5-11. `lib/core/di/providers.dart` — Provider 체인 추가

```dart
// ── 세율 (TaxRates) ──

final taxRatesRemoteDataSourceProvider =
    Provider<TaxRatesRemoteDataSource>((ref) {
  return TaxRatesRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

final taxRatesLocalDataSourceProvider =
    Provider<TaxRatesLocalDataSource>((ref) {
  return TaxRatesLocalDataSource(ref.read(sharedPreferencesProvider));
});

final taxRatesRepositoryProvider =
    Provider<TaxRatesRepository>((ref) {
  return TaxRatesRepositoryImpl(
    remote: ref.read(taxRatesRemoteDataSourceProvider),
    local: ref.read(taxRatesLocalDataSourceProvider),
  );
});

final getTaxRatesUseCaseProvider =
    Provider<GetTaxRatesUseCase>((ref) {
  return GetTaxRatesUseCase(ref.read(taxRatesRepositoryProvider));
});
```

---

### 5-12. 상수 파일 수정

**`lib/core/constants/firebase_config.dart`**:
```dart
abstract final class FirebaseConfig {
  static const exchangeRateCollection = 'exchange_rates';
  static const exchangeRateDocument = 'latest';

  static const taxRatesCollection = 'tax_rates';
  static const taxRatesDocument = 'latest';
}
```

**`lib/core/constants/cache_config.dart`**:
```dart
abstract final class CacheConfig {
  static const exchangeRateCacheKey = 'exchange_rate_cache';
  static const exchangeRateTtlMs = 3600000;

  static const taxRatesCacheKey = 'tax_rates_cache';
  static const taxRatesCacheTimestampKey = 'tax_rates_cache_ts';
  static const taxRatesTtlMs = 86400000;  // 24시간
}
```

---

## 6. 구현 순서

```
Phase 1: Firestore 데이터 준비
  1-1. firestore.rules에 tax_rates 읽기 규칙 추가 + 배포
  1-2. Excel → JSON 변환 스크립트 작성 (functions/scripts/seed_tax_rates.ts)
  1-3. 스크립트 실행 → Firestore tax_rates/latest 문서 시딩
  1-4. Firebase Console에서 데이터 확인

Phase 2: 도메인 모델
  2-1. tax_rates.dart 확장 (IncomeTaxBracket, OverTenMillionBracket, ChildTaxCredit)
  2-2. build_runner 실행

Phase 3: Data 계층
  3-1. tax_rates_dto.dart (DTO + toEntity)
  3-2. tax_rates_remote_datasource.dart (Firestore 읽기)
  3-3. tax_rates_local_datasource.dart (SharedPreferences 캐시)
  3-4. tax_rates_fallback.dart (폴백 상수 이동, 2026년 값으로 갱신)
  3-5. tax_rates_repository_impl.dart (4단계 캐시 정책)

Phase 4: Domain 계층
  4-1. tax_rates_repository.dart (인터페이스)
  4-2. get_tax_rates_usecase.dart

Phase 5: DI + 상수
  5-1. providers.dart에 세율 Provider 체인 추가
  5-2. firebase_config.dart, cache_config.dart 상수 추가

Phase 6: UseCase 수정
  6-1. calculate_salary_usecase.dart — 룩업 분기 + 초과 산식

Phase 7: ViewModel + UI
  7-1. ViewModel AsyncNotifier 전환
  7-2. Screen AsyncValue.when 처리

Phase 8: 테스트
  8-1. calculate_salary_usecase_test.dart — 룩업 모드 테스트
  8-2. tax_rates_repository_impl_test.dart — 캐시 정책 테스트
  8-3. 수동 UI 확인
```

---

## 7. 범위 외 (이번 작업 제외)

- **Firebase Function 자동 갱신** (`scheduledTaxRateRefresh`) — 연 1회 변경이므로 수동 시딩으로 충분
- **기준 연도 표시 UI** — `basedYear`를 화면에 표시하는 것은 UI 개선 시 추가
- **비과세 항목 설정** (식대, 차량유지비) — v2 예정
- **세전/세후 역산** — v2 예정
- **자녀세액공제 UI** — 현재 앱에 자녀 수 입력 UI 없음, 별도 Phase
