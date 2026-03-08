import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/discount_calculator_state.dart';
import '../../domain/usecases/calculate_discount_usecase.dart';

// ── Intent ─────────────────────────────────────────────────────────────────

sealed class DiscountCalculatorIntent {
  const DiscountCalculatorIntent();
  const factory DiscountCalculatorIntent.keyPressed(String key) = _KeyPressed;
  const factory DiscountCalculatorIntent.chipSelected(int index, {bool isExtra}) = _ChipSelected;
  const factory DiscountCalculatorIntent.fieldTapped(ActiveField field) = _FieldTapped;
  const factory DiscountCalculatorIntent.toggleExtraDiscount() = _ToggleExtraDiscount;
}

class _KeyPressed extends DiscountCalculatorIntent {
  final String key;
  const _KeyPressed(this.key);
}

class _ChipSelected extends DiscountCalculatorIntent {
  final int index;
  final bool isExtra;
  const _ChipSelected(this.index, {this.isExtra = false});
}

class _FieldTapped extends DiscountCalculatorIntent {
  final ActiveField field;
  const _FieldTapped(this.field);
}

class _ToggleExtraDiscount extends DiscountCalculatorIntent {
  const _ToggleExtraDiscount();
}

// ── Chip 목록 ───────────────────────────────────────────────────────────────

const kDiscountChips = ['5%', '10%', '20%', '30%', '50%'];

// ── Provider ────────────────────────────────────────────────────────────────

final discountCalculatorViewModelProvider =
    NotifierProvider.autoDispose<DiscountCalculatorViewModel, DiscountCalculatorState>(
      DiscountCalculatorViewModel.new,
    );

// ── ViewModel ───────────────────────────────────────────────────────────────

class DiscountCalculatorViewModel
    extends AutoDisposeNotifier<DiscountCalculatorState> {
  final _useCase = CalculateDiscountUseCase();

  @override
  DiscountCalculatorState build() => const DiscountCalculatorState();

  DiscountResult get result => _useCase.calculate(
        originalPrice: state.originalPrice,
        discountRate: state.discountRate,
        extraRate: state.extraRate,
        showExtra: state.showExtra,
      );

  void handleIntent(DiscountCalculatorIntent intent) {
    switch (intent) {
      case _KeyPressed(:final key):
        _handleKey(key);
      case _ChipSelected(:final index, :final isExtra):
        _handleChip(index, isExtra: isExtra);
      case _FieldTapped(:final field):
        state = state.copyWith(activeField: field);
      case _ToggleExtraDiscount():
        _toggleExtra();
    }
  }

  // ── 키 처리 ──────────────────────────────────────────────────────────────

  void _handleKey(String key) {
    switch (state.activeField) {
      case ActiveField.originalPrice:
        final raw = state.originalPrice.replaceAll(',', '');
        final next = _applyKey(raw, key, isPrice: true);
        final formatted = _formatInputPrice(next);
        state = state.copyWith(originalPrice: formatted);
      case ActiveField.discountRate:
        final next = _applyKey(state.discountRate, key, isPrice: false);
        final chipIndex = kDiscountChips.indexWhere((c) => c == '$next%');
        state = state.copyWith(
          discountRate: next,
          selectedChip: chipIndex == -1 ? null : chipIndex,
        );
      case ActiveField.extraDiscountRate:
        final next = _applyKey(state.extraRate, key, isPrice: false);
        final chipIndex = kDiscountChips.indexWhere((c) => c == '$next%');
        state = state.copyWith(
          extraRate: next,
          selectedExtraChip: chipIndex == -1 ? null : chipIndex,
        );
    }
  }

  String _applyKey(String current, String key, {required bool isPrice}) {
    switch (key) {
      case '⌫':
        return current.isEmpty ? '' : current.substring(0, current.length - 1);
      case 'AC':
        return '';
      case '.':
        if (isPrice) return current;
        if (current.contains('.')) return current;
        return '${current.isEmpty ? '0' : current}.';
      case '00':
        if (current.isEmpty || current == '0') return current;
        return '${current}00';
      default:
        if (isPrice) {
          final next = current + key;
          final val = int.tryParse(next);
          if (val == null || val > 9999999999) return current;
          return next;
        } else {
          final next = current + key;
          final val = double.tryParse(next);
          if (val == null || val >= 100) return current;
          return next;
        }
    }
  }

  String _formatInputPrice(String raw) {
    final digits = raw.replaceAll(',', '');
    if (digits.isEmpty) return '';
    final value = int.tryParse(digits);
    if (value == null) return raw;
    return CalculateDiscountUseCase.formatPrice(value.toDouble());
  }

  // ── 칩 선택 ──────────────────────────────────────────────────────────────

  void _handleChip(int index, {required bool isExtra}) {
    final value = kDiscountChips[index].replaceAll('%', '');
    if (isExtra) {
      state = state.copyWith(
        selectedExtraChip: index,
        extraRate: value,
        activeField: ActiveField.extraDiscountRate,
      );
    } else {
      state = state.copyWith(
        selectedChip: index,
        discountRate: value,
        activeField: ActiveField.discountRate,
      );
    }
  }

  // ── 추가 할인 토글 ────────────────────────────────────────────────────────

  void _toggleExtra() {
    if (state.showExtra) {
      state = state.copyWith(
        showExtra: false,
        extraRate: '',
        selectedExtraChip: null,
        activeField: ActiveField.discountRate,
      );
    } else {
      state = state.copyWith(
        showExtra: true,
        activeField: ActiveField.extraDiscountRate,
      );
    }
  }
}
