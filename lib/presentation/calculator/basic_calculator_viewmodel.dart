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

  // 반복 = 를 위한 마지막 연산자/피연산자 (resolved 값)
  String _repeatOperator = '';
  String _repeatOperand = '';

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
        _onClear();
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
      // 결과 후 숫자 입력 → 반복 = 초기화 후 새 수식 시작
      _repeatOperator = '';
      _repeatOperand = '';
      state = CalculatorState(input: digit == '0' ? '0' : digit);
      return;
    }
    if (state.input == '0') {
      state = state.copyWith(input: digit);
    } else if (state.input == '-0') {
      // 음수 대기 상태: 0이면 유지, 다른 숫자면 음수로 완성
      state = state.copyWith(input: digit == '0' ? '-0' : '-$digit');
    } else {
      state = state.copyWith(input: state.input + digit);
    }
  }

  // ── 연산자 입력 ──────────────────────────────────────────────────────────────

  void _onOperator(String op) {
    // 표시용 연산자 (÷ → / , × → * 변환은 UseCase 진입 전에 처리)
    final displayOp = op;
    if (state.isResult) {
      // 결과에 이어 연산자 입력 → 반복 = 초기화
      _repeatOperator = '';
      _repeatOperand = '';
      state = CalculatorState(input: state.input + displayOp, isResult: false);
      return;
    }
    final current = state.input;
    // 초기 상태(0)에서 - 누름: 음수 입력 모드 (0 제거 후 - 만 표시)
    if (current == '0' && op == '-') {
      state = state.copyWith(input: '-', isResult: false);
      return;
    }
    if (_endsWithOperator(current)) {
      // 마지막이 연산자면 교체
      state = state.copyWith(input: current.substring(0, current.length - 1) + op);
    } else {
      state = state.copyWith(input: current + op, isResult: false);
    }
  }

  // ── = 입력 ───────────────────────────────────────────────────────────────────

  void _onEquals() {
    // 반복 = : 결과 상태에서 = 를 누르면 마지막 연산 반복
    if (state.isResult && _repeatOperator.isNotEmpty) {
      final expr = state.input +
          _repeatOperator.replaceAll('÷', '/').replaceAll('×', '*') +
          _repeatOperand;
      final result = _useCase.execute(expr);
      state = CalculatorState(
        input: _formatResult(result),
        expression: state.input + _repeatOperator + _repeatOperand,
        isResult: true,
      );
      return;
    }

    final raw = state.input;
    if (_endsWithOperator(raw)) return;

    final resolved = _resolvePercent(raw);

    // 반복 = 용: resolved 기준으로 마지막 연산자/피연산자 저장
    final lastSeg = _lastNumberSegment(resolved);
    final prefix = resolved.substring(0, resolved.length - lastSeg.length);
    if (prefix.isNotEmpty) {
      _repeatOperator = prefix[prefix.length - 1];
      _repeatOperand = lastSeg;
    } else {
      _repeatOperator = '';
      _repeatOperand = '';
    }

    final result = _useCase.execute(resolved.replaceAll('÷', '/').replaceAll('×', '*'));
    state = CalculatorState(
      input: _formatResult(result),
      expression: raw,
      isResult: true,
    );
  }

  // ── 클리어 ───────────────────────────────────────────────────────────────────

  void _onClear() {
    if (state.isResult) {
      state = const CalculatorState();
      _repeatOperator = '';
      _repeatOperand = '';
      return;
    }
    final current = state.input;

    // 음수 대기 상태(-0): 전체 초기화
    if (current == '-0') {
      state = const CalculatorState();
      _repeatOperator = '';
      _repeatOperand = '';
      return;
    }

    final lastSeg = _lastNumberSegment(current);
    final prefix = current.substring(0, current.length - lastSeg.length);

    // 단독 음수(-X): 숫자만 지우고 - 유지 (AC 상태로 복귀)
    if (prefix.isEmpty && lastSeg.startsWith('-') && lastSeg.length > 1) {
      state = state.copyWith(input: '-', isResult: false);
      return;
    }

    // 연산자 뒤 숫자(0+X): 숫자만 지우고 연산자까지 유지 (AC 상태로 복귀)
    if (prefix.isNotEmpty && lastSeg.isNotEmpty) {
      state = state.copyWith(input: prefix, isResult: false);
      return;
    }

    // 기타: 전체 초기화
    state = const CalculatorState();
    _repeatOperator = '';
    _repeatOperand = '';
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
    if (current.endsWith('%')) return;   // 이미 % 있음
    if (_endsWithOperator(current)) return; // 연산자 바로 뒤는 불가
    state = state.copyWith(input: current + '%', isResult: false);
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

  // % 기호를 실제 값으로 변환
  // + / - 뒤: 앞 숫자 기준 퍼센트 (200+50% → 200+100)
  // × / ÷ 또는 단독: ÷ 100 (200×50% → 200×0.5, 50% → 0.5)
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
