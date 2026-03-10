import 'dart:math';

import '../models/tax_rates.dart';

/// 공제 항목 6개 계산 결과.
class DeductionResult {
  const DeductionResult({
    required this.nationalPension,
    required this.healthInsurance,
    required this.longTermCare,
    required this.employmentInsurance,
    required this.incomeTax,
    required this.localTax,
  });

  final int nationalPension;
  final int healthInsurance;
  final int longTermCare;
  final int employmentInsurance;
  final int incomeTax;
  final int localTax;

  int get total =>
      nationalPension +
      healthInsurance +
      longTermCare +
      employmentInsurance +
      incomeTax +
      localTax;
}

/// 실수령액 계산 UseCase.
///
/// 4대보험 + 소득세(간이세액표 산출 공식) + 지방소득세를 계산한다.
/// 소득세는 국세청 간이세액표 산출 알고리즘(소득세법 시행령 별표2)을 구현.
class CalculateNetPayUseCase {
  const CalculateNetPayUseCase(this._rates);

  final TaxRates _rates;

  DeductionResult execute({
    required int monthSalary,
    required int dependents,
  }) {
    if (monthSalary <= 0) {
      return const DeductionResult(
        nationalPension: 0,
        healthInsurance: 0,
        longTermCare: 0,
        employmentInsurance: 0,
        incomeTax: 0,
        localTax: 0,
      );
    }

    final clampedDeps = dependents.clamp(1, 11);

    // 4대보험
    final pension = _calcNationalPension(monthSalary);
    final health = _calcHealthInsurance(monthSalary);
    final longCare = _calcLongTermCare(health);
    final employment = _calcEmploymentInsurance(monthSalary);

    // 소득세 (간이세액표 산출 공식)
    final income = _calcIncomeTax(monthSalary, clampedDeps);
    final local = (income * 0.1).floor();

    return DeductionResult(
      nationalPension: pension,
      healthInsurance: health,
      longTermCare: longCare,
      employmentInsurance: employment,
      incomeTax: income,
      localTax: local,
    );
  }

  // ── 4대보험 ──────────────────────────────────────────────────

  int _calcNationalPension(int monthSalary) {
    final base = monthSalary.clamp(_rates.nationalPensionMin, _rates.nationalPensionMax);
    return (base * _rates.nationalPensionRate).floor();
  }

  int _calcHealthInsurance(int monthSalary) {
    return (monthSalary * _rates.healthInsuranceRate) ~/ 10 * 10;
  }

  int _calcLongTermCare(int healthInsurance) {
    return (healthInsurance * _rates.longTermCareRate).floor();
  }

  int _calcEmploymentInsurance(int monthSalary) {
    return (monthSalary * _rates.employmentInsuranceRate).floor();
  }

  // ── 소득세 (간이세액표 산출 공식) ─────────────────────────────

  /// 간이세액표 산출 공식에 따라 월 소득세를 계산한다.
  /// 소득세법 시행령 별표2 기준.
  int _calcIncomeTax(int monthSalary, int dependents) {
    final annualGross = monthSalary * 12;

    // 1. 근로소득공제
    final earnedDeduction = _earnedIncomeDeduction(annualGross);

    // 2. 근로소득금액
    final earnedIncome = annualGross - earnedDeduction;
    if (earnedIncome <= 0) return 0;

    // 3. 인적공제
    final personalExemption = dependents * 1500000;

    // 4. 연금보험료공제
    final pensionDeduction =
        (min(monthSalary, _rates.nationalPensionMax) *
                _rates.nationalPensionRate *
                12)
            .floor();

    // 5. 특별소득공제 + 특별세액공제
    final specialDeduction =
        _specialDeduction(annualGross, dependents);

    // 6. 과세표준
    final taxableIncome =
        earnedIncome - personalExemption - pensionDeduction - specialDeduction;
    if (taxableIncome <= 0) return 0;

    // 7. 산출세액
    final calculatedTax = _progressiveTax(taxableIncome);

    // 8. 근로소득세액공제
    final taxCredit = _earnedIncomeTaxCredit(calculatedTax, annualGross);

    // 9. 연간 결정세액
    final annualTax = calculatedTax - taxCredit;
    if (annualTax <= 0) return 0;

    // 10. 월 소득세
    return (annualTax / 12).floor();
  }

  /// 근로소득공제 (소득세법 제47조).
  int _earnedIncomeDeduction(int annualGross) {
    if (annualGross <= 5000000) {
      return (annualGross * 0.7).floor();
    } else if (annualGross <= 15000000) {
      return 3500000 + ((annualGross - 5000000) * 0.4).floor();
    } else if (annualGross <= 45000000) {
      return 7500000 + ((annualGross - 15000000) * 0.15).floor();
    } else if (annualGross <= 100000000) {
      return 12000000 + ((annualGross - 45000000) * 0.05).floor();
    } else {
      return min(
        20000000,
        14750000 + ((annualGross - 100000000) * 0.02).floor(),
      );
    }
  }

  /// 특별소득공제 + 특별세액공제 간주 금액.
  /// 간이세액표 산출 시 부양가족 수와 총급여액에 따라 차등 적용.
  int _specialDeduction(int annualGross, int dependents) {
    if (annualGross <= 30000000) {
      if (dependents <= 1) {
        return 3100000 + (annualGross * 0.04).floor();
      } else if (dependents == 2) {
        return 3600000 + (annualGross * 0.04).floor();
      } else {
        return 5000000 + (annualGross * 0.07).floor();
      }
    } else if (annualGross <= 45000000) {
      final excess = annualGross - 30000000;
      if (dependents <= 1) {
        return 3100000 + (annualGross * 0.04).floor() - (excess * 0.05).floor();
      } else if (dependents == 2) {
        return 3600000 + (annualGross * 0.04).floor() - (excess * 0.05).floor();
      } else {
        return 5000000 + (annualGross * 0.07).floor() - (excess * 0.05).floor();
      }
    } else if (annualGross <= 70000000) {
      if (dependents <= 1) {
        return 3100000 + (annualGross * 0.015).floor();
      } else if (dependents == 2) {
        return 3600000 + (annualGross * 0.02).floor();
      } else {
        return 5000000 + (annualGross * 0.05).floor();
      }
    } else if (annualGross <= 120000000) {
      if (dependents <= 1) {
        return 3100000 + (annualGross * 0.005).floor();
      } else if (dependents == 2) {
        return 3600000 + (annualGross * 0.01).floor();
      } else {
        return 5000000 + (annualGross * 0.03).floor();
      }
    } else {
      // 1.2억 초과 시 1.2억 기준 고정
      if (dependents <= 1) {
        return 3100000 + (120000000 * 0.005).floor();
      } else if (dependents == 2) {
        return 3600000 + (120000000 * 0.01).floor();
      } else {
        return 5000000 + (120000000 * 0.03).floor();
      }
    }
  }

  /// 종합소득세 누진세율 (2024년).
  int _progressiveTax(int taxableIncome) {
    if (taxableIncome <= 14000000) {
      return (taxableIncome * 0.06).floor();
    } else if (taxableIncome <= 50000000) {
      return (taxableIncome * 0.15).floor() - 1260000;
    } else if (taxableIncome <= 88000000) {
      return (taxableIncome * 0.24).floor() - 5760000;
    } else if (taxableIncome <= 150000000) {
      return (taxableIncome * 0.35).floor() - 15440000;
    } else if (taxableIncome <= 300000000) {
      return (taxableIncome * 0.38).floor() - 19940000;
    } else if (taxableIncome <= 500000000) {
      return (taxableIncome * 0.40).floor() - 25940000;
    } else if (taxableIncome <= 1000000000) {
      return (taxableIncome * 0.42).floor() - 35940000;
    } else {
      return (taxableIncome * 0.45).floor() - 65940000;
    }
  }

  /// 근로소득세액공제 (소득세법 제59조).
  int _earnedIncomeTaxCredit(int calculatedTax, int annualGross) {
    // 공제액 계산
    int credit;
    if (calculatedTax <= 1300000) {
      credit = (calculatedTax * 0.55).floor();
    } else {
      credit = 715000 + ((calculatedTax - 1300000) * 0.30).floor();
    }

    // 한도
    int cap;
    if (annualGross <= 33000000) {
      cap = 740000;
    } else if (annualGross <= 70000000) {
      cap = max(660000, 740000 - ((annualGross - 33000000) * 0.008).floor());
    } else if (annualGross <= 120000000) {
      cap = max(500000,
          660000 - ((annualGross - 70000000) * 0.5 / 100).floor());
      // 위 공식은 0.5% 감소
    } else {
      cap = max(200000,
          500000 - ((annualGross - 120000000) * 0.5 / 100).floor());
    }

    return min(credit, cap);
  }
}
