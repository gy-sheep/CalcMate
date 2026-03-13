/// 계산기 수식 입력에 공통으로 사용되는 유틸리티 함수.
abstract final class CalculatorInputUtils {
  static const _operators = {'+', '-', '×', '÷', '*', '/'};
  static const _nonMinusOps = {'+', '×', '÷', '*', '/'};

  /// 문자열이 연산자로 끝나는지 확인.
  static bool endsWithOperator(String s) {
    if (s.isEmpty) return false;
    return _operators.contains(s[s.length - 1]);
  }

  /// 마지막 숫자 세그먼트를 반환.
  /// '-'는 부호로도 쓰이므로 연산자 뒤 '-'는 숫자 세그먼트에 포함.
  static String lastNumberSegment(String s) {
    int i = s.length - 1;
    while (i >= 0) {
      final ch = s[i];
      if (_nonMinusOps.contains(ch)) break;
      if (ch == '-' && i > 0 && !_nonMinusOps.contains(s[i - 1])) break;
      i--;
    }
    return s.substring(i + 1);
  }

  /// 최상위 레벨에서 마지막 피연산자를 반환.
  /// 괄호 그룹은 하나의 덩어리로 취급.
  /// e.g. "2×(3+4)" → "(3+4)", "5+3" → "3"
  static String lastTopLevelSegment(String s) {
    int i = s.length - 1;
    while (i >= 0) {
      final ch = s[i];
      if (ch == ')') {
        int depth = 1;
        i--;
        while (i >= 0 && depth > 0) {
          if (s[i] == ')') depth++;
          if (s[i] == '(') depth--;
          i--;
        }
        continue;
      }
      if (_nonMinusOps.contains(ch)) break;
      if (ch == '-' && i > 0 && !_nonMinusOps.contains(s[i - 1])) break;
      i--;
    }
    return s.substring(i + 1);
  }

  /// 닫히지 않은 '(' 개수를 반환.
  static int unclosedParenCount(String s) {
    int count = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') count++;
      if (s[i] == ')') count--;
    }
    return count < 0 ? 0 : count;
  }

  /// 음수 대기 상태인지 판별.
  /// '-' 단독, 연산자 뒤 '-', '(' 뒤 '-', '-0', '연산자-0' 등.
  static bool isNegativePending(String s) {
    if (s.isEmpty) return false;
    // '-' 단독
    if (s == '-') return true;
    // '-0' 단독
    if (s == '-0') return true;
    // 끝이 '-'이고 그 앞이 연산자이거나 '('
    if (s.endsWith('-') && s.length >= 2) {
      final before = s[s.length - 2];
      if (_nonMinusOps.contains(before) || before == '(') return true;
    }
    // 끝이 '-0'이고 그 앞이 연산자이거나 '('
    if (s.endsWith('-0') && s.length >= 3) {
      final before = s[s.length - 3];
      if (_nonMinusOps.contains(before) || before == '(') return true;
    }
    return false;
  }

  /// 수식에 연산자(+, -, ×, ÷, %, 괄호)가 존재하는지 확인.
  /// 맨 앞 음수 부호 '-'는 제외.
  static bool hasOperator(String s) {
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == '(' || ch == ')' || ch == '%') return true;
      if (_nonMinusOps.contains(ch)) return true;
      if (ch == '-' && i > 0) {
        // 앞 글자가 숫자, ')', '%'이면 뺄셈 연산자
        final prev = s[i - 1];
        if (_isDigit(prev) || prev == ')' || prev == '%') return true;
      }
    }
    return false;
  }

  static bool _isDigit(String ch) =>
      ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

  /// % 기호를 실제 값으로 변환 (괄호 depth 추적 좌→우 파서).
  ///
  /// - `%` 뒤에 숫자가 바로 오면 mod → 그대로 통과 (evaluator가 처리)
  /// - `%` 뒤에 연산자/`=`/끝 → 퍼센트 변환:
  ///   - `+` / `-` 뒤: 앞 숫자(base) 기준 퍼센트
  ///   - `×` / `÷` 또는 단독: ÷100
  ///   - `)%`: 그룹 전체 × 0.01
  static String resolvePercent(String raw) {
    if (!raw.contains('%')) return raw;

    final buf = StringBuffer();
    int i = 0;

    while (i < raw.length) {
      if (raw[i] == '%') {
        // % 뒤에 숫자가 바로 오면 mod → 그대로 통과
        if (i + 1 < raw.length && _isDigit(raw[i + 1])) {
          buf.write('%');
          i++;
          continue;
        }

        // 퍼센트 변환: buf의 현재 내용에서 문맥 분석
        final prefix = buf.toString();
        final result = _resolvePercentValue(prefix);
        buf.clear();
        buf.write(result);
        i++;
      } else {
        buf.write(raw[i]);
        i++;
      }
    }

    return buf.toString();
  }

  /// prefix 끝의 숫자/그룹에 퍼센트를 적용한 문자열을 반환.
  static String _resolvePercentValue(String prefix) {
    if (prefix.isEmpty) return prefix;

    // ')' 로 끝나는 경우 → 매칭 '(' 앞 문맥에 따라 처리
    if (prefix.endsWith(')')) {
      // 매칭되는 '(' 찾기
      int depth = 0;
      int i = prefix.length - 1;
      while (i >= 0) {
        if (prefix[i] == ')') depth++;
        if (prefix[i] == '(') depth--;
        if (depth == 0) break;
        i--;
      }
      final beforeParen = prefix.substring(0, i);
      final group = prefix.substring(i); // "(…)"

      // '+' / '-' 뒤의 그룹이면 base 기준 퍼센트
      if (beforeParen.isNotEmpty) {
        final contextOp = beforeParen[beforeParen.length - 1];
        if (contextOp == '+' || contextOp == '-') {
          final beforeOp = beforeParen.substring(0, beforeParen.length - 1);
          final base = _extractBase(beforeOp);
          final baseStr = base == base.truncateToDouble()
              ? base.toInt().toString()
              : base.toString();
          return '$beforeOp$contextOp$baseStr*$group*0.01';
        }
      }

      // 그 외 (단독, × / ÷ 뒤): ÷100
      return '$prefix*0.01';
    }

    // 마지막 숫자 세그먼트와 그 앞의 연산자 찾기
    final numMatch = RegExp(r'(\d+(?:\.\d*)?)$').firstMatch(prefix);
    if (numMatch == null) return prefix;

    final numStr = numMatch.group(1)!;
    final numVal = double.tryParse(numStr) ?? 0;
    final beforeNum = prefix.substring(0, prefix.length - numStr.length);

    if (beforeNum.isEmpty) {
      // 단독: B% → B/100
      return '${numVal / 100}';
    }

    final lastOp = beforeNum[beforeNum.length - 1];
    final beforeOp = beforeNum.substring(0, beforeNum.length - 1);

    if (lastOp == '+' || lastOp == '-') {
      // A +/- B% → A +/- (A * B / 100)
      // A(base)를 찾기: beforeOp에서 마지막 숫자/그룹
      final base = _extractBase(beforeOp);
      final resolved = base * numVal / 100;
      return '$beforeOp$lastOp$resolved';
    }

    // × / ÷ 또는 기타: B% → B/100
    return '$beforeOp$lastOp${numVal / 100}';
  }

  /// 문자열 끝에서 base 숫자를 추출. 괄호 그룹이면 간단한 평가는 하지 않고
  /// 가장 바깥 숫자만 추출.
  static double _extractBase(String s) {
    if (s.isEmpty) return 0;

    // 마지막 숫자를 추출
    final match = RegExp(r'(\d+(?:\.\d*)?)$').firstMatch(s);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0;
    }

    return 0;
  }
}
