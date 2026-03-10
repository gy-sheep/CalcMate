import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit_converter_state.freezed.dart';

@freezed
class UnitConverterState with _$UnitConverterState {
  const factory UnitConverterState({
    @Default(0) int selectedCategoryIndex,
    @Default('cm') String activeUnitCode,
    @Default('0') String input,
    @Default(false) bool isResult,
    @Default({}) Map<String, String> convertedValues,
    @Default({}) Map<String, double> rawConvertedValues,
    String? toastMessage,
  }) = _UnitConverterState;
}
