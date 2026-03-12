import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/data/datasources/tax_rates_fallback.dart';
import 'package:calcmate/domain/models/tax_rates.dart';
import 'package:calcmate/domain/usecases/calculate_salary_usecase.dart';

void main() {
  late CalculateSalaryUseCase useCase;

  setUp(() {
    useCase = const CalculateSalaryUseCase(kFallbackTaxRates);
  });

  group('국민연금', () {
    test('일반 범위 — 월급 375만원 × 4.75% = 178,125', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.nationalPension, 178125);
    });

    test('상한 초과 — 617만원 상한 적용 = 293,075', () {
      final r = useCase.execute(monthSalary: 8000000, dependents: 1);
      expect(r.nationalPension, 293075);
    });

    test('하한 미만 — 39만원 하한 적용 = 18,525', () {
      final r = useCase.execute(monthSalary: 200000, dependents: 1);
      expect(r.nationalPension, 18525);
    });
  });

  group('건강보험', () {
    test('10원 단위 절사 — 375만원 × 3.595% = 134,812 → 134,810', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.healthInsurance, 134810);
    });

    test('200만원 × 3.595% = 71,900', () {
      final r = useCase.execute(monthSalary: 2000000, dependents: 1);
      expect(r.healthInsurance, 71900);
    });
  });

  group('장기요양', () {
    test('건보료 기반 — 134,810 × 13.14%', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      // 134810 * 0.1314 = 17,714.034
      expect(r.longTermCare, 17714);
    });
  });

  group('고용보험', () {
    test('375만원 × 0.9% = 33,750', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.employmentInsurance, 33750);
    });
  });

  group('소득세', () {
    test('월급 0원 — 소득세 0', () {
      final r = useCase.execute(monthSalary: 0, dependents: 1);
      expect(r.incomeTax, 0);
    });

    test('부양가족 1명 — 월급 200만원 소득세 약 19,520', () {
      final r = useCase.execute(monthSalary: 2000000, dependents: 1);
      // 국세청 간이세액표 검증 데이터: 19,520
      expect(r.incomeTax, closeTo(19520, 3000));
    });

    test('부양가족 1명 — 월급 300만원 소득세 약 60,940', () {
      final r = useCase.execute(monthSalary: 3000000, dependents: 1);
      expect(r.incomeTax, closeTo(60940, 5000));
    });

    test('부양가족 1명 — 월급 500만원 소득세 양수', () {
      final r = useCase.execute(monthSalary: 5000000, dependents: 1);
      // 간이세액표 산출 공식 기반 근사치 (Firestore 실데이터 연동 후 정밀화)
      expect(r.incomeTax, greaterThan(200000));
    });

    test('부양가족 2명 — 소득세가 1명보다 낮음', () {
      final r1 = useCase.execute(monthSalary: 3750000, dependents: 1);
      final r2 = useCase.execute(monthSalary: 3750000, dependents: 2);
      expect(r2.incomeTax, lessThan(r1.incomeTax));
    });

    test('부양가족 3명 이상 — 소득세가 2명보다 낮음', () {
      final r2 = useCase.execute(monthSalary: 3750000, dependents: 2);
      final r3 = useCase.execute(monthSalary: 3750000, dependents: 3);
      expect(r3.incomeTax, lessThan(r2.incomeTax));
    });

    test('부양가족 11명 — 소득세 최소', () {
      final r1 = useCase.execute(monthSalary: 3750000, dependents: 1);
      final r11 = useCase.execute(monthSalary: 3750000, dependents: 11);
      expect(r11.incomeTax, lessThan(r1.incomeTax));
    });
  });

  group('지방소득세', () {
    test('소득세 × 10%', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.localTax, (r.incomeTax * 0.1).floor());
    });
  });

  group('통합 검증', () {
    test('월급 0 — 모든 공제 0', () {
      final r = useCase.execute(monthSalary: 0, dependents: 1);
      expect(r.nationalPension, 0);
      expect(r.healthInsurance, 0);
      expect(r.longTermCare, 0);
      expect(r.employmentInsurance, 0);
      expect(r.incomeTax, 0);
      expect(r.localTax, 0);
      expect(r.total, 0);
    });

    test('월급 375만원 부양가족 1명 — total 합계 일치', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(
        r.total,
        r.nationalPension +
            r.healthInsurance +
            r.longTermCare +
            r.employmentInsurance +
            r.incomeTax +
            r.localTax,
      );
    });

    test('고액 월급 1000만원 — 정상 계산', () {
      final r = useCase.execute(monthSalary: 10000000, dependents: 1);
      expect(r.nationalPension, 293075); // 상한 (617만 × 4.75%)
      expect(r.healthInsurance, greaterThan(0));
      expect(r.incomeTax, greaterThan(0));
      expect(r.total, greaterThan(0));
    });

    test('저액 월급 100만원 — 소득세 0 가능', () {
      final r = useCase.execute(monthSalary: 1000000, dependents: 1);
      expect(r.nationalPension, greaterThan(0));
      expect(r.healthInsurance, greaterThan(0));
      // 저소득은 소득세 0 가능
      expect(r.incomeTax, greaterThanOrEqualTo(0));
    });
  });

  // ── 간이세액표 룩업 모드 ──────────────────────────────────────────────────

  group('간이세액표 룩업', () {
    late CalculateSalaryUseCase lookupUseCase;

    /// 테스트용 간이세액표 (3행만)
    final testTable = [
      const IncomeTaxBracket(min: 770, max: 775, taxes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
      const IncomeTaxBracket(min: 2000, max: 2010, taxes: [19520, 14750, 6600, 3220, 0, 0, 0, 0, 0, 0, 0]),
      const IncomeTaxBracket(min: 5000, max: 5020, taxes: [502210, 414030, 331750, 280790, 229820, 178860, 135980, 104240, 72500, 40760, 9030]),
    ];

    final testOverBrackets = [
      const OverTenMillionBracket(min: 10000, max: 14000, baseAdd: 25000, rate: 0.35, applyRatio: 0.98, excessFrom: 10000),
      const OverTenMillionBracket(min: 14000, max: 28000, baseAdd: 1397000, rate: 0.38, applyRatio: 0.98, excessFrom: 14000),
    ];

    setUp(() {
      lookupUseCase = CalculateSalaryUseCase(TaxRates(
        nationalPensionRate: 0.0475,
        nationalPensionMin: 390000,
        nationalPensionMax: 6170000,
        healthInsuranceRate: 0.03595,
        longTermCareRate: 0.1314,
        employmentInsuranceRate: 0.009,
        basedYear: 2026,
        incomeTaxTable: testTable,
        overTenMillionBrackets: testOverBrackets,
      ));
    });

    test('테이블 범위 내 — 200만원 부양가족 1명 = 19,520', () {
      final r = lookupUseCase.execute(monthSalary: 2000000, dependents: 1);
      expect(r.incomeTax, 19520);
    });

    test('테이블 범위 내 — 200만원 부양가족 3명 = 6,600', () {
      final r = lookupUseCase.execute(monthSalary: 2000000, dependents: 3);
      expect(r.incomeTax, 6600);
    });

    test('테이블 범위 내 — 200만원 부양가족 5명 = 0', () {
      final r = lookupUseCase.execute(monthSalary: 2000000, dependents: 5);
      expect(r.incomeTax, 0);
    });

    test('테이블 최저 미만 — 50만원 = 세액 0', () {
      final r = lookupUseCase.execute(monthSalary: 500000, dependents: 1);
      expect(r.incomeTax, 0);
    });

    test('테이블 범위 밖(구간 사이) — 폴백 산출 공식 사용하지 않고 0 반환', () {
      // 3000천원은 testTable에 없음 (2010~5000 사이 빈 구간)
      final r = lookupUseCase.execute(monthSalary: 3000000, dependents: 1);
      expect(r.incomeTax, 0);
    });

    test('부양가족 증가 시 세액 감소', () {
      final r1 = lookupUseCase.execute(monthSalary: 5000000, dependents: 1);
      final r3 = lookupUseCase.execute(monthSalary: 5000000, dependents: 3);
      expect(r3.incomeTax, lessThan(r1.incomeTax));
    });

    test('지방소득세 = 소득세 × 10%', () {
      final r = lookupUseCase.execute(monthSalary: 2000000, dependents: 1);
      expect(r.localTax, (r.incomeTax * 0.1).floor());
    });
  });

  group('1,000만원 초과 산식', () {
    late CalculateSalaryUseCase overUseCase;

    /// 간이세액표 마지막 행 = 10,000천원 기준 세액
    final testTable = [
      const IncomeTaxBracket(min: 9980, max: 10000, taxes: [2000000, 1800000, 1600000, 1400000, 1200000, 1000000, 800000, 600000, 400000, 200000, 100000]),
    ];

    final testOverBrackets = [
      const OverTenMillionBracket(min: 10000, max: 14000, baseAdd: 25000, rate: 0.35, applyRatio: 0.98, excessFrom: 10000),
      const OverTenMillionBracket(min: 14000, max: 28000, baseAdd: 1397000, rate: 0.38, applyRatio: 0.98, excessFrom: 14000),
    ];

    setUp(() {
      overUseCase = CalculateSalaryUseCase(TaxRates(
        nationalPensionRate: 0.0475,
        nationalPensionMin: 390000,
        nationalPensionMax: 6170000,
        healthInsuranceRate: 0.03595,
        longTermCareRate: 0.1314,
        employmentInsuranceRate: 0.009,
        basedYear: 2026,
        incomeTaxTable: testTable,
        overTenMillionBrackets: testOverBrackets,
      ));
    });

    test('1,200만원 — baseTax + baseAdd + 초과분 × 0.98 × 0.35', () {
      final r = overUseCase.execute(monthSalary: 12000000, dependents: 1);
      // baseTax = 2,000,000 (10,000천원 세액, dep index 0)
      // excess = 12,000,000 - 10,000,000 = 2,000,000
      // adjusted = floor(2,000,000 × 0.98) = 1,960,000
      // additionalTax = 25,000 + floor(1,960,000 × 0.35) = 25,000 + 686,000 = 711,000
      // total = 2,000,000 + 711,000 = 2,711,000
      expect(r.incomeTax, 2711000);
    });

    test('1,500만원 — 두 번째 구간 적용', () {
      final r = overUseCase.execute(monthSalary: 15000000, dependents: 1);
      // baseTax = 2,000,000
      // excess = 15,000,000 - 14,000,000 = 1,000,000
      // adjusted = floor(1,000,000 × 0.98) = 980,000
      // additionalTax = 1,397,000 + floor(980,000 × 0.38) = 1,397,000 + 372,400 = 1,769,400
      // total = 2,000,000 + 1,769,400 = 3,769,400
      expect(r.incomeTax, 3769400);
    });

    test('부양가족 증가 시 초과 산식에서도 세액 감소', () {
      final r1 = overUseCase.execute(monthSalary: 12000000, dependents: 1);
      final r3 = overUseCase.execute(monthSalary: 12000000, dependents: 3);
      expect(r3.incomeTax, lessThan(r1.incomeTax));
    });
  });

  group('폴백 모드 — incomeTaxTable null', () {
    test('테이블 없으면 산출 공식으로 계산', () {
      final formulaUseCase = const CalculateSalaryUseCase(kFallbackTaxRates);
      final r = formulaUseCase.execute(monthSalary: 3000000, dependents: 1);
      // 폴백 상수는 incomeTaxTable == null → 공식 사용
      expect(r.incomeTax, greaterThan(0));
    });
  });
}
