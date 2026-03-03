import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/error_messages.dart';
import '../../core/di/providers.dart';
import '../../domain/models/exchange_rate_entity.dart';
import '../../domain/usecases/evaluate_expression_usecase.dart';
import '../../domain/usecases/get_exchange_rate_usecase.dart';
import '../../domain/utils/calculator_input_utils.dart';
import '../../domain/utils/number_formatter.dart';

part 'currency_calculator_viewmodel.freezed.dart';

// ──────────────────────────────────────────
// State
// ──────────────────────────────────────────
@freezed
class ExchangeRateState with _$ExchangeRateState {
  const factory ExchangeRateState({
    @Default({}) Map<String, double> rates,
    @Default('KRW') String fromCode,
    @Default(['USD', 'EUR', 'JPY']) List<String> toCodes,
    @Default('0') String input,
    @Default(false) bool isResult,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
    String? toastMessage,
    DateTime? lastUpdated,
  }) = _ExchangeRateState;
}

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────
sealed class ExchangeRateIntent {
  const ExchangeRateIntent();

  const factory ExchangeRateIntent.keyTapped(String key) = _KeyTapped;
  const factory ExchangeRateIntent.fromCurrencyChanged(String code) =
      _FromCurrencyChanged;
  const factory ExchangeRateIntent.toCurrencyChanged(int index, String code) =
      _ToCurrencyChanged;
  const factory ExchangeRateIntent.refreshRequested() = _RefreshRequested;
}

class _KeyTapped extends ExchangeRateIntent {
  final String key;
  const _KeyTapped(this.key);
}

class _FromCurrencyChanged extends ExchangeRateIntent {
  final String code;
  const _FromCurrencyChanged(this.code);
}

class _ToCurrencyChanged extends ExchangeRateIntent {
  final int index;
  final String code;
  const _ToCurrencyChanged(this.index, this.code);
}

class _RefreshRequested extends ExchangeRateIntent {
  const _RefreshRequested();
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────
final exchangeRateViewModelProvider =
    NotifierProvider.autoDispose<ExchangeRateViewModel, ExchangeRateState>(
  ExchangeRateViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────
class ExchangeRateViewModel extends AutoDisposeNotifier<ExchangeRateState> {
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
      case _KeyTapped(:final key):
        _onKeyTap(key);
      case _FromCurrencyChanged(:final code):
        final swapIndex = state.toCodes.indexOf(code);
        if (swapIndex >= 0) {
          // 선택한 통화가 To에 있으면 swap
          final updated = List<String>.from(state.toCodes);
          updated[swapIndex] = state.fromCode;
          state = state.copyWith(fromCode: code, toCodes: updated, input: '0');
        } else {
          state = state.copyWith(fromCode: code, input: '0');
        }
      case _ToCurrencyChanged(:final index, :final code):
        final updated = List<String>.from(state.toCodes);
        updated[index] = code;
        state = state.copyWith(toCodes: updated);
      case _RefreshRequested():
        _refreshRates();
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
    if (input == '정의되지 않음') return 0;
    final simple = double.tryParse(input);
    if (simple != null) return simple;
    if (CalculatorInputUtils.endsWithOperator(input)) return 0;
    try {
      final resolved = CalculatorInputUtils.resolvePercent(input);
      final result = _evaluateUseCase
          .execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
      return (result.isNaN || result.isInfinite) ? 0 : result;
    } catch (_) {
      return 0;
    }
  }

  /// 입력값에 천 단위 콤마를 적용한 표시 문자열
  String get formattedInput {
    final input = state.input;
    if (input == '정의되지 않음') return input;
    return input.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)'),
      (m) {
        final parts = m.group(0)!.split('.');
        parts[0] = NumberFormatter.addCommas(parts[0]);
        return parts.join('.');
      },
    );
  }

  /// index번째 To 통화의 환산 결과 텍스트
  String convertedDisplayAt(int index) {
    final result =
        convert(evaluatedInput, state.fromCode, state.toCodes[index]);
    return NumberFormatter.formatAmount(result);
  }

  /// index번째 To 통화의 1단위 환율 힌트 텍스트 (예: "1 KRW = 0.0007 USD")
  String unitRateDisplayAt(int index) {
    if (state.rates.isEmpty) return '';
    final toCode = state.toCodes[index];
    final rate = convert(1.0, state.fromCode, toCode);
    if (rate == 0) return '';
    return '1 ${state.fromCode} = ${NumberFormatter.formatAmount(rate)} $toCode';
  }

  /// 수동 새로고침: 스피너를 최소 800ms 표시 후 종료
  Future<void> _refreshRates() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, error: null);

    ExchangeRateEntity? entity;
    try {
      await Future.wait<void>([
        _getExchangeRateUseCase.execute().then((e) => entity = e),
        Future.delayed(const Duration(milliseconds: 800)),
      ]);
    } catch (e) {
      debugPrint('[ExchangeRateVM] refreshRates failed: $e');
    }

    state = state.copyWith(
      isRefreshing: false,
      rates: entity?.rates ?? state.rates,
      lastUpdated: entity != null
          ? DateTime.fromMillisecondsSinceEpoch(entity!.timestamp)
          : state.lastUpdated,
    );
  }

  Future<void> _loadRates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entity = await _getExchangeRateUseCase.execute();
      final isFallback = entity.timestamp == 0;
      state = state.copyWith(
        rates: entity.rates,
        isLoading: false,
        lastUpdated: isFallback
            ? null
            : DateTime.fromMillisecondsSinceEpoch(entity.timestamp),
        toastMessage: isFallback ? ErrorMessages.exchangeRateUsingFallback : null,
      );
    } catch (e) {
      debugPrint('[ExchangeRateVM] loadRates failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: ErrorMessages.exchangeRateLoadFailed,
      );
    }
  }

  void _onKeyTap(String key) {
    var input = state.input;
    var isResult = state.isResult;

    switch (key) {
      case 'AC':
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
        if (isResult || CalculatorInputUtils.endsWithOperator(input)) return;
        input = CalculatorInputUtils.resolvePercent('$input%');

      case '÷' || '×' || '-' || '+':
        if (isResult) isResult = false;
        if (CalculatorInputUtils.endsWithOperator(input)) {
          input = input.substring(0, input.length - 1) + key;
        } else if (input != '0') {
          input += key;
        }

      case '=':
        if (CalculatorInputUtils.endsWithOperator(input)) return;
        final resolved = CalculatorInputUtils.resolvePercent(input);
        final result = _evaluateUseCase
            .execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
        input = NumberFormatter.formatResult(result);
        isResult = true;

      case '.':
        if (isResult) {
          input = '0.';
          isResult = false;
          break;
        }
        final last = CalculatorInputUtils.lastNumberSegment(input);
        if (!last.contains('.')) {
          if (CalculatorInputUtils.endsWithOperator(input) || input.isEmpty) {
            input += '0.';
          } else {
            input += '.';
          }
        }

      case '00':
        if (isResult) {
          input = '0';
          isResult = false;
          break;
        }
        // 연산자 직후: 0 하나만 추가
        if (CalculatorInputUtils.endsWithOperator(input)) {
          input += '0';
          break;
        }
        // 선행 0 방지: 마지막 세그먼트가 '0'이면 무시
        if (input == '0' || input == '-0') break;
        final seg00 = CalculatorInputUtils.lastNumberSegment(input);
        if (seg00 == '0' || seg00 == '-0') break;
        // 자릿수 제한 체크
        final clean00 = seg00.startsWith('-') ? seg00.substring(1) : seg00;
        if (clean00.contains('.')) {
          final fracLen = clean00.split('.')[1].length;
          if (fracLen >= 8) {
            state = state.copyWith(toastMessage: '소수점 이하 8자리까지 입력 가능합니다');
            return;
          }
          // 남은 자릿수에 따라 0 1개 또는 2개 추가
          input += (fracLen >= 7) ? '0' : '00';
        } else {
          final intLen = clean00.length;
          if (intLen >= 12) {
            state = state.copyWith(toastMessage: '최대 12자리까지 입력 가능합니다');
            return;
          }
          input += (intLen >= 11) ? '0' : '00';
        }

      default: // 숫자
        if (isResult) {
          input = key == '0' ? '0' : key;
          isResult = false;
          break;
        }
        // 자릿수 제한 체크
        final seg = CalculatorInputUtils.lastNumberSegment(input);
        final segClean = seg.startsWith('-') ? seg.substring(1) : seg;
        if (segClean.contains('.')) {
          if (segClean.split('.')[1].length >= 8) {
            state = state.copyWith(toastMessage: '소수점 이하 8자리까지 입력 가능합니다');
            return;
          }
        } else if (segClean.length >= 12) {
          state = state.copyWith(toastMessage: '최대 12자리까지 입력 가능합니다');
          return;
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

  void clearToast() {
    state = state.copyWith(toastMessage: null);
  }
}
