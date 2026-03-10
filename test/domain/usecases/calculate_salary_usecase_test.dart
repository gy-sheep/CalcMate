import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/models/tax_rates.dart';
import 'package:calcmate/domain/usecases/calculate_salary_usecase.dart';

void main() {
  late CalculateSalaryUseCase useCase;

  setUp(() {
    useCase = const CalculateSalaryUseCase(kFallbackTaxRates);
  });

  group('국민연금', () {
    test('일반 범위 — 월급 375만원 × 4.5% = 168,750', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.nationalPension, 168750);
    });

    test('상한 초과 — 617만원 상한 적용 = 277,650', () {
      final r = useCase.execute(monthSalary: 8000000, dependents: 1);
      expect(r.nationalPension, 277650);
    });

    test('하한 미만 — 37만원 하한 적용 = 16,650', () {
      final r = useCase.execute(monthSalary: 200000, dependents: 1);
      expect(r.nationalPension, 16650);
    });
  });

  group('건강보험', () {
    test('10원 단위 절사 — 375만원 × 3.545% = 132,937 → 132,930', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      expect(r.healthInsurance, 132930);
    });

    test('200만원 × 3.545% = 70,900', () {
      final r = useCase.execute(monthSalary: 2000000, dependents: 1);
      expect(r.healthInsurance, 70900);
    });
  });

  group('장기요양', () {
    test('건보료 기반 — 132,930 × 12.95%', () {
      final r = useCase.execute(monthSalary: 3750000, dependents: 1);
      // 132930 * 0.1295 = 17,214.435
      expect(r.longTermCare, 17214);
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
      expect(r.nationalPension, 277650); // 상한
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
}
