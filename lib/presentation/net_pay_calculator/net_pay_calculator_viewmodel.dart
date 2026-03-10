import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/net_pay_state.dart';
import '../../domain/models/tax_rates.dart';
import '../../domain/usecases/calculate_net_pay_usecase.dart';

// ── Intent ──────────────────────────────────────────────────────────────────

sealed class NetPayIntent {
  const NetPayIntent();
  const factory NetPayIntent.tabSwitched(SalaryMode mode) = _TabSwitched;
  const factory NetPayIntent.salaryChanged(int salary) = _SalaryChanged;
  const factory NetPayIntent.directInput(int salary) = _DirectInput;
  const factory NetPayIntent.unitChanged(AdjustUnit unit) = _UnitChanged;
  const factory NetPayIntent.adjust(int delta) = _Adjust;
  const factory NetPayIntent.dependentsChanged(int dependents) =
      _DependentsChanged;
}

class _TabSwitched extends NetPayIntent {
  final SalaryMode mode;
  const _TabSwitched(this.mode);
}

class _SalaryChanged extends NetPayIntent {
  final int salary;
  const _SalaryChanged(this.salary);
}

class _DirectInput extends NetPayIntent {
  final int salary;
  const _DirectInput(this.salary);
}

class _UnitChanged extends NetPayIntent {
  final AdjustUnit unit;
  const _UnitChanged(this.unit);
}

class _Adjust extends NetPayIntent {
  final int delta;
  const _Adjust(this.delta);
}

class _DependentsChanged extends NetPayIntent {
  final int dependents;
  const _DependentsChanged(this.dependents);
}

// ── Provider ────────────────────────────────────────────────────────────────

final netPayViewModelProvider =
    NotifierProvider.autoDispose<NetPayViewModel, NetPayState>(
        NetPayViewModel.new);

// ── ViewModel ───────────────────────────────────────────────────────────────

class NetPayViewModel extends AutoDisposeNotifier<NetPayState> {
  late final CalculateNetPayUseCase _useCase;

  @override
  NetPayState build() {
    _useCase = const CalculateNetPayUseCase(kFallbackTaxRates);
    const initial = NetPayState();
    return _recalculate(initial);
  }

  void handleIntent(NetPayIntent intent) {
    switch (intent) {
      case _TabSwitched(:final mode):
        _onTabSwitched(mode);
      case _SalaryChanged(:final salary):
        state = _recalculate(state.copyWith(salary: salary.clamp(0, 9999999999)));
      case _DirectInput(:final salary):
        state = _recalculate(state.copyWith(salary: salary.clamp(0, 9999999999)));
      case _UnitChanged(:final unit):
        state = state.copyWith(unit: unit);
      case _Adjust(:final delta):
        _onAdjust(delta);
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
    } else {
      converted = (state.salary / 12).round();
    }
    state = _recalculate(state.copyWith(mode: mode, salary: converted));
  }

  void _onAdjust(int delta) {
    final newSalary = (state.salary + delta * state.unit.value).clamp(0, 9999999999);
    state = _recalculate(state.copyWith(salary: newSalary));
  }

  NetPayState _recalculate(NetPayState s) {
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
