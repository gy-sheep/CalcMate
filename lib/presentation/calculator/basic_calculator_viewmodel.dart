import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/domain/usecases/evaluate_expression_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Intent ────────────────────────────────────────────────────────────────────

sealed class CalculatorIntent {
  const CalculatorIntent();
  const factory CalculatorIntent.numberPressed(String digit) = _NumberPressed;
  const factory CalculatorIntent.operatorPressed(String op) = _OperatorPressed;
  const factory CalculatorIntent.equalsPressed() = _EqualsPressed;
  const factory CalculatorIntent.clearPressed() = _ClearPressed;
  const factory CalculatorIntent.backspacePressed() = _BackspacePressed;
  const factory CalculatorIntent.decimalPressed() = _DecimalPressed;
  const factory CalculatorIntent.percentPressed() = _PercentPressed;
  const factory CalculatorIntent.negatePressed() = _NegatePressed;
}

class _NumberPressed extends CalculatorIntent {
  final String digit;
  const _NumberPressed(this.digit);
}

class _OperatorPressed extends CalculatorIntent {
  final String op;
  const _OperatorPressed(this.op);
}

class _EqualsPressed extends CalculatorIntent {
  const _EqualsPressed();
}

class _ClearPressed extends CalculatorIntent {
  const _ClearPressed();
}

class _BackspacePressed extends CalculatorIntent {
  const _BackspacePressed();
}

class _DecimalPressed extends CalculatorIntent {
  const _DecimalPressed();
}

class _PercentPressed extends CalculatorIntent {
  const _PercentPressed();
}

class _NegatePressed extends CalculatorIntent {
  const _NegatePressed();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final basicCalculatorViewModelProvider =
    NotifierProvider<BasicCalculatorViewModel, CalculatorState>(
  BasicCalculatorViewModel.new,
);

// ── ViewModel ─────────────────────────────────────────────────────────────────

class BasicCalculatorViewModel extends Notifier<CalculatorState> {
  final _useCase = EvaluateExpressionUseCase();

  @override
  CalculatorState build() => const CalculatorState();

  void handleIntent(CalculatorIntent intent) {
    switch (intent) {
      case _NumberPressed(:final digit):
        _onNumber(digit);
      case _OperatorPressed(:final op):
        _onOperator(op);
      case _EqualsPressed():
        _onEquals();
      case _ClearPressed():
        state = const CalculatorState();
      case _BackspacePressed():
        _onBackspace();
      case _DecimalPressed():
        _onDecimal();
      case _PercentPressed():
        _onPercent();
      case _NegatePressed():
        _onNegate();
    }
  }

  // ── 숫자 입력 ────────────────────────────────────────────────────────────────

  void _onNumber(String digit) {
    if (state.isResult) {
      // 계산 완료 후 숫자 입력 → 새 수식 시작
      state = CalculatorState(input: digit == '0' ? '0' : digit);
      return;
    }
    if (state.input == '0') {
      state = state.copyWith(input: digit);
    } else {
      state = state.copyWith(input: state.input + digit);
    }
  }

  // ── 연산자 입력 ──────────────────────────────────────────────────────────────

  void _onOperator(String op) {
    // 표시용 연산자 (÷ → / , × → * 변환은 UseCase 진입 전에 처리)
    final displayOp = op;
    if (state.isResult) {
      // 결과값에 이어 연산자 입력
      state = CalculatorState(
        input: state.input + displayOp,
        isResult: false,
      );
      return;
    }
    final current = state.input;
    if (_endsWithOperator(current)) {
      // 마지막이 연산자면 교체
      state = state.copyWith(input: current.substring(0, current.length - 1) + displayOp);
    } else {
      state = state.copyWith(input: current + displayOp, isResult: false);
    }
  }

  // ── = 입력 ───────────────────────────────────────────────────────────────────

  void _onEquals() {
    final raw = state.input;
    if (_endsWithOperator(raw)) return;

    final expr = raw.replaceAll('÷', '/').replaceAll('×', '*');
    final result = _useCase.execute(expr);

    final resultStr = _formatResult(result);
    state = CalculatorState(
      input: resultStr,
      expression: '$raw=',
      isResult: true,
    );
  }

  // ── 백스페이스 ───────────────────────────────────────────────────────────────

  void _onBackspace() {
    if (state.isResult) {
      state = const CalculatorState();
      return;
    }
    final current = state.input;
    if (current.length <= 1) {
      state = state.copyWith(input: '0');
    } else {
      state = state.copyWith(input: current.substring(0, current.length - 1));
    }
  }

  // ── 소수점 ───────────────────────────────────────────────────────────────────

  void _onDecimal() {
    if (state.isResult) {
      state = const CalculatorState(input: '0.');
      return;
    }
    final current = state.input;
    // 마지막 숫자 세그먼트에 소수점이 없을 때만 추가
    final lastSegment = _lastNumberSegment(current);
    if (!lastSegment.contains('.')) {
      if (_endsWithOperator(current) || current.isEmpty) {
        state = state.copyWith(input: '${current}0.');
      } else {
        state = state.copyWith(input: '$current.');
      }
    }
  }

  // ── % ─────────────────────────────────────────────────────────────────────────

  void _onPercent() {
    final current = state.input;
    final lastSegment = _lastNumberSegment(current);
    if (lastSegment.isEmpty) return;

    final val = double.tryParse(lastSegment);
    if (val == null) return;

    final percentStr = _formatResult(val / 100);
    final prefix = current.substring(0, current.length - lastSegment.length);
    state = state.copyWith(input: prefix + percentStr, isResult: false);
  }

  // ── +/- ───────────────────────────────────────────────────────────────────────

  void _onNegate() {
    final current = state.input;
    final lastSegment = _lastNumberSegment(current);
    if (lastSegment.isEmpty) return;

    final prefix = current.substring(0, current.length - lastSegment.length);
    if (lastSegment.startsWith('-')) {
      state = state.copyWith(input: prefix + lastSegment.substring(1));
    } else {
      state = state.copyWith(input: '$prefix-$lastSegment');
    }
  }

  // ── 헬퍼 ─────────────────────────────────────────────────────────────────────

  bool _endsWithOperator(String s) {
    if (s.isEmpty) return false;
    final last = s[s.length - 1];
    return last == '+' || last == '-' || last == '×' || last == '÷' || last == '*' || last == '/';
  }

  String _lastNumberSegment(String s) {
    final ops = {'+', '×', '÷', '*', '/'};
    // '-' 는 부호로도 쓰이므로 연산자 뒤 '-' 는 숫자 세그먼트에 포함
    int i = s.length - 1;
    while (i >= 0) {
      final ch = s[i];
      if (ops.contains(ch)) break;
      if (ch == '-' && i > 0 && !ops.contains(s[i - 1])) break;
      i--;
    }
    return s.substring(i + 1);
  }

  String _formatResult(double value) {
    if (value == double.infinity || value == double.negativeInfinity) return '오류';
    if (value.isNaN) return '오류';
    // 정수면 소수점 제거
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    // 소수점 이하 최대 10자리, 불필요한 0 제거
    final str = value.toStringAsFixed(10);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
