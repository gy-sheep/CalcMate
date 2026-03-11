import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/date_calculator_state.dart';
import '../../domain/usecases/date_calculate_usecase.dart';

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────

sealed class DateCalculatorIntent {
  const DateCalculatorIntent();

  const factory DateCalculatorIntent.modeChanged(int mode) = _ModeChanged;
  const factory DateCalculatorIntent.periodStartChanged(DateTime date) =
      _PeriodStartChanged;
  const factory DateCalculatorIntent.periodEndChanged(DateTime date) =
      _PeriodEndChanged;
  const factory DateCalculatorIntent.includeStartDayToggled() =
      _IncludeStartDayToggled;
  const factory DateCalculatorIntent.calcBaseChanged(DateTime date) =
      _CalcBaseChanged;
  const factory DateCalculatorIntent.keyPressed(String key) = _KeyPressed;
  const factory DateCalculatorIntent.calcDirectionChanged(int direction) =
      _CalcDirectionChanged;
  const factory DateCalculatorIntent.calcUnitChanged(int unit) = _CalcUnitChanged;
  const factory DateCalculatorIntent.numberStepped(int delta) = _NumberStepped;
  const factory DateCalculatorIntent.calcNumberChanged(int value) = _CalcNumberChanged;
  const factory DateCalculatorIntent.ddayTargetChanged(DateTime date) =
      _DDayTargetChanged;
  const factory DateCalculatorIntent.ddayReferenceChanged(DateTime date) =
      _DDayReferenceChanged;
}

class _ModeChanged extends DateCalculatorIntent {
  final int mode;
  const _ModeChanged(this.mode);
}

class _PeriodStartChanged extends DateCalculatorIntent {
  final DateTime date;
  const _PeriodStartChanged(this.date);
}

class _PeriodEndChanged extends DateCalculatorIntent {
  final DateTime date;
  const _PeriodEndChanged(this.date);
}

class _IncludeStartDayToggled extends DateCalculatorIntent {
  const _IncludeStartDayToggled();
}

class _CalcBaseChanged extends DateCalculatorIntent {
  final DateTime date;
  const _CalcBaseChanged(this.date);
}

class _KeyPressed extends DateCalculatorIntent {
  final String key;
  const _KeyPressed(this.key);
}

class _CalcDirectionChanged extends DateCalculatorIntent {
  final int direction;
  const _CalcDirectionChanged(this.direction);
}

class _CalcUnitChanged extends DateCalculatorIntent {
  final int unit;
  const _CalcUnitChanged(this.unit);
}

class _NumberStepped extends DateCalculatorIntent {
  final int delta;
  const _NumberStepped(this.delta);
}

class _CalcNumberChanged extends DateCalculatorIntent {
  final int value;
  const _CalcNumberChanged(this.value);
}

class _DDayTargetChanged extends DateCalculatorIntent {
  final DateTime date;
  const _DDayTargetChanged(this.date);
}

class _DDayReferenceChanged extends DateCalculatorIntent {
  final DateTime date;
  const _DDayReferenceChanged(this.date);
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────

final dateCalculatorViewModelProvider = NotifierProvider.autoDispose<
    DateCalculatorViewModel, DateCalculatorState>(
  DateCalculatorViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────

class DateCalculatorViewModel
    extends AutoDisposeNotifier<DateCalculatorState> {
  final _useCase = DateCalculateUseCase();

  @override
  DateCalculatorState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateCalculatorState(
      periodStart: today,
      periodEnd: today.add(const Duration(days: 30)),
      calcBase: today,
      ddayTarget: today.add(const Duration(days: 100)),
      ddayReference: today,
    );
  }

  void handleIntent(DateCalculatorIntent intent) {
    switch (intent) {
      case _ModeChanged(:final mode):
        state = state.copyWith(mode: mode);

      case _PeriodStartChanged(:final date):
        state = state.copyWith(
            periodStart: DateTime(date.year, date.month, date.day));

      case _PeriodEndChanged(:final date):
        state = state.copyWith(
            periodEnd: DateTime(date.year, date.month, date.day));

      case _IncludeStartDayToggled():
        state = state.copyWith(includeStartDay: !state.includeStartDay);

      case _CalcBaseChanged(:final date):
        state = state.copyWith(
            calcBase: DateTime(date.year, date.month, date.day));

      case _KeyPressed(:final key):
        if (key == '+/-') {
          state = state.copyWith(
              calcDirection: state.calcDirection == 0 ? 1 : 0);
        } else {
          _handleKey(key);
        }

      case _CalcDirectionChanged(:final direction):
        state = state.copyWith(calcDirection: direction);

      case _CalcUnitChanged(:final unit):
        state = state.copyWith(calcUnit: unit);

      case _NumberStepped(:final delta):
        final next = (calcNumber + delta).clamp(0, 9999);
        state = state.copyWith(calcNumberInput: next.toString());

      case _CalcNumberChanged(:final value):
        state = state.copyWith(calcNumberInput: value.clamp(0, 9999).toString());

      case _DDayTargetChanged(:final date):
        state = state.copyWith(
            ddayTarget: DateTime(date.year, date.month, date.day));

      case _DDayReferenceChanged(:final date):
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final normalized = DateTime(date.year, date.month, date.day);
        state = state.copyWith(
          ddayReference: normalized,
          ddayRefIsToday: normalized == today,
        );
    }
  }

  void _handleKey(String key) {
    final current = state.calcNumberInput;
    String next;
    if (key == 'AC') {
      next = '0';
    } else if (key == '⌫') {
      next = current.length <= 1 ? '0' : current.substring(0, current.length - 1);
    } else {
      if (current == '0') {
        next = key;
      } else {
        final candidate = '$current$key';
        final val = int.tryParse(candidate);
        next = (val != null && val <= 9999) ? candidate : current;
      }
    }
    state = state.copyWith(calcNumberInput: next);
  }

  // ── Computed getters ──────────────────────────────────

  PeriodResult get periodResult => _useCase.calculatePeriod(
        state.periodStart, state.periodEnd, state.includeStartDay);

  DateTime get calcResult => _useCase.calculateDate(
        state.calcBase, calcNumber, state.calcUnit, state.calcDirection);

  DDayResult get ddayResult =>
      _useCase.calculateDDay(state.ddayTarget, state.ddayReference);

  int get calcNumber => int.tryParse(state.calcNumberInput) ?? 0;
}
