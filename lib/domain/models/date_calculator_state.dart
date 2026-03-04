import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_calculator_state.freezed.dart';

@freezed
class DateCalculatorState with _$DateCalculatorState {
  const factory DateCalculatorState({
    @Default(0) int mode,
    // 모드 0: 기간 계산
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(false) bool includeStartDay,
    // 모드 1: 날짜 계산
    required DateTime calcBase,
    @Default('100') String calcNumberInput,
    @Default(0) int calcDirection, // 0=더하기, 1=빼기
    @Default(0) int calcUnit,      // 0=일, 1=주, 2=월, 3=년
    // 모드 2: D-Day
    required DateTime ddayTarget,
    required DateTime ddayReference,
    @Default(true) bool ddayRefIsToday,
  }) = _DateCalculatorState;
}
