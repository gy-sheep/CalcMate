import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/age_calculator_state.dart';
import '../../domain/usecases/age_calculate_usecase.dart';
import '../../domain/usecases/lunar_converter.dart';

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
      day: now.day.clamp(1, _solarDaysInMonth(defaultYear, now.month)),
    );
  }

  void handleIntent(AgeCalculatorIntent intent) {
    switch (intent) {
      case _CalendarTypeChanged(:final type):
        final now = DateTime.now();
        final defaultYear = now.year - 30;
        final month = now.month;
        final maxDay = type == AgeCalendarType.solar
            ? _solarDaysInMonth(defaultYear, month)
            : LunarConverter.daysInMonth(defaultYear, month);
        final day = now.day.clamp(1, maxDay);
        state = AgeCalculatorState(
          calendarType: type,
          year: defaultYear,
          month: month,
          day: day,
          convertedSolarDate: type == AgeCalendarType.lunar
              ? LunarConverter.toSolar(defaultYear, month, day)
              : null,
        );

      case _YearChanged(:final year):
        final maxDay = maxDaysForCurrentMonth(year: year, month: state.month);
        final day = state.day.clamp(1, maxDay);
        // 윤달이 더 이상 없는 연도로 바뀌면 isLeapMonth 해제
        final isLeap = state.isLeapMonth &&
            LunarConverter.hasLeapMonth(year, state.month);
        state = state.copyWith(
          year: year,
          day: day,
          isLeapMonth: isLeap,
          convertedSolarDate: state.calendarType == AgeCalendarType.lunar
              ? LunarConverter.toSolar(year, state.month, day, isLeap: isLeap)
              : null,
        );

      case _MonthChanged(:final month):
        final maxDay = maxDaysForCurrentMonth(year: state.year, month: month);
        final day = state.day.clamp(1, maxDay);
        final isLeap = false; // 월 변경 시 윤달 해제
        state = state.copyWith(
          month: month,
          day: day,
          isLeapMonth: isLeap,
          convertedSolarDate: state.calendarType == AgeCalendarType.lunar
              ? LunarConverter.toSolar(state.year, month, day)
              : null,
        );

      case _DayChanged(:final day):
        state = state.copyWith(
          day: day,
          convertedSolarDate: state.calendarType == AgeCalendarType.lunar
              ? LunarConverter.toSolar(
                  state.year, state.month, day,
                  isLeap: state.isLeapMonth,
                )
              : null,
        );

      case _LeapMonthToggled(:final isLeap):
        state = state.copyWith(
          isLeapMonth: isLeap,
          convertedSolarDate: state.calendarType == AgeCalendarType.lunar
              ? LunarConverter.toSolar(
                  state.year, state.month, state.day,
                  isLeap: isLeap,
                )
              : null,
        );
    }
  }

  /// 현재 state 기준 나이 계산 결과. 미래 날짜면 null.
  AgeResult? get ageResult {
    try {
      final birth = state.calendarType == AgeCalendarType.lunar
          ? state.convertedSolarDate
          : DateTime(state.year, state.month, state.day);
      if (birth == null) return null;

      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      if (birth.isAfter(todayOnly)) return null;
      return _useCase.execute(birthDate: birth, today: todayOnly);
    } catch (_) {
      return null;
    }
  }

  /// 해당 연·월의 최대 일수.
  /// 음력 모드면 음력 기준, 양력 모드면 양력 기준.
  int maxDaysForCurrentMonth({int? year, int? month}) {
    final y = year ?? state.year;
    final m = month ?? state.month;
    if (state.calendarType == AgeCalendarType.lunar) {
      return LunarConverter.daysInMonth(y, m, isLeap: state.isLeapMonth);
    }
    return _solarDaysInMonth(y, m);
  }

  /// 현재 연·월에 윤달이 존재하는지 여부.
  bool get hasLeapMonth {
    if (state.calendarType != AgeCalendarType.lunar) return false;
    return LunarConverter.hasLeapMonth(state.year, state.month);
  }

  int _solarDaysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// 앱 포그라운드 복귀 시 결과 갱신을 위한 state touch.
  void refreshToday() {
    state = state.copyWith();
  }
}
