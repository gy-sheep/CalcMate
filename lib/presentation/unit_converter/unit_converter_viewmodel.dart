import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/unit_definitions.dart';
import '../../domain/models/unit_converter_state.dart';
import '../../domain/usecases/convert_unit_usecase.dart';
import '../../domain/utils/digit_limit_policy.dart';
import '../../domain/utils/number_formatter.dart';

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

  /// 활성 단위의 입력값을 포맷팅하여 반환.
  ///
  /// - 단위 전환(isResult=true): convertedValues를 그대로 사용 → 비활성 표시와 100% 일치
  /// - 사용자 직접 입력(isResult=false): 천 단위 콤마만 추가
  String get formattedInput {
    if (state.isResult) {
      return state.convertedValues[state.activeUnitCode] ?? '0';
    }
    return NumberFormatter.formatInput(state.input);
  }

  // ── 핸들러 ──

  void _onKeyTap(String key) {
    var input = state.input;
    var isResult = state.isResult;

    switch (key) {
      case 'AC':
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

      case '00':
        if (isResult) {
          input = '0';
          isResult = false;
          break;
        }
        if (input == '0' || input == '-0') break;
        // 자릿수 제한 체크
        final add00 = DigitLimitPolicy.standard.adjustDoubleZero(input,
            onExceed: (result) {
          state = state.copyWith(toastMessage: _digitCheckToast(result));
        });
        if (add00 == null) return;
        input += add00;

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
        final digitCheck = DigitLimitPolicy.standard.check(input, key);
        if (digitCheck != null) {
          final msg = _digitCheckToast(digitCheck);
          if (msg.isNotEmpty) state = state.copyWith(toastMessage: msg);
          return;
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

    // raw double 값을 표시용 정밀도로 변환
    final rawValue = state.rawConvertedValues[code] ?? 0.0;
    final newInput = NumberFormatter.rawFromDouble(rawValue);

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
      categoryCode: category.code,
      fromCode: s.activeUnitCode,
      value: inputValue,
      units: category.units,
    );

    final isTemperature = category.code == 'temperature';
    final formatted = <String, String>{};
    for (final entry in rawResults.entries) {
      formatted[entry.key] = isTemperature
          ? NumberFormatter.formatTemperature(entry.value)
          : NumberFormatter.formatUnitResult(entry.value);
    }

    return s.copyWith(
      convertedValues: formatted,
      rawConvertedValues: rawResults,
    );
  }

  double _parseInput(String input) {
    if (input.isEmpty || input == '-' || input == '-0') return 0;
    // 끝이 .으로 끝나면 제거
    final clean = input.endsWith('.') ? input.substring(0, input.length - 1) : input;
    return double.tryParse(clean) ?? 0;
  }
}

// TODO: Phase 5에서 l10n으로 전환
String _digitCheckToast(DigitCheckResult result) => switch (result) {
      DigitCheckResult.integerExceeded => '최대 12자리까지 입력 가능합니다',
      DigitCheckResult.fractionalExceeded => '소수점 이하 8자리까지 입력 가능합니다',
      DigitCheckResult.decimalNotAllowed => '',
    };
