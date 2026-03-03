import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/age_calculator_state.dart';
import '../../domain/usecases/age_calculate_usecase.dart';

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────
sealed class AgeCalculatorIntent {
  const AgeCalculatorIntent();

  const factory AgeCalculatorIntent.calendarTypeChanged(
      AgeCalendarType type) = _CalendarTypeChanged;
  const factory AgeCalculatorIntent.yearChanged(int year) = _YearChanged;
  const factory AgeCalculatorIntent.monthChanged(int month) = _MonthChanged;
  const factory AgeCalculatorIntent.dayChanged(int day) = _DayChanged;
  const factory AgeCalculatorIntent.leapMonthToggled(bool isLeap) =
      _LeapMonthToggled;
}

class _CalendarTypeChanged extends AgeCalculatorIntent {
  final AgeCalendarType type;
  const _CalendarTypeChanged(this.type);
}

class _YearChanged extends AgeCalculatorIntent {
  final int year;
  const _YearChanged(this.year);
}

class _MonthChanged extends AgeCalculatorIntent {
  final int month;
  const _MonthChanged(this.month);
}

class _DayChanged extends AgeCalculatorIntent {
  final int day;
  const _DayChanged(this.day);
}

class _LeapMonthToggled extends AgeCalculatorIntent {
  final bool isLeap;
  const _LeapMonthToggled(this.isLeap);
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────
final ageCalculatorViewModelProvider =
    NotifierProvider.autoDispose<AgeCalculatorViewModel, AgeCalculatorState>(
  AgeCalculatorViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────
class AgeCalculatorViewModel extends AutoDisposeNotifier<AgeCalculatorState> {
  final _useCase = AgeCalculateUseCase();

  @override
  AgeCalculatorState build() {
    final now = DateTime.now();
    final defaultYear = now.year - 30;
    return AgeCalculatorState(
      year: defaultYear,
      month: now.month,
      day: now.day.clamp(1, _daysInMonth(defaultYear, now.month)),
    );
  }

  void handleIntent(AgeCalculatorIntent intent) {
    switch (intent) {
      case _CalendarTypeChanged(:final type):
        state = state.copyWith(calendarType: type, isLeapMonth: false);
      case _YearChanged(:final year):
        final maxDay = _daysInMonth(year, state.month);
        state = state.copyWith(year: year, day: state.day.clamp(1, maxDay));
      case _MonthChanged(:final month):
        final maxDay = _daysInMonth(state.year, month);
        state =
            state.copyWith(month: month, day: state.day.clamp(1, maxDay), isLeapMonth: false);
      case _DayChanged(:final day):
        state = state.copyWith(day: day);
      case _LeapMonthToggled(:final isLeap):
        state = state.copyWith(isLeapMonth: isLeap);
    }
  }

  /// 현재 state 기준 나이 계산 결과. 미래 날짜면 null.
  AgeResult? get ageResult {
    try {
      final birth = DateTime(state.year, state.month, state.day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      if (birth.isAfter(todayOnly)) return null;
      return _useCase.execute(birthDate: birth, today: todayOnly);
    } catch (_) {
      return null;
    }
  }

  /// 해당 연·월의 최대 일수 (양력 기준).
  int maxDaysForCurrentMonth() =>
      _daysInMonth(state.year, state.month);

  int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// 앱 포그라운드 복귀 시 결과 갱신을 위한 state touch.
  void refreshToday() {
    // ageResult getter는 DateTime.now()를 매번 읽으므로
    // state를 새 인스턴스로 교체해 listener를 트리거한다.
    state = state.copyWith();
  }
}
