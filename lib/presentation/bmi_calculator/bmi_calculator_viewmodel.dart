import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/bmi_calculator_state.dart';
import '../../domain/usecases/bmi_calculate_usecase.dart';

// ── Intent ─────────────────────────────────────────────────────────────────

sealed class BmiCalculatorIntent {
  const BmiCalculatorIntent();
  const factory BmiCalculatorIntent.heightChanged(double cm) = _HeightChanged;
  const factory BmiCalculatorIntent.weightChanged(double kg) = _WeightChanged;
  const factory BmiCalculatorIntent.heightEdited(String input) = _HeightEdited;
  const factory BmiCalculatorIntent.weightEdited(String input) = _WeightEdited;
  const factory BmiCalculatorIntent.unitToggled() = _UnitToggled;
  const factory BmiCalculatorIntent.initialized() = _Initialized;
}

class _HeightChanged extends BmiCalculatorIntent {
  final double cm;
  const _HeightChanged(this.cm);
}

class _WeightChanged extends BmiCalculatorIntent {
  final double kg;
  const _WeightChanged(this.kg);
}

class _HeightEdited extends BmiCalculatorIntent {
  final String input;
  const _HeightEdited(this.input);
}

class _WeightEdited extends BmiCalculatorIntent {
  final String input;
  const _WeightEdited(this.input);
}

class _UnitToggled extends BmiCalculatorIntent {
  const _UnitToggled();
}

class _Initialized extends BmiCalculatorIntent {
  const _Initialized();
}

// ── SharedPreferences key ──────────────────────────────────────────────────

const _kUnitPrefKey = 'bmi_unit_system';

// ── Provider ───────────────────────────────────────────────────────────────

final bmiCalculatorViewModelProvider =
    NotifierProvider.autoDispose<BmiCalculatorViewModel, BmiCalculatorState>(
  BmiCalculatorViewModel.new,
);

// ── ViewModel ──────────────────────────────────────────────────────────────

class BmiCalculatorViewModel
    extends AutoDisposeNotifier<BmiCalculatorState> {
  final _useCase = BmiCalculateUseCase();
  bool _initialized = false;

  @override
  BmiCalculatorState build() => const BmiCalculatorState();

  BmiResult get result => _useCase.calculate(
        heightCm: state.heightCm,
        weightKg: state.weightKg,
        standard: state.standard,
      );

  void handleIntent(BmiCalculatorIntent intent) {
    switch (intent) {
      case _HeightChanged(:final cm):
        state = state.copyWith(heightCm: cm);
      case _WeightChanged(:final kg):
        state = state.copyWith(weightKg: kg);
      case _HeightEdited(:final input):
        _handleHeightEdit(input);
      case _WeightEdited(:final input):
        _handleWeightEdit(input);
      case _UnitToggled():
        _toggleUnit();
      case _Initialized():
        _initialize();
    }
  }

  // ── 초기화 ──────────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 기기의 시스템 지역 설정에서 국가 코드를 가져옴 (앱 내 언어 설정과 무관)
    final countryCode = PlatformDispatcher.instance.locale.countryCode;
    final standard = BmiCalculateUseCase.standardForCountryCode(countryCode);

    // SharedPreferences에서 저장된 단위 읽기
    final prefs = await SharedPreferences.getInstance();
    final savedUnit = prefs.getString(_kUnitPrefKey);
    final isMetric = savedUnit != null
        ? savedUnit == 'metric'
        : BmiCalculateUseCase.defaultIsMetric(countryCode);

    state = state.copyWith(
      standard: standard,
      isMetric: isMetric,
    );
  }

  // ── 직접 입력 처리 ──────────────────────────────────────────────────────

  void _handleHeightEdit(String input) {
    final v = double.tryParse(input);
    if (v == null) return;
    final cm = state.isMetric ? v : v * 30.48;
    state = state.copyWith(heightCm: cm.clamp(100, 220).toDouble());
  }

  void _handleWeightEdit(String input) {
    final v = double.tryParse(input);
    if (v == null) return;
    final kg = state.isMetric ? v : v / 2.20462;
    state = state.copyWith(weightKg: kg.clamp(20, 150).toDouble());
  }

  // ── 단위 토글 ──────────────────────────────────────────────────────────

  Future<void> _toggleUnit() async {
    final newMetric = !state.isMetric;
    state = state.copyWith(isMetric: newMetric);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUnitPrefKey, newMetric ? 'metric' : 'imperial');
  }
}
