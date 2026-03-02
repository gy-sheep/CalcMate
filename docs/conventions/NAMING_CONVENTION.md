# Naming Convention

CalcMate 프로젝트의 네이밍 규칙을 정리한 문서.

---

## 파일명

- **규칙**: `snake_case` + 역할 접미사
- **화면 파일**: `{기능명}_screen.dart`
- **위젯 파일**: `{기능명}_widget.dart` 또는 `{기능명}_card.dart`
- **ViewModel 파일**: `{기능명}_notifier.dart`
- **UseCase 파일**: `{기능명}_use_case.dart`
- **Entity 파일**: `{기능명}_entity.dart`
- **Repository 파일**: `{기능명}_repository.dart`

### 계산기 화면 파일명

| 계산기 | 파일명 |
|--------|--------|
| 기본 계산기 | `basic_calculator_screen.dart` |
| 환율 계산기 | `exchange_rate_screen.dart` |
| 단위 변환기 | `unit_converter_screen.dart` |
| 부가세 계산기 | `vat_screen.dart` |
| 나이 계산기 | `age_calculator_screen.dart` |
| 날짜 계산기 | `date_calculator_screen.dart` |
| 대출 계산기 | `loan_calculator_screen.dart` |
| 실수령액 계산기 | `salary_calculator_screen.dart` |
| 할인 계산기 | `discount_calculator_screen.dart` |
| 더치페이 계산기 | `dutch_pay_screen.dart` |
| 전월세 계산기 | `rent_calculator_screen.dart` |
| 취득세 계산기 | `acquisition_tax_screen.dart` |
| BMI 계산기 | `bmi_calculator_screen.dart` |

---

## 클래스명

- **규칙**: `PascalCase` + 역할 접미사

| 역할 | 형식 | 예시 |
|------|------|------|
| 화면 Widget | `{기능}Screen` | `BasicCalculatorScreen` |
| ViewModel (Notifier) | `{기능}Notifier` | `BasicCalculatorNotifier` |
| State | `{기능}State` | `BasicCalculatorState` |
| Intent | `{기능}Intent` | `BasicCalculatorIntent` |
| UseCase | `{기능}UseCase` | `EvaluateExpressionUseCase` |
| Entity | `{기능}Entity` | `ExchangeRateEntity` |
| Repository 인터페이스 | `{기능}Repository` | `ExchangeRateRepository` |
| Repository 구현체 | `{기능}RepositoryImpl` | `ExchangeRateRepositoryImpl` |
| DTO | `{기능}Dto` | `ExchangeRateDto` |

---

## 변수 / 함수명

- **규칙**: `camelCase`
- **Provider**: `{기능}Provider` (e.g. `basicCalculatorProvider`)
- **상수**: `k{이름}` (e.g. `kAllCalculatorItems`)
- **private**: `_camelCase` (e.g. `_buildImage()`)

---

## 디렉토리명

- **규칙**: `snake_case`
- 전체 디렉토리 구조: [`docs/architecture/ARCHITECTURE.md`](../architecture/ARCHITECTURE.md) 참고

---

## Hero 태그

- **배경**: `calc_bg_{title}`
- **아이콘**: `calc_icon_{title}`
- **타이틀**: `calc_title_{title}`

---

## 브랜치명

- **규칙**: `{type}/{kebab-case-기능명}`
- **기준**: Q0002 브랜치 전략 참조 → [Q0002.md](../prompts/answers/Q0002.md)

### Phase별 브랜치명

| Phase | 브랜치명 | 설명 |
|-------|----------|------|
| 선행 작업 | `feat/calc-mode-card-refactor` | 카드 리스트 데이터 분리 |
| Phase 1 | `feat/basic-calculator` | 기본 계산기 |
| Phase 2 | `feat/exchange-rate` | 환율 계산기 |
| Phase 3 | `feat/unit-converter` | 단위 변환기 |
| Phase 4 | `feat/vat-calculator` | 부가세 계산기 |
| Phase 5 | `feat/age-calculator` | 나이 계산기 |
| Phase 6 | `feat/date-calculator` | 날짜 계산기 |
| Phase 7 | `feat/loan-calculator` | 대출 계산기 |
| Phase 8 | `feat/salary-calculator` | 실수령액 계산기 |
| Phase 9 | `feat/discount-calculator` | 할인 계산기 |
| Phase 10 | `feat/dutch-pay` | 더치페이 계산기 |
| Phase 11 | `feat/rent-calculator` | 전월세 계산기 |
| Phase 12 | `feat/acquisition-tax` | 취득세 계산기 |
| Phase 13 | `feat/bmi-calculator` | BMI 계산기 |
| Phase 14 | `feat/polish` | 마무리 및 출시 |

### 세부 분기 (하나의 Phase를 나눠 작업할 경우)

```bash
feat/basic-calculator-usecase   # UseCase만 먼저
feat/basic-calculator-ui        # UI 별도 작업
```

---

## Asset 파일명

- **규칙**: `snake_case`
- **배경 이미지**: `assets/images/backgrounds/{기능명}.png` (e.g. `basic_calculator.png`)
- **아이콘 이미지**: `assets/images/icons/{기능명}.png`
- **일러스트 등 기타**: `assets/images/illustrations/{기능명}.png`
