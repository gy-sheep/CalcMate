import 'package:freezed_annotation/freezed_annotation.dart';

import '../usecases/vat_calculate_usecase.dart';

part 'vat_calculator_state.freezed.dart';

/// 부가세 계산기 입력 대상.
enum InputTarget { amount, taxRate }

@freezed
class VatCalculatorState with _$VatCalculatorState {
  const factory VatCalculatorState({
    @Default(VatMode.inclusive) VatMode mode,
    @Default(InputTarget.amount) InputTarget inputTarget,
    @Default('0') String input,
    @Default(false) bool isResult,
    @Default(10) int taxRate,
    @Default('') String taxRateInput,
    String? toastMessage,
  }) = _VatCalculatorState;
}
