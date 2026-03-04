import 'package:freezed_annotation/freezed_annotation.dart';

part 'age_calculator_state.freezed.dart';

enum AgeCalendarType { solar, lunar }

@freezed
class AgeCalculatorState with _$AgeCalculatorState {
  const factory AgeCalculatorState({
    @Default(AgeCalendarType.solar) AgeCalendarType calendarType,
    required int year,
    @Default(1) int month,
    @Default(1) int day,
    @Default(false) bool isLeapMonth,
    /// 음력 모드에서 변환된 양력 날짜. 양력 모드에서는 null.
    DateTime? convertedSolarDate,
  }) = _AgeCalculatorState;
}
