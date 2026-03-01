import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/di/providers.dart';
import '../../domain/usecases/evaluate_expression_usecase.dart';
import '../../domain/usecases/get_exchange_rate_usecase.dart';

part 'currency_calculator_viewmodel.freezed.dart';

// ──────────────────────────────────────────
// State
// ──────────────────────────────────────────
@freezed
class ExchangeRateState with _$ExchangeRateState {
  const factory ExchangeRateState({
    @Default({}) Map<String, double> rates,
    @Default('USD') String fromCode,
    @Default('KRW') String toCode,
    @Default('0') String input,
    @Default(true) bool isFromActive,
    @Default(false) bool isResult,
    @Default(false) bool isLoading,
    String? error,
    DateTime? lastUpdated,
  }) = _ExchangeRateState;
}

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────
sealed class ExchangeRateIntent {
  const ExchangeRateIntent();
}

class KeyTapped extends ExchangeRateIntent {
  final String key;
  const KeyTapped(this.key);
}

class FromCurrencyChanged extends ExchangeRateIntent {
  final String code;
  const FromCurrencyChanged(this.code);
}

class ToCurrencyChanged extends ExchangeRateIntent {
  final String code;
  const ToCurrencyChanged(this.code);
}

class Swapped extends ExchangeRateIntent {
  const Swapped();
}

class ActiveRowChanged extends ExchangeRateIntent {
  final bool isFrom;
  const ActiveRowChanged(this.isFrom);
}

class RefreshRequested extends ExchangeRateIntent {
  const RefreshRequested();
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────
final exchangeRateViewModelProvider =
    NotifierProvider<ExchangeRateViewModel, ExchangeRateState>(
  ExchangeRateViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────
class ExchangeRateViewModel extends Notifier<ExchangeRateState> {
  late final GetExchangeRateUseCase _getExchangeRateUseCase;
  final _evaluateUseCase = EvaluateExpressionUseCase();

  @override
  ExchangeRateState build() {
    _getExchangeRateUseCase = ref.read(getExchangeRateUseCaseProvider);
    Future.microtask(_loadRates);
    return const ExchangeRateState();
  }

  void handleIntent(ExchangeRateIntent intent) {
    switch (intent) {
      case KeyTapped(:final key):
        _onKeyTap(key);
      case FromCurrencyChanged(:final code):
        state = state.copyWith(fromCode: code, input: '0');
      case ToCurrencyChanged(:final code):
        state = state.copyWith(toCode: code, input: '0');
      case Swapped():
        state = state.copyWith(
          fromCode: state.toCode,
          toCode: state.fromCode,
          input: '0',
        );
      case ActiveRowChanged(:final isFrom):
        state = state.copyWith(isFromActive: isFrom);
      case RefreshRequested():
        _loadRates();
    }
  }

  /// 교차환율 변환: amount 단위의 from 통화를 to 통화로 변환
  double convert(double amount, String from, String to) {
    if (state.rates.isEmpty) return 0;
    final fromRate = state.rates[from];
    final toRate = state.rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return 0;
    return amount * (toRate / fromRate);
  }

  /// 현재 입력값을 수치로 평가 (수식 포함)
  double get evaluatedInput {
    final input = state.input;
    if (input == '오류') return 0;
    final simple = double.tryParse(input);
    if (simple != null) return simple;
    if (_endsWithOperator(input)) return 0;
    try {
      final resolved = _resolvePercent(input);
      final result = _evaluateUseCase
          .execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
      return (result.isNaN || result.isInfinite) ? 0 : result;
    } catch (_) {
      return 0;
    }
  }

  /// 환산 결과 텍스트
  String get convertedDisplay {
    if (!state.isFromActive) return state.input;
    final result = convert(evaluatedInput, state.fromCode, state.toCode);
    return _formatAmount(result);
  }

  /// 역방향 환산 결과 텍스트
  String get reverseConvertedDisplay {
    if (state.isFromActive) return state.input;
    final amount = double.tryParse(state.input) ?? 0;
    final result = convert(amount, state.toCode, state.fromCode);
    return _formatAmount(result);
  }

  bool get isAcState {
    final input = state.input;
    if (input == '0' || input == '-') return true;
    if (input.length == 2 && input[0] == '0') {
      return const {'+', '-', '×', '÷'}.contains(input[1]);
    }
    return false;
  }

  Future<void> _loadRates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entity = await _getExchangeRateUseCase.execute();
      state = state.copyWith(
        rates: entity.rates,
        isLoading: false,
        lastUpdated: entity.fetchedAt,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '환율 정보를 불러올 수 없습니다',
      );
    }
  }

  void _onKeyTap(String key) {
    var input = state.input;
    var isResult = state.isResult;

    switch (key) {
      case 'AC' || 'C':
        input = '0';
        isResult = false;

      case '⌫':
        if (isResult) {
          input = '0';
          isResult = false;
          break;
        }
        if (input.length > 1) {
          input = input.substring(0, input.length - 1);
        } else {
          input = '0';
        }

      case '%':
        if (input.endsWith('%')) return;
        if (_endsWithOperator(input)) return;
        input += '%';

      case '÷' || '×' || '-' || '+':
        if (isResult) isResult = false;
        if (_endsWithOperator(input)) {
          input = input.substring(0, input.length - 1) + key;
        } else if (input == '0' && key == '-') {
          input = '-';
        } else if (input != '0') {
          input += key;
        }

      case '=':
        if (_endsWithOperator(input)) return;
        final resolved = _resolvePercent(input);
        final result = _evaluateUseCase
            .execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
        input = _formatResult(result);
        isResult = true;

      case '+/-':
        final last = _lastNumberSegment(input);
        if (last.isEmpty) return;
        final prefix = input.substring(0, input.length - last.length);
        input = last.startsWith('-')
            ? prefix + last.substring(1)
            : '$prefix-$last';

      case '.':
        if (isResult) {
          input = '0.';
          isResult = false;
          break;
        }
        final last = _lastNumberSegment(input);
        if (!last.contains('.')) {
          if (_endsWithOperator(input) || input.isEmpty) {
            input += '0.';
          } else {
            input += '.';
          }
        }

      default: // 숫자
        if (isResult) {
          input = key == '0' ? '0' : key;
          isResult = false;
          break;
        }
        if (input == '0') {
          input = key;
        } else if (input == '-0') {
          input = key == '0' ? '-0' : '-$key';
        } else {
          input += key;
        }
    }

    state = state.copyWith(input: input, isResult: isResult);
  }

  // ── 유틸리티 ──

  bool _endsWithOperator(String s) {
    if (s.isEmpty) return false;
    final last = s[s.length - 1];
    return last == '+' || last == '-' || last == '×' || last == '÷';
  }

  String _lastNumberSegment(String s) {
    final ops = {'+', '×', '÷'};
    int i = s.length - 1;
    while (i >= 0) {
      final ch = s[i];
      if (ops.contains(ch)) break;
      if (ch == '-' && i > 0 && !ops.contains(s[i - 1])) break;
      i--;
    }
    return s.substring(i + 1);
  }

  String _resolvePercent(String raw) {
    var expr = raw;
    expr = expr.replaceAllMapped(
      RegExp(r'(-?\d+(?:\.\d*)?)([+\-])(\d+(?:\.\d*)?)%'),
      (m) {
        final left = double.tryParse(m.group(1)!) ?? 0;
        final right = double.tryParse(m.group(3)!) ?? 0;
        return '${m.group(1)}${m.group(2)}${left * right / 100}';
      },
    );
    expr = expr.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d*)?)%'),
      (m) {
        final val = double.tryParse(m.group(1)!) ?? 0;
        return '${val / 100}';
      },
    );
    return expr;
  }

  String _formatResult(double value) {
    if (value == double.infinity || value == double.negativeInfinity) {
      return '오류';
    }
    if (value.isNaN) return '오류';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(10);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  String _formatAmount(double value) {
    if (value == 0) return '0';
    if (value >= 1000) return value.toStringAsFixed(0);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }
}
