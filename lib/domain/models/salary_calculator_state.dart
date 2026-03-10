import 'package:freezed_annotation/freezed_annotation.dart';

part 'salary_calculator_state.freezed.dart';

enum SalaryMode { monthly, annual }

@freezed
class SalaryCalculatorState with _$SalaryCalculatorState {
  const factory SalaryCalculatorState({
    @Default(SalaryMode.monthly) SalaryMode mode,
    @Default(3000000) int salary,
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
  int get monthSalary =>
      mode == SalaryMode.monthly ? salary : (salary / 12).round();

  int get totalDeduction =>
      nationalPension +
      healthInsurance +
      longTermCare +
      employmentInsurance +
      incomeTax +
      localTax;

  int get netPay =>
      monthSalary > 0 ? (monthSalary - totalDeduction).clamp(0, 999999999) : 0;

  int get netPayAnnual => netPay * 12;
}
