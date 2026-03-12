/// 자릿수 제한 초과 결과
enum DigitCheckResult {
  /// 정수 자릿수 초과
  integerExceeded,

  /// 소수 자릿수 초과
  fractionalExceeded,

  /// 소수점 입력 불가
  decimalNotAllowed,
}

/// 숫자 입력 자릿수 제한 정책
class DigitLimitPolicy {
  final int maxIntegerDigits;
  final int? maxFractionalDigits; // null이면 소수점 불가

  const DigitLimitPolicy({
    required this.maxIntegerDigits,
    this.maxFractionalDigits,
  });

  /// 미리 정의된 표준 정책 (환율·부가세·단위변환·기본계산기)
  static const standard = DigitLimitPolicy(
    maxIntegerDigits: 12,
    maxFractionalDigits: 8,
  );

  /// 정수만 (더치페이 금액)
  static const integerOnly9 = DigitLimitPolicy(
    maxIntegerDigits: 9,
  );

  /// 정수만 (할인 가격)
  static const integerOnly10 = DigitLimitPolicy(
    maxIntegerDigits: 10,
  );

  /// [segment]에 [adding]을 추가했을 때 제한 초과 여부를 검사.
  /// 초과 시 [DigitCheckResult]를 반환하고, 통과 시 null 반환.
  DigitCheckResult? check(String segment, String adding) {
    final combined = segment + adding;
    final noSign = combined.startsWith('-') ? combined.substring(1) : combined;

    if (noSign.contains('.')) {
      final parts = noSign.split('.');
      if (parts[0].replaceFirst(RegExp(r'^0+'), '').length > maxIntegerDigits) {
        return DigitCheckResult.integerExceeded;
      }
      if (maxFractionalDigits == null) return DigitCheckResult.decimalNotAllowed;
      if (parts[1].length > maxFractionalDigits!) {
        return DigitCheckResult.fractionalExceeded;
      }
    } else {
      final intPart = noSign.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.length > maxIntegerDigits) {
        return DigitCheckResult.integerExceeded;
      }
    }
    return null; // 통과
  }

  /// '00' 키 입력 시 추가할 문자열을 결정.
  /// 제한 초과 시 null 반환, 초과 결과는 [onExceed]에 전달.
  String? adjustDoubleZero(String segment, {void Function(DigitCheckResult)? onExceed}) {
    final noSign = segment.startsWith('-') ? segment.substring(1) : segment;

    if (noSign.contains('.')) {
      final fracLen = noSign.split('.')[1].length;
      final maxFrac = maxFractionalDigits;
      if (maxFrac == null) return null;
      if (fracLen >= maxFrac) {
        onExceed?.call(DigitCheckResult.fractionalExceeded);
        return null;
      }
      return (fracLen >= maxFrac - 1) ? '0' : '00';
    } else {
      final intLen = noSign.replaceFirst(RegExp(r'^0+'), '').length;
      if (intLen >= maxIntegerDigits) {
        onExceed?.call(DigitCheckResult.integerExceeded);
        return null;
      }
      return (intLen >= maxIntegerDigits - 1) ? '0' : '00';
    }
  }
}
