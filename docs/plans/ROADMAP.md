# CalcMate Implementation Roadmap

생활 속 계산을 하나로 해결하는 Flutter 계산기 앱. 총 13개 계산기를 Phase별로 순차 구현한다.

---

## Phase 0: 프로젝트 기초 설정 (Foundation)

**목표**: 이후 모든 계산기 Phase의 기반이 되는 공통 인프라 구성

- [ ] `pubspec.yaml` 의존성 추가: Riverpod, Dio, Retrofit, Freezed, json_serializable, shared_preferences
- [ ] `analysis_options.yaml` 커스텀 lint 규칙 설정 (prefer_single_quotes 등)
- [ ] `core/di/` — Riverpod ProviderScope 설정, Dio 인스턴스 Provider
- [ ] `core/network/` — Dio 기본 옵션, 인터셉터 (로깅, 에러 처리)
- [ ] 공통 상태 기반 타입 정의 (AsyncValue 활용 패턴 정립)
- [ ] 메인 화면에 13개 계산기 카드 전체 추가 및 라우팅 연결

---

## Phase 1: 기본 계산기

- [ ] **Domain**: `CalculatorState` (Freezed), `CalculatorIntent` (sealed class)
- [ ] **Domain**: `EvaluateExpressionUseCase` — 수식 파싱 및 계산 (TDD)
- [ ] **Presentation**: 결과창 + 숫자/연산자 버튼 패드 UI
- [ ] **ViewModel**: `CalculatorViewModel` (Riverpod Notifier, handleIntent)

---

## Phase 2: 환율 계산기

- [ ] **Data**: Retrofit API 인터페이스, 환율 DTO, Repository 구현체
- [ ] **Domain**: `ExchangeRateEntity`, `GetExchangeRateUseCase`
- [ ] **Presentation**: 통화 선택 UI, 금액 입력, 환산 결과 표시
- [ ] **ViewModel**: `ExchangeRateViewModel` (AsyncNotifier — API 상태 관리)
- [ ] 오프라인 fallback: 마지막 조회 환율 `shared_preferences` 캐싱

---

## Phase 3: 단위 변환기

- [ ] **Domain**: `UnitConvertUseCase` — 길이/무게/넓이/부피/온도 (TDD)
- [ ] **Presentation**: 단위 카테고리 선택 + 입력/결과 UI
- [ ] **ViewModel**: `UnitConverterViewModel`

---

## Phase 4: 부가세 계산기

- [ ] **Domain**: `VatCalculateUseCase` — 포함/별도 계산 (TDD)
- [ ] **Presentation**: 금액 입력, 포함/별도 토글, 결과 표시
- [ ] **ViewModel**: `VatViewModel`

---

## Phase 5: 나이 계산기

- [ ] **Domain**: `AgeCalculateUseCase` — 만 나이, 띠, 별자리 계산 (TDD)
- [ ] **Presentation**: 생년월일 입력 (DatePicker), 결과 카드 UI
- [ ] **ViewModel**: `AgeViewModel`

---

## Phase 6: 날짜 계산기

- [ ] **Domain**: `DateCalculateUseCase` — D-day, 날짜 간격 계산 (TDD)
- [ ] **Presentation**: 기준일/목표일 DatePicker, 결과 표시
- [ ] **ViewModel**: `DateCalculatorViewModel`

---

## Phase 7: 대출 계산기

- [ ] **Domain**: `LoanCalculateUseCase` — 원리금균등상환, 원금균등상환 (TDD)
- [ ] **Presentation**: 대출금/금리/기간 입력, 월납입금 및 총이자 결과 표시
- [ ] **ViewModel**: `LoanViewModel`

---

## Phase 8: 실수령액 계산기

- [ ] **Domain**: `SalaryCalculateUseCase` — 연봉 → 세금/4대보험 차감 (TDD)
- [ ] 세율/요율 상수 파일 분리 (`core/constants/tax_rates.dart`)
- [ ] **Presentation**: 연봉 입력, 항목별 공제액 및 실수령액 표시
- [ ] **ViewModel**: `SalaryViewModel`

---

## Phase 9: 할인 계산기

- [ ] **Domain**: `DiscountCalculateUseCase` — 정가 + 할인율 → 최종금액 (TDD)
- [ ] **Presentation**: 정가/할인율 입력, 할인금액 및 최종금액 표시
- [ ] **ViewModel**: `DiscountViewModel`

---

## Phase 10: 더치페이 계산기

- [ ] **Domain**: `DutchPayCalculateUseCase` — 금액 ÷ 인원 (TDD)
- [ ] **Presentation**: 금액/인원 입력, 1인 부담액 표시
- [ ] **ViewModel**: `DutchPayViewModel`

---

## Phase 11: 전월세 계산기

- [ ] **Domain**: `RentCalculateUseCase` — 전세↔월세 전환, 보증금 이자 환산 (TDD)
- [ ] **Presentation**: 전환 방향 선택, 보증금/금리/월세 입력, 결과 표시
- [ ] **ViewModel**: `RentViewModel`

---

## Phase 12: 취득세 계산기

- [ ] **Domain**: `AcquisitionTaxCalculateUseCase` — 매매가 기준 취득세 산출 (TDD)
- [ ] 취득세율 상수 파일 분리 (`core/constants/acquisition_tax_rates.dart`)
- [ ] **Presentation**: 매매가/주택 유형 입력, 세율 및 세액 표시
- [ ] **ViewModel**: `AcquisitionTaxViewModel`

---

## Phase 13: BMI 계산기

- [ ] **Domain**: `BmiCalculateUseCase` — BMI 계산 및 체중 분류 (TDD)
- [ ] **Presentation**: 신장/체중 입력, BMI 수치 및 분류(저체중/정상/과체중/비만) 표시
- [ ] **ViewModel**: `BmiViewModel`

---

## Phase 14: 마무리 및 출시 (Polish)

- [ ] 계산 히스토리 저장 (`shared_preferences`)
- [ ] 설정 화면 구현 (테마, 기본 통화 등)
- [ ] 버튼 클릭 피드백 애니메이션 보강
- [ ] 앱 아이콘 및 스플래시 화면 설정
- [ ] Android / iOS 플랫폼별 권한 및 설정 점검
- [ ] 릴리즈 빌드 테스트
