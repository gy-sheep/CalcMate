import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/domain/usecases/evaluate_expression_usecase.dart';
import 'package:calcmate/domain/utils/calculator_input_utils.dart';
import 'package:calcmate/domain/utils/number_formatter.dart';
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
  const factory CalculatorIntent.parenthesesPressed() = _ParenthesesPressed;
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

class _ParenthesesPressed extends CalculatorIntent {
  const _ParenthesesPressed();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final basicCalculatorViewModelProvider =
    NotifierProvider.autoDispose<BasicCalculatorViewModel, CalculatorState>(
  BasicCalculatorViewModel.new,
);

// ── ViewModel ─────────────────────────────────────────────────────────────────

class BasicCalculatorViewModel extends AutoDisposeNotifier<CalculatorState> {
  final _useCase = EvaluateExpressionUseCase();

  static const _nonMinusOps = {'+', '×', '÷'};
  static const _allOps = {'+', '-', '×', '÷'};

  // 반복 = 를 위한 마지막 연산자/피연산자
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
      case _ParenthesesPressed():
        _onParentheses();
    }
  }

  // ── 숫자 입력 ────────────────────────────────────────────────────────────────

  void _onNumber(String digit) {
    if (state.isResult) {
      _repeatOperator = '';
      _repeatOperand = '';
      state = CalculatorState(input: digit == '0' ? '0' : digit);
      return;
    }

    final current = state.input;

    // ) 뒤 숫자 → 암묵적 × 삽입
    if (current.endsWith(')')) {
      state = state.copyWith(input: '$current×$digit');
      return;
    }

    if (current == '0') {
      state = state.copyWith(input: digit);
    } else if (current == '-0' || current.endsWith('-0') && _isNegZeroEnd(current)) {
      // 음수 대기 -0: 0이면 유지, 다른 숫자면 교체
      if (digit == '0') return;
      state = state.copyWith(
        input: current.substring(0, current.length - 1) + digit,
      );
    } else {
      state = state.copyWith(input: current + digit);
    }
  }

  /// -0으로 끝나는 음수 대기 상태인지 확인
  bool _isNegZeroEnd(String s) {
    if (s == '-0') return true;
    if (s.length >= 3) {
      final before = s[s.length - 3];
      return s.endsWith('-0') &&
          (_nonMinusOps.contains(before) || before == '(');
    }
    return false;
  }

  // ── 연산자 입력 ──────────────────────────────────────────────────────────────

  void _onOperator(String op) {
    if (state.isResult) {
      _repeatOperator = '';
      _repeatOperand = '';
      state = CalculatorState(input: state.input + op, isResult: false);
      return;
    }

    final current = state.input;

    // 초기 상태(0): -만 허용
    if (current == '0') {
      if (op == '-') {
        state = state.copyWith(input: '-');
      }
      return;
    }

    // ( 바로 뒤: -만 허용
    if (current.endsWith('(')) {
      if (op == '-') {
        state = state.copyWith(input: '$current-');
      }
      return;
    }

    // 음수 대기 상태 (연산자 뒤 '-' 또는 '(-' 또는 연산자 뒤 '-0')
    if (CalculatorInputUtils.isNegativePending(current)) {
      // 같은 연산자면 무시
      if (current.endsWith('-') && op == '-') return;

      // 음수 대기에서 다른 연산자 → 음수 취소 + 연산자 교체
      // 5×- → 5+, (- → (는 불가하므로 (-에서 다른 연산자 무시
      if (current.length >= 2 && current[current.length - 2] == '(') {
        return; // (- 에서 다른 연산자는 무시
      }
      // 5×-0 → 연산자 교체 시 -0 제거
      if (current.endsWith('-0')) {
        final base = current.substring(0, current.length - 3); // 5 (×-0 → ×, -, 0 제거)
        state = state.copyWith(input: base + op);
        return;
      }
      // 5×- → 5+ (- 제거하고 앞 연산자도 교체)
      final base = current.substring(0, current.length - 2); // 5
      state = state.copyWith(input: base + op);
      return;
    }

    // 연산자로 끝나는 경우 → 같은 연산자면 무시, 다른 연산자면 교체
    if (CalculatorInputUtils.endsWithOperator(current)) {
      if (op == '-') {
        // 음수 대기 상태로 진입
        state = state.copyWith(input: '$current-');
        return;
      }
      final lastOp = current[current.length - 1];
      if (lastOp == op) return; // 같은 연산자 무시
      state = state.copyWith(input: current.substring(0, current.length - 1) + op);
      return;
    }

    // 일반적 경우: 연산자 추가
    state = state.copyWith(input: current + op, isResult: false);
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
        input: NumberFormatter.formatResult(result),
        expression: state.input + _repeatOperator + _repeatOperand,
        isResult: true,
      );
      return;
    }

    final raw = state.input;

    // 숫자만 있으면 무시 (연산자가 없는 경우)
    if (!CalculatorInputUtils.hasOperator(raw)) return;

    // 연산자로 끝나면 무시
    if (CalculatorInputUtils.endsWithOperator(raw)) return;

    // 음수 대기 상태면 무시
    if (CalculatorInputUtils.isNegativePending(raw)) return;

    // '(' 만 있는 경우 무시
    if (raw == '(') return;

    // 미닫힌 괄호 자동 닫기
    var expr = raw;
    final unclosed = CalculatorInputUtils.unclosedParenCount(expr);
    for (int i = 0; i < unclosed; i++) {
      expr += ')';
    }

    final resolved = CalculatorInputUtils.resolvePercent(expr);

    // 반복 = 용: resolved 기준으로 마지막 연산자/피연산자 저장
    final lastSeg = CalculatorInputUtils.lastNumberSegment(resolved);
    final prefix = resolved.substring(0, resolved.length - lastSeg.length);
    if (prefix.isNotEmpty) {
      _repeatOperator = prefix[prefix.length - 1];
      _repeatOperand = lastSeg;
    } else {
      _repeatOperator = '';
      _repeatOperand = '';
    }

    final result = _useCase.execute(
      resolved.replaceAll('÷', '/').replaceAll('×', '*'),
    );
    state = CalculatorState(
      input: NumberFormatter.formatResult(result),
      expression: expr,
      isResult: true,
    );
  }

  // ── 클리어 ───────────────────────────────────────────────────────────────────

  void _onClear() {
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

    // ) 뒤 → ×0.
    if (current.endsWith(')')) {
      state = state.copyWith(input: '$current×0.');
      return;
    }

    // % 뒤 → ×0.
    if (current.endsWith('%')) {
      state = state.copyWith(input: '$current×0.');
      return;
    }

    // ( 뒤 → 0.
    if (current.endsWith('(')) {
      state = state.copyWith(input: '${current}0.');
      return;
    }

    // 음수 대기 (-, 5×-)
    if (CalculatorInputUtils.isNegativePending(current)) {
      // -0 상태에서 소수점
      if (current.endsWith('-0')) {
        state = state.copyWith(input: '$current.');
        return;
      }
      state = state.copyWith(input: '${current}0.');
      return;
    }

    // 연산자 뒤 → 0.
    if (CalculatorInputUtils.endsWithOperator(current)) {
      state = state.copyWith(input: '${current}0.');
      return;
    }

    // 현재 숫자 세그먼트에 소수점이 없을 때만 추가
    final lastSegment = CalculatorInputUtils.lastNumberSegment(current);
    if (!lastSegment.contains('.')) {
      state = state.copyWith(input: '$current.');
    }
  }

  // ── % ─────────────────────────────────────────────────────────────────────────

  void _onPercent() {
    final current = state.input;

    // 음수 대기 상태 → 무시
    if (CalculatorInputUtils.isNegativePending(current)) return;

    // 결과 상태 → 결과에 % 붙이기, 수식 초기화
    if (state.isResult) {
      state = CalculatorState(input: '${state.input}%', isResult: false);
      return;
    }

    // ( 뒤 → 0%
    if (current.endsWith('(')) {
      state = state.copyWith(input: '${current}0%', isResult: false);
      return;
    }

    // 연산자 뒤 → 연산자를 %로 교체
    if (CalculatorInputUtils.endsWithOperator(current)) {
      state = state.copyWith(
        input: current.substring(0, current.length - 1) + '%',
        isResult: false,
      );
      return;
    }

    // 이미 %로 끝나면 → 마지막 피연산자+% 만 괄호로 감싸기
    if (current.endsWith('%')) {
      final beforePercent = current.substring(0, current.length - 1);
      int segStart;
      if (beforePercent.endsWith(')')) {
        // 괄호 그룹 찾기: 매칭되는 ( 위치까지
        int depth = 0;
        int i = beforePercent.length - 1;
        while (i >= 0) {
          if (beforePercent[i] == ')') depth++;
          if (beforePercent[i] == '(') depth--;
          if (depth == 0) break;
          i--;
        }
        segStart = i;
      } else {
        // 숫자 세그먼트 시작 위치 찾기
        int i = beforePercent.length - 1;
        while (i >= 0 && _isDigitOrDot(beforePercent[i])) {
          i--;
        }
        segStart = i + 1;
      }
      final prefix = current.substring(0, segStart);
      final segment = current.substring(segStart); // e.g. "9%"
      state = state.copyWith(input: '$prefix($segment)%', isResult: false);
      return;
    }

    // 일반: % 추가
    state = state.copyWith(input: '$current%', isResult: false);
  }

  // ── 괄호 ───────────────────────────────────────────────────────────────────────

  void _onParentheses() {
    final current = state.input;

    // 결과 상태 → ( 로 새 수식 시작
    if (state.isResult) {
      _repeatOperator = '';
      _repeatOperand = '';
      state = const CalculatorState(input: '(');
      return;
    }

    final unclosed = CalculatorInputUtils.unclosedParenCount(current);
    final lastCh = current.isNotEmpty ? current[current.length - 1] : '';

    // ) 삽입 조건: 미닫힌 괄호 있고, 끝이 숫자 또는 ) 또는 %
    if (unclosed > 0 && (_isDigit(lastCh) || lastCh == ')' || lastCh == '%')) {
      state = state.copyWith(input: '$current)');
      return;
    }

    // ( 삽입 조건들
    // 초기 상태(0) → ( 대체
    if (current == '0') {
      state = state.copyWith(input: '(');
      return;
    }

    // 연산자 뒤 → ( 추가
    if (CalculatorInputUtils.endsWithOperator(current)) {
      state = state.copyWith(input: '$current(');
      return;
    }

    // ( 뒤 → ( 추가 (중첩)
    if (lastCh == '(') {
      state = state.copyWith(input: '$current(');
      return;
    }

    // 숫자 뒤 → ×( 삽입 (암묵적 곱셈)
    if (_isDigit(lastCh)) {
      state = state.copyWith(input: '$current×(');
      return;
    }

    // ) 뒤 → ×( 삽입
    if (lastCh == ')') {
      state = state.copyWith(input: '$current×(');
      return;
    }

    // % 뒤 → ×( 삽입
    if (lastCh == '%') {
      state = state.copyWith(input: '$current×(');
      return;
    }
  }

  bool _isDigit(String ch) =>
      ch.isNotEmpty && ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

  bool _isDigitOrDot(String ch) => _isDigit(ch) || ch == '.';
}
