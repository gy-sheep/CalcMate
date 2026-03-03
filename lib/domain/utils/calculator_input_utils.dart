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

  /// % 기호를 실제 값으로 변환.
  /// +/- 뒤: 앞 숫자 기준 퍼센트 (200+50% → 200+100).
  /// ×/÷ 또는 단독: ÷100 (200×50% → 200×0.5, 50% → 0.5).
  static String resolvePercent(String raw) {
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

}
