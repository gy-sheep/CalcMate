import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/unit_definitions.dart';
import '../../domain/models/unit_converter_state.dart';
import '../../domain/usecases/convert_unit_usecase.dart';

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────
sealed class UnitConverterIntent {
  const UnitConverterIntent();

  const factory UnitConverterIntent.keyTapped(String key) = _KeyTapped;
  const factory UnitConverterIntent.categorySelected(int index) =
      _CategorySelected;
  const factory UnitConverterIntent.unitTapped(String code) = _UnitTapped;
  const factory UnitConverterIntent.arrowTapped(int direction) = _ArrowTapped;
}

class _KeyTapped extends UnitConverterIntent {
  final String key;
  const _KeyTapped(this.key);
}

class _CategorySelected extends UnitConverterIntent {
  final int index;
  const _CategorySelected(this.index);
}

class _UnitTapped extends UnitConverterIntent {
  final String code;
  const _UnitTapped(this.code);
}

class _ArrowTapped extends UnitConverterIntent {
  final int direction;
  const _ArrowTapped(this.direction);
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────
final unitConverterViewModelProvider =
    NotifierProvider.autoDispose<UnitConverterViewModel, UnitConverterState>(
  UnitConverterViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────
class UnitConverterViewModel extends AutoDisposeNotifier<UnitConverterState> {
  final _convertUseCase = ConvertUnitUseCase();

  @override
  UnitConverterState build() {
    final category = unitCategories[0];
    final initial = const UnitConverterState().copyWith(
      activeUnitCode: category.defaultCode,
    );
    // 초기 변환 결과 계산
    return _recalculate(initial);
  }

  void handleIntent(UnitConverterIntent intent) {
    switch (intent) {
      case _KeyTapped(:final key):
        _onKeyTap(key);
      case _CategorySelected(:final index):
        _onCategorySelected(index);
      case _UnitTapped(:final code):
        _onUnitTapped(code);
      case _ArrowTapped(:final direction):
        _onArrow(direction);
    }
  }

  void clearToast() {
    state = state.copyWith(toastMessage: null);
  }

  /// 활성 단위의 입력값을 천 단위 콤마로 포맷팅
  String get formattedInput {
    return _formatInput(state.input);
  }

  /// AC/C 표시 판별
  bool get isAcState {
    if (state.isResult) return true;
    final input = state.input;
    return input == '0' || input == '-0' || input == '-';
  }

  // ── 핸들러 ──

  void _onKeyTap(String key) {
    var input = state.input;
    var isResult = state.isResult;

    switch (key) {
      case 'AC' || 'C':
        state = _recalculate(state.copyWith(input: '0', isResult: false));
        return;

      case '⌫':
        if (isResult) {
          state = _recalculate(state.copyWith(input: '0', isResult: false));
          return;
        }
        if (input.length > 1) {
          final trimmed = input.substring(0, input.length - 1);
          input = (trimmed == '-') ? '0' : trimmed;
        } else {
          input = '0';
        }

      case '+/-':
        isResult = false;
        if (input == '0') {
          input = '-0';
        } else if (input.startsWith('-')) {
          input = input.substring(1);
        } else {
          input = '-$input';
        }

      case '.':
        if (isResult) {
          input = '0.';
          isResult = false;
          break;
        }
        if (input.contains('.')) return;
        input += '.';

      default: // 숫자 0-9
        if (isResult) {
          input = key == '0' ? '0' : key;
          isResult = false;
          break;
        }
        // 자릿수 제한 체크
        final clean = input.startsWith('-') ? input.substring(1) : input;
        if (clean.contains('.')) {
          final fracLen = clean.split('.')[1].length;
          if (fracLen >= 8) {
            state = state.copyWith(toastMessage: '소수점 이하 8자리까지 입력 가능해요');
            return;
          }
        } else {
          final intPart = clean.replaceFirst(RegExp(r'^0+'), '');
          if (intPart.length >= 12) {
            state = state.copyWith(toastMessage: '정수부는 최대 12자리까지 입력 가능해요');
            return;
          }
        }

        if (input == '0') {
          input = key == '0' ? '0' : key;
        } else if (input == '-0') {
          input = key == '0' ? '-0' : '-$key';
        } else {
          input += key;
        }
    }

    state = _recalculate(state.copyWith(input: input, isResult: isResult));
  }

  void _onCategorySelected(int index) {
    if (index == state.selectedCategoryIndex) return;
    final category = unitCategories[index];
    state = _recalculate(state.copyWith(
      selectedCategoryIndex: index,
      activeUnitCode: category.defaultCode,
      input: '0',
    ));
  }

  void _onUnitTapped(String code) {
    if (code == state.activeUnitCode) return;

    // 현재 변환 결과를 새 활성 단위의 입력값으로 설정
    final currentConverted = state.convertedValues[code];
    String newInput;
    if (currentConverted != null && currentConverted != '0') {
      // 포맷팅된 값에서 콤마 제거
      newInput = currentConverted.replaceAll(',', '');
      // 지수 표기법이면 double로 파싱 후 다시 문자열로
      if (newInput.contains('e')) {
        final parsed = double.tryParse(newInput);
        if (parsed != null) {
          newInput = _rawFromDouble(parsed);
        }
      }
    } else {
      newInput = '0';
    }

    state = _recalculate(state.copyWith(
      activeUnitCode: code,
      input: newInput,
      isResult: true,
    ));
  }

  void _onArrow(int direction) {
    final category = unitCategories[state.selectedCategoryIndex];
    final units = category.units;
    final currentIndex =
        units.indexWhere((u) => u.code == state.activeUnitCode);
    if (currentIndex < 0) return;

    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= units.length) return;

    _onUnitTapped(units[newIndex].code);
  }

  // ── 변환 계산 ──

  UnitConverterState _recalculate(UnitConverterState s) {
    final category = unitCategories[s.selectedCategoryIndex];
    final inputValue = _parseInput(s.input);

    final rawResults = _convertUseCase.execute(
      categoryName: category.name,
      fromCode: s.activeUnitCode,
      value: inputValue,
      units: category.units,
    );

    final isTemperature = category.name == '온도';
    final formatted = <String, String>{};
    for (final entry in rawResults.entries) {
      formatted[entry.key] =
          isTemperature ? _formatTemperature(entry.value) : _formatResult(entry.value);
    }

    return s.copyWith(convertedValues: formatted);
  }

  double _parseInput(String input) {
    if (input.isEmpty || input == '-' || input == '-0') return 0;
    // 끝이 .으로 끝나면 제거
    final clean = input.endsWith('.') ? input.substring(0, input.length - 1) : input;
    return double.tryParse(clean) ?? 0;
  }

  // ── 포맷팅 ──

  /// 온도 전용 포맷: 소수점 최대 3자리 + 천 단위 콤마
  String _formatTemperature(double value) {
    if (value == 0) return '0';
    return _addCommas(_trimTrailingZeros(value.toStringAsFixed(3)));
  }

  /// 결과 표시 규칙 (스펙 기준)
  String _formatResult(double value) {
    if (value == 0) return '0';

    final absVal = value.abs();

    // 지수 표기법: 아주 작은 값
    if (absVal < 0.0001) {
      return _formatScientific(value);
    }

    // 0.0001 이상 1 미만: 소수점 최대 8자리
    if (absVal < 1) {
      return _addCommas(_trimTrailingZeros(value.toStringAsFixed(8)));
    }

    // 매우 큰 값: 지수 표기법
    if (absVal >= 1e15) {
      return _formatScientific(value);
    }

    // 1,000,000 이상: 정수만 + 콤마
    if (absVal >= 1000000) {
      return _addCommas(value.toStringAsFixed(0));
    }

    // 1 이상 1,000,000 미만: 유효숫자 기준 소수점 최대 6자리
    return _addCommas(_trimTrailingZeros(value.toStringAsFixed(6)));
  }

  String _formatScientific(double value) {
    final exp = (log(value.abs()) / ln10).floor();
    final mantissa = value / pow(10, exp);
    final mantissaStr = _trimTrailingZeros(mantissa.toStringAsFixed(2));
    final sign = exp >= 0 ? '+' : '';
    return '${mantissaStr}e$sign$exp';
  }

  String _formatInput(String raw) {
    if (raw.isEmpty) return '0';
    final isNegative = raw.startsWith('-');
    final body = isNegative ? raw.substring(1) : raw;

    if (body.contains('.')) {
      final parts = body.split('.');
      final intFormatted = _addCommas(parts[0]);
      return '${isNegative ? '-' : ''}$intFormatted.${parts[1]}';
    }

    return '${isNegative ? '-' : ''}${_addCommas(body)}';
  }

  String _trimTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    var result = s;
    while (result.endsWith('0')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  String _addCommas(String str) {
    final isNegative = str.startsWith('-');
    final body = isNegative ? str.substring(1) : str;

    // 소수점이 있으면 정수부만 콤마 처리
    final parts = body.split('.');
    final digits = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final intPart = isNegative ? '-${buf.toString()}' : buf.toString();
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  /// double을 raw 입력 문자열로 변환 (콤마 없이, 불필요한 소수 제거)
  String _rawFromDouble(double value) {
    if (value == 0) return '0';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(10);
    return _trimTrailingZeros(str);
  }
}
