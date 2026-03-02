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

  /// 계산 결과를 표시용 문자열로 변환.
  static String formatResult(double value) {
    if (value == double.infinity || value == double.negativeInfinity) {
      return '정의되지 않음';
    }
    if (value.isNaN) return '정의되지 않음';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(10);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// 정수 문자열에 천 단위 콤마 추가.
  static String addCommas(String intStr) {
    final isNegative = intStr.startsWith('-');
    final digits = isNegative ? intStr.substring(1) : intStr;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return isNegative ? '-${buf.toString()}' : buf.toString();
  }
}
