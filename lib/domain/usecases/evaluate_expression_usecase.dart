/// 수식 문자열을 파싱하여 계산 결과를 반환한다.
/// 외부 패키지 없이 순수 Dart로 구현 — 연산자 우선순위(* / 먼저) 반영.
class EvaluateExpressionUseCase {
  double execute(String expression) {
    try {
      final tokens = _tokenize(expression);
      return _evaluate(tokens);
    } catch (_) {
      return double.nan;
    }
  }

  // ── 토크나이저 ─────────────────────────────────────────────────────────────
  // 수식 문자열을 숫자/연산자 토큰 목록으로 분리한다.
  // 맨 앞 '-'는 음수 부호로 처리한다.
  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];

      if (ch == '-' && (i == 0 || _isOperator(expr[i - 1]))) {
        // 음수 부호: 버퍼에 포함
        buffer.write(ch);
      } else if (_isOperator(ch)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(ch);
      } else {
        buffer.write(ch);
      }
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }

  bool _isOperator(String ch) => ch == '+' || ch == '-' || ch == '*' || ch == '/';

  // ── 평가기 ────────────────────────────────────────────────────────────────
  // 1단계: * / 처리 → 2단계: + - 처리
  double _evaluate(List<String> tokens) {
    // 1단계: * / 우선 처리
    final pass1 = <String>[];
    int i = 0;
    while (i < tokens.length) {
      final t = tokens[i];
      if ((t == '*' || t == '/') && pass1.isNotEmpty) {
        final left = double.parse(pass1.removeLast());
        final right = double.parse(tokens[++i]);
        if (t == '*') {
          pass1.add((left * right).toString());
        } else {
          pass1.add(right == 0 ? double.infinity.toString() : (left / right).toString());
        }
      } else {
        pass1.add(t);
      }
      i++;
    }

    // 2단계: + - 처리
    double result = double.parse(pass1[0]);
    int j = 1;
    while (j < pass1.length) {
      final op = pass1[j];
      final right = double.parse(pass1[j + 1]);
      if (op == '+') {
        result += right;
      } else if (op == '-') {
        result -= right;
      }
      j += 2;
    }

    return result;
  }
}
