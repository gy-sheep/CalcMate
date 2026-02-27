import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculator_state.freezed.dart';

@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    @Default('0') String input,
    @Default('') String expression,
    @Default(false) bool isResult,
  }) = _CalculatorState;
}
