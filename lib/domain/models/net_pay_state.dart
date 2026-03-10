import 'package:freezed_annotation/freezed_annotation.dart';

part 'net_pay_state.freezed.dart';

enum SalaryMode { monthly, annual }

enum AdjustUnit {
  man(10000, '만원'),
  tenMan(100000, '10만'),
  hundredMan(1000000, '100만'),
  cheonMan(10000000, '천만');

  const AdjustUnit(this.value, this.label);
  final int value;
  final String label;
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
  }) = _NetPayState;
}

extension NetPayStateX on NetPayState {
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
