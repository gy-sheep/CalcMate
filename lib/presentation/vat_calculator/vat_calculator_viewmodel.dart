import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/default_tax_rates.dart';
import '../../domain/models/vat_calculator_state.dart';
import '../../domain/usecases/evaluate_expression_usecase.dart';
import '../../domain/usecases/vat_calculate_usecase.dart';
import '../../domain/utils/calculator_input_utils.dart';
import '../../domain/utils/digit_limit_policy.dart';
import '../../domain/utils/number_formatter.dart';

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────
sealed class VatCalculatorIntent {
  const VatCalculatorIntent();

  const factory VatCalculatorIntent.keyTapped(String key) = _KeyTapped;
  const factory VatCalculatorIntent.modeChanged(VatMode mode) = _ModeChanged;
  const factory VatCalculatorIntent.taxRateTapped() = _TaxRateTapped;
  const factory VatCalculatorIntent.amountTapped() = _AmountTapped;
}

class _KeyTapped extends VatCalculatorIntent {
  final String key;
  const _KeyTapped(this.key);
}

class _ModeChanged extends VatCalculatorIntent {
  final VatMode mode;
  const _ModeChanged(this.mode);
}

class _TaxRateTapped extends VatCalculatorIntent {
  const _TaxRateTapped();
}

class _AmountTapped extends VatCalculatorIntent {
  const _AmountTapped();
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────
final vatCalculatorViewModelProvider =
    NotifierProvider.autoDispose<VatCalculatorViewModel, VatCalculatorState>(
  VatCalculatorViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────
class VatCalculatorViewModel
    extends AutoDisposeNotifier<VatCalculatorState> {
  final _evaluator = EvaluateExpressionUseCase();
  final _vatUseCase = VatCalculateUseCase();

  @override
  VatCalculatorState build() {
    final locale = PlatformDispatcher.instance.locale;
    final defaultRate = getDefaultTaxRateForCountry(locale.countryCode);
    return VatCalculatorState(taxRate: defaultRate);
  }

  void handleIntent(VatCalculatorIntent intent) {
    switch (intent) {
      case _KeyTapped(:final key):
        _onKeyTap(key);
      case _ModeChanged(:final mode):
        _onModeChanged(mode);
      case _TaxRateTapped():
        _onTaxRateTapped();
      case _AmountTapped():
        _onAmountTapped();
    }
  }

  void clearToast() {
    state = state.copyWith(toastMessage: null);
  }

  // ── 계산 getters ──

  /// 현재 입력값을 수식으로 평가한 double 값.
  double get evaluatedInput {
    final raw = state.input.replaceAll(',', '');
    if (CalculatorInputUtils.endsWithOperator(raw)) {
      final trimmed = raw.substring(0, raw.length - 1);
      if (trimmed.isEmpty) return 0;
      return _evaluate(trimmed);
    }
    final result = _evaluate(raw);
    return result.isNaN ? 0 : result;
  }

  /// 부가세 계산 결과.
  VatResult get vatResult {
    return _vatUseCase.execute(
      inputValue: evaluatedInput,
      taxRate: state.taxRate,
      mode: state.mode,
    );
  }

  /// 입력값을 천 단위 콤마와 연산자 공백으로 포맷팅.
  String get formattedInput {
    if (state.input == '오류') return '오류';
    final raw = state.input;
    final buf = StringBuffer();
    final segment = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if ('+-×÷'.contains(ch) &&
          !(ch == '-' &&
              (i == 0 || '+-×÷'.contains(raw[i - 1])))) {
        if (segment.isNotEmpty) {
          buf.write(NumberFormatter.formatInput(segment.toString()));
          segment.clear();
        }
        buf.write(' $ch ');
      } else {
        segment.write(ch);
      }
    }
    if (segment.isNotEmpty) {
      buf.write(NumberFormatter.formatInput(segment.toString()));
    }
    return buf.isEmpty ? '0' : buf.toString();
  }

  /// 화면에 표시할 세율 (편집 중이면 입력값, 아니면 확정값).
  int get displayRate {
    if (state.inputTarget == InputTarget.taxRate &&
        state.taxRateInput.isNotEmpty) {
      return int.tryParse(state.taxRateInput) ?? state.taxRate;
    }
    return state.taxRate;
  }

  // ── Private 핸들러 ──

  void _onKeyTap(String key) {
    if (state.inputTarget == InputTarget.taxRate) {
      _handleTaxRateKey(key);
      return;
    }
    _handleAmountKey(key);
  }

  void _onModeChanged(VatMode mode) {
    if (state.inputTarget == InputTarget.taxRate) {
      _applyTaxRate();
      state = state.copyWith(mode: mode, inputTarget: InputTarget.amount);
    } else {
      state = state.copyWith(mode: mode);
    }
  }

  void _onAmountTapped() {
    if (state.inputTarget == InputTarget.taxRate) {
      _applyTaxRate();
      state = state.copyWith(inputTarget: InputTarget.amount);
    }
  }

  void _onTaxRateTapped() {
    if (state.inputTarget == InputTarget.taxRate) {
      _applyTaxRate();
      state = state.copyWith(inputTarget: InputTarget.amount);
    } else {
      state = state.copyWith(
        inputTarget: InputTarget.taxRate,
        taxRateInput: '',
      );
    }
  }

  void _handleAmountKey(String key) {
    var input = state.input;
    var isResult = state.isResult;

    switch (key) {
      case 'AC':
        state = state.copyWith(input: '0', isResult: false);
        return;

      case '\u{232B}': // backspace
        if (isResult) return;
        if (input.length <= 1 ||
            (input.length == 2 && input.startsWith('-'))) {
          input = '0';
        } else {
          input = input.substring(0, input.length - 1);
        }

      case '=':
        if (CalculatorInputUtils.endsWithOperator(input)) return;
        final raw = input.replaceAll(',', '');
        final resolved = CalculatorInputUtils.resolvePercent(raw);
        final expr =
            resolved.replaceAll('×', '*').replaceAll('÷', '/');
        final result = _evaluator.execute(expr);
        if (result.isNaN || result.isInfinite) {
          state = state.copyWith(input: '오류', isResult: true);
          return;
        }
        state = state.copyWith(
          input: NumberFormatter.rawFromDouble(result),
          isResult: true,
        );
        return;

      case '+' || '-' || '×' || '÷':
        if (isResult) {
          isResult = false;
        }
        if (CalculatorInputUtils.endsWithOperator(input)) {
          input = input.substring(0, input.length - 1) + key;
        } else {
          input += key;
        }

      case '%':
        if (isResult || CalculatorInputUtils.endsWithOperator(input)) {
          return;
        }
        final raw = input.replaceAll(',', '');
        input = CalculatorInputUtils.resolvePercent('$raw%');

      case '.':
        if (isResult) {
          input = '0.';
          isResult = false;
          break;
        }
        final lastSeg = CalculatorInputUtils.lastNumberSegment(input);
        if (lastSeg.contains('.')) return;
        input += '.';

      case '00':
        if (isResult) {
          input = '0';
          isResult = false;
          break;
        }
        if (input == '0') return;
        if (CalculatorInputUtils.endsWithOperator(input)) return;
        final lastSeg = CalculatorInputUtils.lastNumberSegment(input);
        if (lastSeg == '0') return;
        final check00 = DigitLimitPolicy.standard.check(lastSeg, '00');
        if (check00 != null) {
          final msg00 = _digitCheckToast(check00);
          if (msg00.isNotEmpty) state = state.copyWith(toastMessage: msg00);
          return;
        }
        final add00 = DigitLimitPolicy.standard.adjustDoubleZero(lastSeg,
            onExceed: (result) {
          state = state.copyWith(toastMessage: _digitCheckToast(result));
        });
        if (add00 == null) return;
        input += add00;

      default: // 숫자 0-9
        if (isResult) {
          input = key == '0' ? '0' : key;
          isResult = false;
          break;
        }
        if (CalculatorInputUtils.endsWithOperator(input)) {
          input += key;
          break;
        }
        final lastSeg = CalculatorInputUtils.lastNumberSegment(input);
        if (lastSeg == '0' && key == '0') return;
        if (lastSeg == '0' && !lastSeg.contains('.')) {
          final prefix = input.substring(0, input.length - 1);
          input = prefix + key;
          break;
        }
        final digitCheck = DigitLimitPolicy.standard.check(lastSeg, key);
        if (digitCheck != null) {
          final msg = _digitCheckToast(digitCheck);
          if (msg.isNotEmpty) state = state.copyWith(toastMessage: msg);
          return;
        }
        input += key;
    }

    state = state.copyWith(input: input, isResult: isResult);
  }

  void _handleTaxRateKey(String key) {
    switch (key) {
      case 'AC':
        state = state.copyWith(taxRateInput: '');
      case '\u{232B}':
        if (state.taxRateInput.isNotEmpty) {
          state = state.copyWith(
            taxRateInput: state.taxRateInput
                .substring(0, state.taxRateInput.length - 1),
          );
        }
      case '=' || '+' || '-' || '×' || '÷' || '%' || '.' || '00':
        _applyTaxRate();
        state = state.copyWith(inputTarget: InputTarget.amount);
      default: // 숫자 0-9
        final newInput = state.taxRateInput + key;
        final parsed = int.tryParse(newInput);
        if (parsed != null && parsed <= 99) {
          state = state.copyWith(taxRateInput: newInput);
        } else if (parsed != null && parsed > 99) {
          state = state.copyWith(
              toastMessage: '세율은 0~99% 범위로 입력하세요');
        }
    }
  }

  void _applyTaxRate() {
    final parsed = int.tryParse(state.taxRateInput);
    if (parsed != null) {
      state = state.copyWith(taxRate: parsed, taxRateInput: '');
    } else {
      state = state.copyWith(taxRateInput: '');
    }
  }

  double _evaluate(String expr) {
    return _evaluator.execute(
      expr.replaceAll('×', '*').replaceAll('÷', '/'),
    );
  }
}

// TODO: Phase 5에서 l10n으로 전환
String _digitCheckToast(DigitCheckResult result) => switch (result) {
      DigitCheckResult.integerExceeded => '최대 12자리까지 입력 가능합니다',
      DigitCheckResult.fractionalExceeded => '소수점 이하 8자리까지 입력 가능합니다',
      DigitCheckResult.decimalNotAllowed => '',
    };
