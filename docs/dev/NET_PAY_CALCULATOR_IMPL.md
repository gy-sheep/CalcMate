# 실수령액 계산기 구현 명세

> **브랜치**: `dev`
> **목적**: 슬라이더 + 미세 조절 + 직접 입력으로 급여를 시뮬레이션하고, Firestore 세율 데이터 기반으로 실수령액·공제 내역을 실시간 계산하는 계산기 구현

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고
> Firebase 백엔드 상세: [`docs/dev/firebase/FIREBASE_TAX_RATE_BACKEND.md`](firebase/FIREBASE_TAX_RATE_BACKEND.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `functions/src/taxRates.ts` | 신규 — 간이세액표 자동 파싱 Scheduled Function + HTTP 트리거 |
| `lib/data/models/tax_rates_model.dart` | 신규 — Firestore 응답 Freezed 모델 |
| `lib/data/datasources/tax_rates_remote_datasource.dart` | 신규 — Firestore 조회 DataSource |
| `lib/data/repositories/tax_rates_repository_impl.dart` | 신규 — 오프라인 폴백 포함 Repository 구현 |
| `lib/domain/models/tax_rates.dart` | 신규 — 도메인 TaxRates Freezed 모델 |
| `lib/domain/models/net_pay_state.dart` | 신규 — UI 전체 상태 Freezed 모델 |
| `lib/domain/repositories/tax_rates_repository.dart` | 신규 — Repository 인터페이스 |
| `lib/domain/usecases/fetch_tax_rates_usecase.dart` | 신규 — Firestore 세율 조회 UseCase |
| `lib/domain/usecases/calculate_net_pay_usecase.dart` | 신규 — 실수령액 계산 UseCase |
| `lib/core/di/providers.dart` | 수정 — taxRates 관련 Provider 추가 |
| `lib/presentation/net_pay_calculator/net_pay_calculator_viewmodel.dart` | 신규 — ViewModel (Notifier) |
| `lib/presentation/net_pay_calculator/net_pay_calculator_screen.dart` | 수정 — StatefulWidget → ConsumerWidget, ViewModel 연결 |
| `lib/presentation/net_pay_calculator/net_pay_calculator_colors.dart` | 유지 — 색상 상수 (변경 없음) |
| `lib/presentation/net_pay_calculator/widgets/salary_display.dart` | 신규 — 급여 입력 표시 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/salary_slider.dart` | 신규 — 슬라이더 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/adjust_bar.dart` | 신규 — 미세 조절 바 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/result_card.dart` | 신규 — 실수령액 결과 카드 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/deduction_card.dart` | 신규 — 공제 내역 카드 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/dependents_bar.dart` | 신규 — 부양가족 수 조절기 위젯 분리 |
| `lib/presentation/net_pay_calculator/widgets/keypad_modal.dart` | 신규 — 키패드 바텀시트 위젯 분리 |
| `test/domain/usecases/calculate_net_pay_usecase_test.dart` | 신규 — 계산 로직 단위 테스트 |
| `test/domain/usecases/fetch_tax_rates_usecase_test.dart` | 신규 — 세율 조회 UseCase 단위 테스트 |

**데이터 흐름**

```
[Firestore tax_rates/latest]
        │  FetchTaxRatesUseCase
        ▼
[TaxRatesRepository] ──(오프라인 폴백)──▶ [kFallbackTaxRates 상수]
        │
        ▼
[NetPayCalculatorViewModel (AsyncNotifier)]
        │  handleIntent(intent)
        │
        ├── SalaryChanged    → _salary 업데이트 → CalculateNetPayUseCase
        ├── TabSwitched      → _salary 환산 → CalculateNetPayUseCase
        ├── UnitChanged      → _unit 업데이트
        ├── DependentsChanged→ _dependents 업데이트 → CalculateNetPayUseCase
        └── DirectInput      → _salary 업데이트 → CalculateNetPayUseCase
                │
                ▼
        [NetPayState 갱신] ──▶ [화면 리렌더]
```

---

## 테마 / 색상 (UI 프리뷰에서 확정)

**콘셉트**: 계약서·공식 문서 느낌 — 크림 종이 배경 + 딥 앤틱 골드 + 버건디 도장

| 역할 | 색상 상수 | 값 |
|------|-----------|-----|
| 화면 배경 (위) | `kNetPayBgTop` | `#F5F0E6` (따뜻한 크림) |
| 화면 배경 (아래) | `kNetPayBgBottom` | `#EDE8D8` |
| 강조색 (확인 버튼) | `kNetPayAccent` | `#8B1A2E` (딥 버건디) |
| 골드 (탭·결과·버튼) | `kNetPayGold` | `#8B6914` (딥 앤틱 골드) |
| 카드 배경 | `kNetPayCardBg` | `#F5EFDF` (양피지) |
| 카드 테두리 | `kNetPayCardBorder` | `#D8C9A8` |
| 결과 카드 배경 | `kNetPayResultBg` | `#EEE4CC` (진한 양피지) |
| 공제 카드 배경 | `kNetPayDeductionBg` | `#F0E8D4` |
| 텍스트 주색 | `kNetPayTextPrimary` | `#1A2540` (네이비 잉크) |
| 텍스트 보조색 | `kNetPayTextSecondary` | `#6B7A99` |

**골드가 적용되는 요소**: 탭 활성 인디케이터, 슬라이더 트랙·썸, 미세 조절 단위 버튼, 실수령액 금액, 부양가족 수 숫자, 부양가족 [−][+] 버튼, 단위 선택 팝업 체크마크

**버건디가 적용되는 요소**: 키패드 모달 확인 버튼

---

## 구현 범위

### 1. Firebase Functions — `functions/src/taxRates.ts`

상세 명세: [`docs/dev/firebase/FIREBASE_TAX_RATE_BACKEND.md`](firebase/FIREBASE_TAX_RATE_BACKEND.md)

**주요 구성 요소**

- `scheduledTaxRateRefresh`: 매년 1월 15일 자동 실행, 국세청 Excel 파싱 → Firestore 저장
- `refreshTaxRates`: HTTP 트리거, 수동 갱신용
- xlsx 패키지로 간이세액표 2D 배열 파싱

**Firestore 문서 구조** (`tax_rates/latest`)

```ts
{
  nationalPensionRate: 0.045,
  nationalPensionMin: 370000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03545,
  longTermCareRate: 0.1295,        // 건강보험료 대비 요율
  employmentInsuranceRate: 0.009,
  incomeTaxTable: number[][],       // [월급구간][부양가족수] 2D 배열
  basedYear: 2025,
  updatedAt: Timestamp,
}
```

---

### 2. `lib/domain/models/tax_rates.dart`

**주요 구성 요소**

```dart
@freezed
class TaxRates with _$TaxRates {
  const factory TaxRates({
    required double nationalPensionRate,
    required int    nationalPensionMin,
    required int    nationalPensionMax,
    required double healthInsuranceRate,
    required double longTermCareRate,        // 건보료 대비 비율
    required double employmentInsuranceRate,
    required List<List<int>> incomeTaxTable, // [급여구간][부양가족-1]
    required int    basedYear,
  }) = _TaxRates;
}

// 오프라인 폴백 상수
const kFallbackTaxRates = TaxRates(
  nationalPensionRate: 0.045,
  nationalPensionMin: 370000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03545,
  longTermCareRate: 0.1295,
  employmentInsuranceRate: 0.009,
  incomeTaxTable: [...],  // 2024년 기준 하드코딩
  basedYear: 2024,
);
```

---

### 3. `lib/domain/models/net_pay_state.dart`

```dart
enum SalaryMode { monthly, annual }

enum AdjustUnit {
  man(10000, '만원'),
  tenMan(100000, '10만'),
  hundredMan(1000000, '100만'),
  cheonMan(10000000, '천만');
}

@freezed
class NetPayState with _$NetPayState {
  const factory NetPayState({
    @Default(SalaryMode.annual) SalaryMode mode,
    @Default(45000000) int salary,
    @Default(1) int dependents,
    @Default(AdjustUnit.hundredMan) AdjustUnit unit,
    // 계산 결과
    @Default(0) int nationalPension,
    @Default(0) int healthInsurance,
    @Default(0) int longTermCare,
    @Default(0) int employmentInsurance,
    @Default(0) int incomeTax,
    @Default(0) int localTax,
    // 로딩/에러
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _NetPayState;

  // computed getters (const factory 패턴 → extension으로)
}

extension NetPayStateX on NetPayState {
  int get monthSalary => mode == SalaryMode.monthly ? salary : (salary / 12).round();
  int get totalDeduction => nationalPension + healthInsurance + longTermCare
      + employmentInsurance + incomeTax + localTax;
  int get netPay => monthSalary > 0 ? (monthSalary - totalDeduction).clamp(0, 999999999) : 0;
  int get netPayAnnual => netPay * 12;
}
```

---

### 4. `lib/domain/usecases/calculate_net_pay_usecase.dart`

**주요 구성 요소**

```dart
class CalculateNetPayUseCase {
  final TaxRates rates;

  DeductionResult execute({required int monthSalary, required int dependents});
}

class DeductionResult {
  final int nationalPension;
  final int healthInsurance;
  final int longTermCare;
  final int employmentInsurance;
  final int incomeTax;
  final int localTax;
}
```

**계산 로직**

```
국민연금   = clamp(monthSalary, min, max) × nationalPensionRate → floor
건강보험   = monthSalary × healthInsuranceRate → (÷10 → floor × 10)  // 10원 단위 절사
장기요양   = 건강보험료 × longTermCareRate → floor
고용보험   = monthSalary × employmentInsuranceRate → floor
소득세     = incomeTaxTable[급여구간][dependents - 1]  (구간 이진탐색)
지방소득세 = 소득세 × 0.1 → floor
```

**설계 결정**

- UseCase에 `TaxRates`를 생성자 주입: 테스트 시 임의 세율 주입 가능
- 간이세액표 구간 조회는 이진탐색 (O(log n)) — 구간 수 약 40개로 선형도 무방하나 일관성 유지

---

### 5. `lib/domain/usecases/fetch_tax_rates_usecase.dart`

```dart
class FetchTaxRatesUseCase {
  final TaxRatesRepository repository;
  Future<TaxRates> execute();  // 실패 시 kFallbackTaxRates 반환
}
```

---

### 6. `lib/data/` — DataSource / Repository

**`TaxRatesRemoteDataSource`**
- `Future<TaxRatesModel> fetchLatest()` — Firestore `tax_rates/latest` 조회
- 오프라인·오류 시 `FirebaseException` 그대로 throw

**`TaxRatesRepositoryImpl`**
- `fetchLatest()` 호출 → 실패 시 catch → `kFallbackTaxRates` 반환 + 오류 로그

---

### 7. `lib/core/di/providers.dart` 추가 Provider

```dart
final taxRatesRepositoryProvider = Provider<TaxRatesRepository>(...);
final fetchTaxRatesUseCaseProvider = Provider<FetchTaxRatesUseCase>(...);
final calculateNetPayUseCaseProvider = Provider.family<CalculateNetPayUseCase, TaxRates>(...);
final netPayCalculatorProvider = AsyncNotifierProvider<NetPayCalculatorViewModel, NetPayState>(...);
```

---

### 8. `lib/presentation/net_pay_calculator/net_pay_calculator_viewmodel.dart`

**Intent 목록**

```dart
sealed class NetPayIntent {
  const factory NetPayIntent.salaryChanged(int salary) = SalaryChanged;
  const factory NetPayIntent.tabSwitched(SalaryMode mode) = TabSwitched;
  const factory NetPayIntent.unitChanged(AdjustUnit unit) = UnitChanged;
  const factory NetPayIntent.adjust(int delta) = Adjust;
  const factory NetPayIntent.directInput(int salary) = DirectInput;
  const factory NetPayIntent.dependentsChanged(int dependents) = DependentsChanged;
}
```

**ViewModel 구조**

```dart
class NetPayCalculatorViewModel extends AsyncNotifier<NetPayState> {
  Future<NetPayState> build() async {
    // FetchTaxRatesUseCase 실행 → TaxRates 로드
    // 초기 상태 계산 후 반환
  }

  void handleIntent(NetPayIntent intent) {
    // switch on intent → state 업데이트 + 재계산
  }

  NetPayState _recalculate(NetPayState s, TaxRates rates) {
    final result = CalculateNetPayUseCase(rates)
        .execute(monthSalary: s.monthSalary, dependents: s.dependents);
    return s.copyWith(...result);
  }
}
```

---

### 9. `lib/presentation/net_pay_calculator/` 위젯 분리

프리뷰 단계에서 한 파일에 작성된 위젯을 `widgets/` 폴더로 분리한다.

| 위젯 클래스 | 분리 파일 | 비고 |
|------------|-----------|------|
| `SalaryDisplay` | `widgets/salary_display.dart` | 급여 표시 + 키패드 트리거 |
| `SalarySlider` | `widgets/salary_slider.dart` | 슬라이더 + 범위 레이블 |
| `AdjustBar` | `widgets/adjust_bar.dart` | [−] [단위▾] [+] 미세 조절 바 |
| `ResultCard` | `widgets/result_card.dart` | 실수령액 결과 (금액 우측 정렬) |
| `DeductionCard` | `widgets/deduction_card.dart` | 공제 내역 리스트 |
| `DependentsBar` | `widgets/dependents_bar.dart` | 고정 하단 부양가족 조절기 |
| `KeypadModal` | `widgets/keypad_modal.dart` | 직접 입력 바텀시트 |

**분리 후 `net_pay_calculator_screen.dart` 역할**

- ViewModel watch + `handleIntent` 호출 전달
- 위젯 트리 조합만 담당 (150줄 이내 목표)
- `ConsumerWidget` 사용

---

## 구현 순서

```
1. TDD: calculate_net_pay_usecase_test.dart 작성
   └─ 국민연금 상한·하한 경계값, 건강보험 10원 절사, 소득세 구간 테스트

2. 도메인 모델 구현
   └─ tax_rates.dart, net_pay_state.dart, AdjustUnit enum

3. CalculateNetPayUseCase 구현 (테스트 통과 목표)
   └─ 간이세액표 2024년 기준 데이터 하드코딩 (kFallbackTaxRates용)

4. TDD: fetch_tax_rates_usecase_test.dart 작성 (Mock repository 사용)

5. 데이터 계층 구현
   └─ TaxRatesModel, TaxRatesRemoteDataSource, TaxRatesRepositoryImpl

6. FetchTaxRatesUseCase 구현

7. DI 연결 (providers.dart)

8. ViewModel 구현
   └─ build() → 세율 로드 + 초기 계산
   └─ handleIntent() 각 케이스 처리

9. 화면 위젯 분리 (widgets/ 폴더)
   └─ 프리뷰 StatefulWidget 로직 → ViewModel로 이전

10. net_pay_calculator_screen.dart ConsumerWidget 전환

11. Firebase Functions 배포
    └─ FIREBASE_TAX_RATE_BACKEND.md 절차 참고
```

---

## 간이세액표 데이터 처리

### 구조

```dart
// incomeTaxTable[i] = 급여 구간 i의 부양가족별 세액 배열
// incomeTaxTable[i][j] = 부양가족 (j+1)명 기준 소득세
// 급여 구간 경계값은 kIncomeTaxBrackets 별도 상수

const kIncomeTaxBrackets = [1060000, 1500000, 2000000, ...]; // 원 단위
```

### 구간 조회 로직

```dart
int lookupIncomeTax(List<List<int>> table, int monthSalary, int dependents) {
  // 이진탐색으로 구간 index 찾기
  // dependents.clamp(1, 11) - 1 → 열 index
  // 최고 구간 초과 시 마지막 행 적용
}
```

---

## 범위 외 (이번 작업 제외)

- **비과세 항목 설정** (식대, 차량유지비) — v2 예정
- **세전/세후 역산** — v2 예정
- **두 연봉 비교 모드** — v2 예정
- **요율 연도 선택** — v2 예정
- **Firebase Functions 자동 배포 CI** — 수동 배포로 우선 진행
