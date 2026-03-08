import 'package:freezed_annotation/freezed_annotation.dart';
import '../usecases/bmi_calculate_usecase.dart';

part 'bmi_calculator_state.freezed.dart';

@freezed
class BmiCalculatorState with _$BmiCalculatorState {
  const factory BmiCalculatorState({
    @Default(170.0) double heightCm,
    @Default(65.0) double weightKg,
    @Default(true) bool isMetric,
    @Default(BmiStandard.global) BmiStandard standard,
  }) = _BmiCalculatorState;
}
