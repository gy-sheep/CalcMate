import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/salary_calculator_state.dart';
import '../../domain/models/tax_rates.dart';
import '../../domain/usecases/calculate_salary_usecase.dart';

// ── Intent ──────────────────────────────────────────────────────────────────

sealed class SalaryCalculatorIntent {
  const SalaryCalculatorIntent();
  const factory SalaryCalculatorIntent.tabSwitched(SalaryMode mode) = _TabSwitched;
  const factory SalaryCalculatorIntent.salaryChanged(int salary) = _SalaryChanged;
  const factory SalaryCalculatorIntent.directInput(int salary) = _DirectInput;
  const factory SalaryCalculatorIntent.dependentsChanged(int dependents) =
      _DependentsChanged;
}

class _TabSwitched extends SalaryCalculatorIntent {
  final SalaryMode mode;
  const _TabSwitched(this.mode);
}

class _SalaryChanged extends SalaryCalculatorIntent {
  final int salary;
  const _SalaryChanged(this.salary);
}

class _DirectInput extends SalaryCalculatorIntent {
  final int salary;
  const _DirectInput(this.salary);
}

class _DependentsChanged extends SalaryCalculatorIntent {
  final int dependents;
  const _DependentsChanged(this.dependents);
}

// ── Provider ────────────────────────────────────────────────────────────────

final salaryCalculatorViewModelProvider =
    NotifierProvider.autoDispose<SalaryCalculatorViewModel, SalaryCalculatorState>(
        SalaryCalculatorViewModel.new);

// ── ViewModel ───────────────────────────────────────────────────────────────

class SalaryCalculatorViewModel extends AutoDisposeNotifier<SalaryCalculatorState> {
  late final CalculateSalaryUseCase _useCase;

  @override
  SalaryCalculatorState build() {
    _useCase = const CalculateSalaryUseCase(kFallbackTaxRates);
    const initial = SalaryCalculatorState();
    return _recalculate(initial);
  }

  void handleIntent(SalaryCalculatorIntent intent) {
    switch (intent) {
      case _TabSwitched(:final mode):
        _onTabSwitched(mode);
      case _SalaryChanged(:final salary):
        state = _recalculate(state.copyWith(salary: salary.clamp(0, 9999999999)));
      case _DirectInput(:final salary):
        state = _recalculate(state.copyWith(salary: salary.clamp(0, 9999999999)));
      case _DependentsChanged(:final dependents):
        state = _recalculate(
            state.copyWith(dependents: dependents.clamp(1, 11)));
    }
  }

  void _onTabSwitched(SalaryMode mode) {
    if (state.mode == mode) return;
    int converted;
    if (state.mode == SalaryMode.monthly && mode == SalaryMode.annual) {
      converted = state.salary * 12;
      // 100만 단위로 스냅
      converted = (converted / 1000000).round() * 1000000;
      converted = converted.clamp(20000000, 300000000);
    } else {
      converted = (state.salary / 12).round();
      // 10만 단위로 스냅
      converted = (converted / 100000).round() * 100000;
      converted = converted.clamp(1000000, 10000000);
    }
    state = _recalculate(state.copyWith(mode: mode, salary: converted));
  }

  SalaryCalculatorState _recalculate(SalaryCalculatorState s) {
    final result = _useCase.execute(
      monthSalary: s.mode == SalaryMode.monthly
          ? s.salary
          : (s.salary / 12).round(),
      dependents: s.dependents,
    );
    return s.copyWith(
      nationalPension: result.nationalPension,
      healthInsurance: result.healthInsurance,
      longTermCare: result.longTermCare,
      employmentInsurance: result.employmentInsurance,
      incomeTax: result.incomeTax,
      localTax: result.localTax,
    );
  }
}
