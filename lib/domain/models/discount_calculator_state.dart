import 'package:freezed_annotation/freezed_annotation.dart';

part 'discount_calculator_state.freezed.dart';

enum ActiveField { originalPrice, discountRate, extraDiscountRate }

@freezed
class DiscountCalculatorState with _$DiscountCalculatorState {
  const factory DiscountCalculatorState({
    @Default('') String originalPrice,
    @Default('') String discountRate,
    @Default(false) bool showExtra,
    @Default('') String extraRate,
    @Default(null) int? selectedChip,
    @Default(null) int? selectedExtraChip,
    @Default(ActiveField.originalPrice) ActiveField activeField,
  }) = _DiscountCalculatorState;
}
