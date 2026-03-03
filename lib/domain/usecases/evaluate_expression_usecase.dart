/// 수식 문자열을 파싱하여 계산 결과를 반환한다.
/// 재귀 하강 파서로 구현 — 괄호, 연산자 우선순위, mod(%) 지원.
///
/// 문법:
///   expression = term (('+' | '-') term)*
///   term       = atom (('*' | '/' | '%') atom)*
///   atom       = ['-'] number | ['-'] '(' expression ')'
class EvaluateExpressionUseCase {
  double execute(String expression) {
    try {
      final parser = _Parser(expression);
      final result = parser.parseExpression();
      return result;
    } catch (_) {
      return double.nan;
    }
  }
}

class _Parser {
  final String _source;
  int _pos = 0;

  _Parser(this._source);

  /// 현재 위치 문자. 끝이면 빈 문자열 반환.
  String get _current => _pos < _source.length ? _source[_pos] : '';

  /// 현재 위치를 한 칸 전진하고 이전 문자를 반환.
  String _advance() {
    final ch = _current;
    _pos++;
    return ch;
  }

  /// expression = term (('+' | '-') term)*
  double parseExpression() {
    var result = _parseTerm();
    while (_current == '+' || _current == '-') {
      final op = _advance();
      final right = _parseTerm();
      if (op == '+') {
        result += right;
      } else {
        result -= right;
      }
    }
    return result;
  }

  /// term = atom (('*' | '/' | '%') atom)*
  double _parseTerm() {
    var result = _parseAtom();
    while (_current == '*' || _current == '/' || _current == '%') {
      final op = _advance();
      final right = _parseAtom();
      if (op == '*') {
        result *= right;
      } else if (op == '/') {
        result = right == 0 ? double.infinity : result / right;
      } else {
        // mod
        result = right == 0 ? double.nan : result % right;
      }
    }
    return result;
  }

  /// atom = ['-'] number | ['-'] '(' expression ')'
  double _parseAtom() {
    // 단항 마이너스
    var negative = false;
    if (_current == '-') {
      negative = true;
      _advance();
    }

    double value;

    if (_current == '(') {
      _advance(); // '(' 소비
      value = parseExpression();
      if (_current == ')') _advance(); // ')' 소비
    } else {
      value = _parseNumber();
    }

    return negative ? -value : value;
  }

  /// 숫자 파싱 (정수, 소수). '5.' 같은 trailing dot도 허용.
  double _parseNumber() {
    final start = _pos;
    while (_pos < _source.length &&
        (_source[_pos].codeUnitAt(0) >= 48 && _source[_pos].codeUnitAt(0) <= 57 ||
            _source[_pos] == '.')) {
      _pos++;
    }
    if (_pos == start) throw FormatException('숫자가 필요합니다');
    return double.parse(_source.substring(start, _pos));
  }
}
