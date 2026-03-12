# 실수령액 계산기 구현 명세

> **브랜치**: `feat/salary-calculator`
> **목적**: 슬라이더 + 미세 조절 + 직접 입력으로 급여를 시뮬레이션하고, 실수령액·공제 내역을 실시간 계산하는 계산기 구현

---

## 프로젝트 구조 및 작업 범위

> 기본 아키텍처: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고
> Firebase 백엔드 상세: [`docs/dev/firebase/FIREBASE_TAX_RATE_BACKEND.md`](firebase/FIREBASE_TAX_RATE_BACKEND.md) 참고

**작업 파일**

| 파일 | 작업 |
|------|------|
| `lib/domain/models/tax_rates.dart` | 신규 — 도메인 TaxRates Freezed 모델 (Firestore 연동 후 IncomeTaxBracket 등 확장) |
| `lib/domain/models/salary_calculator_state.dart` | 신규 — UI 전체 상태 Freezed 모델 |
| `lib/domain/usecases/calculate_salary_usecase.dart` | 신규 — 실수령액 계산 UseCase (간이세액표 산출 공식) |
| `lib/presentation/salary_calculator/salary_calculator_viewmodel.dart` | 신규 — ViewModel (AutoDisposeNotifier) |
| `lib/presentation/salary_calculator/salary_calculator_screen.dart` | 수정 — StatefulWidget → ConsumerStatefulWidget, ViewModel 연결 |
| `lib/presentation/salary_calculator/salary_calculator_colors.dart` | 유지 — 색상 상수 |
| `lib/presentation/salary_calculator/widgets/salary_display.dart` | 신규 — 급여 입력 표시 + 슬라이더 통합 위젯 |
| `lib/presentation/salary_calculator/widgets/result_card.dart` | 신규 — 실수령액 결과 카드 위젯 |
| `lib/presentation/salary_calculator/widgets/deduction_card.dart` | 신규 — 공제 내역 카드 위젯 |
| `lib/presentation/salary_calculator/widgets/dependents_bar.dart` | 신규 — 부양가족 수 조절기 위젯 |
| `lib/presentation/salary_calculator/widgets/keypad_modal.dart` | 신규 — 키패드 바텀시트 |
| `test/domain/usecases/calculate_salary_usecase_test.dart` | 신규 — 계산 로직 단위 테스트 (19케이스) |

**데이터 흐름**

```
[Firestore tax_rates/latest → 캐시(7일) → kFallbackTaxRates 폴백]
        │
        ▼
[SalaryCalculatorViewModel (AutoDisposeNotifier<SalaryCalculatorState>)]
        │  build() → _loadTaxRates() (fire-and-forget)
        │  handleIntent(intent)
        │
        ├── SalaryChanged    → _salary 업데이트 → CalculateSalaryUseCase
        ├── TabSwitched      → _salary 환산 (×12/÷12) → CalculateSalaryUseCase
        ├── DependentsChanged→ _dependents 업데이트 → CalculateSalaryUseCase
        └── DirectInput      → _salary 업데이트 → CalculateSalaryUseCase
                │
                ▼
        [SalaryCalculatorState 갱신] ──▶ [화면 리렌더]
```

---

## 테마 / 색상 (UI 프리뷰에서 확정)

**콘셉트**: 계약서·공식 문서 느낌 — 크림 종이 배경 + 딥 앤틱 골드 + 버건디 도장

| 역할 | 색상 상수 | 값 |
|------|-----------|-----|
| 화면 배경 (위) | `kSalaryBg1` | `#0A0A0F` (깊은 블랙) |
| 화면 배경 (아래) | `kSalaryBg2` | `#141420` |
| 강조색 | `kSalaryAccent` | `#E8ECF2` (브릴리언트 실버) |
| 하이라이트 (금액) | `kSalaryGold` | `#F0F4FF` (밝은 실버 화이트) |
| 카드 배경 | `kSalaryCardBg` | `#1A1A28` (다크 카드) |
| 카드 테두리 | `kSalaryCardBorder` | `#2A2A3A` |
| 결과 카드 배경 | `kSalaryResultBg` | `#1E1E2C` |
| 공제 카드 배경 | `kSalaryDeductionBg` | `#1A1A28` |
| 텍스트 주색 | `kSalaryTextPrimary` | `#F0EDE6` (아이보리 화이트) |
| 텍스트 보조색 | `kSalaryTextSecondary` | `#C8C6D2` (미디엄 그레이) |
| 공통 카드 그림자 | `kSalaryCardBoxShadow` | `BoxShadow(blurRadius: 8, offset: (0,2))` |

---

## 구현 범위

### 1. `lib/domain/models/tax_rates.dart`

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
    required int    basedYear,
  }) = _TaxRates;
}

const kFallbackTaxRates = TaxRates(
  nationalPensionRate: 0.045,
  nationalPensionMin: 370000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03545,
  longTermCareRate: 0.1295,
  employmentInsuranceRate: 0.009,
  basedYear: 2024,
);
```

> **설계 결정**: 소득세는 Firestore 간이세액표 646행 룩업으로 계산한다 (테이블 없으면 산출 공식 폴백).
> 폴백 상수는 `lib/data/datasources/tax_rates_fallback.dart`로 이동 (2026년 기준).
> Firestore 세율 연동 상세: [`docs/dev/firebase/FIRESTORE_TAX_RATES.md`](firebase/FIRESTORE_TAX_RATES.md)

---

### 2. `lib/domain/models/salary_calculator_state.dart`

```dart
enum SalaryMode { monthly, annual }

@freezed
class SalaryCalculatorState with _$SalaryCalculatorState {
  const factory SalaryCalculatorState({
    @Default(SalaryMode.annual) SalaryMode mode,
    @Default(45000000) int salary,
    @Default(1) int dependents,
    // 계산 결과
    @Default(0) int nationalPension,
    @Default(0) int healthInsurance,
    @Default(0) int longTermCare,
    @Default(0) int employmentInsurance,
    @Default(0) int incomeTax,
    @Default(0) int localTax,
  }) = _SalaryCalculatorState;
}

extension SalaryCalculatorStateX on SalaryCalculatorState {
  int get monthSalary => mode == SalaryMode.monthly ? salary : (salary / 12).round();
  int get totalDeduction => nationalPension + healthInsurance + longTermCare
      + employmentInsurance + incomeTax + localTax;
  int get netPay => monthSalary > 0 ? (monthSalary - totalDeduction).clamp(0, 999999999) : 0;
  int get netPayAnnual => netPay * 12;
}
```

---

### 3. `lib/domain/usecases/calculate_salary_usecase.dart`

**주요 구성 요소**

```dart
class CalculateSalaryUseCase {
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
소득세     = 간이세액표 산출 공식 (소득세법 시행령 별표2 10단계 알고리즘)
지방소득세 = 소득세 × 0.1 → floor
```

**소득세 산출 공식 (10단계)**

```
1. 연간총급여 = monthSalary × 12
2. 근로소득공제 (구간별 차등: 70%~1,475만+2%)
3. 근로소득금액 = 총급여 - 근로소득공제
4. 인적공제 = dependents × 1,500,000
5. 연금보험료공제 = 국민연금 × 12
6. 특별소득공제 (건보료·고용보험료 × 12 + 주택자금공제 추정)
7. 과세표준 = 근로소득금액 - 인적공제 - 연금보험료 - 특별소득공제
8. 산출세액 (8단계 누진세율: 6%~45%)
9. 근로소득세액공제 (산출세액 구간별 차등)
10. 월 소득세 = (산출세액 - 세액공제) ÷ 12
```

**설계 결정**

- UseCase에 `TaxRates`를 생성자 주입: 테스트 시 임의 세율 주입 가능
- 소득세: 간이세액표 2D 배열 대신 산출 공식 사용 (Firestore 연동 전 임시 방안)
- 저소득 구간은 실제 세액표와 2% 이내 오차, 고소득 구간은 차이 발생 가능 (특별소득공제 추정치 한계)

---

### 4. `lib/presentation/salary_calculator/salary_calculator_viewmodel.dart`

**Intent 목록**

```dart
sealed class SalaryCalculatorIntent {
  const factory SalaryCalculatorIntent.salaryChanged(int salary) = _SalaryChanged;
  const factory SalaryCalculatorIntent.tabSwitched(SalaryMode mode) = _TabSwitched;
  const factory SalaryCalculatorIntent.directInput(int salary) = _DirectInput;
  const factory SalaryCalculatorIntent.dependentsChanged(int dependents) = _DependentsChanged;
}
```

**ViewModel 구조**

```dart
class SalaryCalculatorViewModel extends AutoDisposeNotifier<SalaryCalculatorState> {
  late final CalculateSalaryUseCase _useCase;

  @override
  SalaryCalculatorState build() {
    _useCase = const CalculateSalaryUseCase(kFallbackTaxRates);
    return _recalculate(const SalaryCalculatorState());
  }

  void handleIntent(SalaryCalculatorIntent intent) {
    // switch on intent → state 업데이트 + _recalculate
  }

  SalaryCalculatorState _recalculate(SalaryCalculatorState s) {
    final result = _useCase.execute(
        monthSalary: s.monthSalary, dependents: s.dependents);
    return s.copyWith(...result);
  }
}

final salaryCalculatorViewModelProvider =
    NotifierProvider.autoDispose<SalaryCalculatorViewModel, SalaryCalculatorState>(
        SalaryCalculatorViewModel.new);
```

> **설계 결정**: 동기 `AutoDisposeNotifier` 유지. Firestore 세율은 `_loadTaxRates()`에서 fire-and-forget으로 비동기 로딩하고, 완료 시 state를 갱신한다.
> 로딩 중에는 `isLoading: true` + 환율 계산기와 동일한 블러 오버레이를 표시한다.

---

### 5. `lib/presentation/salary_calculator/` 위젯 분리

프리뷰 단계에서 한 파일에 작성된 위젯을 `widgets/` 폴더로 분리한다.

| 위젯 클래스 | 분리 파일 | 비고 |
|------------|-----------|------|
| `SalaryDisplay` | `widgets/salary_display.dart` | 급여 표시 + 슬라이더 통합 + 키패드 트리거 |
| `ResultCard` | `widgets/result_card.dart` | 실수령액 결과 (금액 우측 정렬) |
| `DeductionCard` | `widgets/deduction_card.dart` | 공제 내역 리스트 |
| `DependentsBar` | `widgets/dependents_bar.dart` | 고정 하단 부양가족 조절기 |
| `showSalaryKeypad` | `widgets/keypad_modal.dart` | 직접 입력 바텀시트 (함수) |

**분리 후 `salary_calculator_screen.dart` 역할**

- ViewModel watch + `handleIntent` 호출 전달
- 슬라이더 범위 관리, 탭 전환 로직
- `ConsumerStatefulWidget` 사용 (탭 오프셋 상태 관리)

---

## 구현 순서

```
1. 도메인 모델 구현 (tax_rates.dart, salary_calculator_state.dart) + build_runner
2. TDD: calculate_salary_usecase_test.dart 작성 (19케이스)
3. CalculateSalaryUseCase 구현 (간이세액표 산출 공식) — 테스트 통과
4. ViewModel 구현 (AutoDisposeNotifier + sealed Intent)
5. 위젯 분리 (widgets/ 폴더 5개 파일)
6. Screen ConsumerStatefulWidget 전환 + ViewModel 연결
7. 검증 (단위 테스트 + 정적 분석 + 수동 UI 확인)
```

---

## 범위 외 (이번 작업 제외)

- **Firebase Functions** (`functions/src/taxRates.ts`) — 간이세액표 자동 파싱
- **Firestore DataSource / Repository** — 세율 원격 조회
- **FetchTaxRatesUseCase** — Firestore 세율 조회
- **비과세 항목 설정** (식대, 차량유지비) — v2 예정
- **세전/세후 역산** — v2 예정
- **두 연봉 비교 모드** — v2 예정
- **요율 연도 선택** — v2 예정
