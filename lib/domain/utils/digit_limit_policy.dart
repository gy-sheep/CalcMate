/// 숫자 입력 자릿수 제한 정책
class DigitLimitPolicy {
  final int maxIntegerDigits;
  final int? maxFractionalDigits; // null이면 소수점 불가
  final String? toastOnInteger;
  final String? toastOnFractional;

  const DigitLimitPolicy({
    required this.maxIntegerDigits,
    this.maxFractionalDigits,
    this.toastOnInteger,
    this.toastOnFractional,
  });

  /// 미리 정의된 표준 정책 (환율·부가세·단위변환·기본계산기)
  static const standard = DigitLimitPolicy(
    maxIntegerDigits: 12,
    maxFractionalDigits: 8,
    toastOnInteger: '최대 12자리까지 입력 가능합니다',
    toastOnFractional: '소수점 이하 8자리까지 입력 가능합니다',
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
  /// 초과 시 표시할 토스트 메시지를 반환하고, 통과 시 null 반환.
  String? check(String segment, String adding) {
    final combined = segment + adding;
    final noSign = combined.startsWith('-') ? combined.substring(1) : combined;

    if (noSign.contains('.')) {
      final parts = noSign.split('.');
      if (parts[0].replaceFirst(RegExp(r'^0+'), '').length > maxIntegerDigits) {
        return toastOnInteger;
      }
      if (maxFractionalDigits == null) return ''; // 소수점 불가
      if (parts[1].length > maxFractionalDigits!) {
        return toastOnFractional;
      }
    } else {
      final intPart = noSign.replaceFirst(RegExp(r'^0+'), '');
      if (intPart.length > maxIntegerDigits) {
        return toastOnInteger;
      }
    }
    return null; // 통과
  }

  /// '00' 키 입력 시 추가할 문자열을 결정.
  /// 제한 초과 시 null 반환, 토스트 메시지는 [toastOut]에 저장.
  String? adjustDoubleZero(String segment, {void Function(String?)? onExceed}) {
    final noSign = segment.startsWith('-') ? segment.substring(1) : segment;

    if (noSign.contains('.')) {
      final fracLen = noSign.split('.')[1].length;
      final maxFrac = maxFractionalDigits;
      if (maxFrac == null) return null;
      if (fracLen >= maxFrac) {
        onExceed?.call(toastOnFractional);
        return null;
      }
      return (fracLen >= maxFrac - 1) ? '0' : '00';
    } else {
      final intLen = noSign.replaceFirst(RegExp(r'^0+'), '').length;
      if (intLen >= maxIntegerDigits) {
        onExceed?.call(toastOnInteger);
        return null;
      }
      return (intLen >= maxIntegerDigits - 1) ? '0' : '00';
    }
  }
}
