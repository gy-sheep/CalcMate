import 'dart:math';

/// 숫자 포맷팅에 공통으로 사용되는 유틸리티 함수.
///
/// 천 단위 콤마, 후행 0 제거, 지수 표기법 등 기본 빌딩블록과
/// 계산기별 결과 표시 포맷터를 제공한다.
abstract final class NumberFormatter {
  // ── 빌딩 블록 ──

  /// 천 단위 콤마 추가. 소수점이 있으면 정수부만 처리.
  static String addCommas(String str) {
    final isNegative = str.startsWith('-');
    final body = isNegative ? str.substring(1) : str;

    final parts = body.split('.');
    final digits = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final intPart = isNegative ? '-${buf.toString()}' : buf.toString();
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }

  /// 후행 0 제거. 소수점만 남으면 소수점도 제거.
  static String trimTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    var result = s;
    while (result.endsWith('0')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// 지수 표기법 변환. 가수부 소수점 최대 2자리.
  static String formatScientific(double value) {
    final exp = (log(value.abs()) / ln10).floor();
    final mantissa = value / pow(10, exp);
    final mantissaStr = trimTrailingZeros(mantissa.toStringAsFixed(2));
    final sign = exp >= 0 ? '+' : '';
    return '${mantissaStr}e$sign$exp';
  }

  /// double을 raw 입력 문자열로 변환 (콤마 없이, 후행 0 제거).
  static String rawFromDouble(double value) {
    if (value == 0) return '0';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(10);
    return trimTrailingZeros(str);
  }

  // ── 결과 포맷터 ──

  /// 기본 계산기 결과 표시 (정수화, 후행 0 제거, Infinity/NaN 처리).
  static String formatResult(double value) {
    if (value == double.infinity || value == double.negativeInfinity) {
      return '정의되지 않음';
    }
    if (value.isNaN) return '정의되지 않음';
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final str = value.toStringAsFixed(9);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// 환율 금액 표시 (크기에 따라 소수점 자릿수 변경).
  ///
  /// - ≥1000: 정수 + 콤마
  /// - ≥1: 소수 2자리
  /// - <1: 소수 4자리
  static String formatAmount(double value) {
    if (value == 0) return '0';
    if (value >= 1000) {
      return addCommas(value.toStringAsFixed(0));
    }
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }

  /// 단위 변환 결과 표시 (지수 표기 포함).
  ///
  /// - <0.0001: 지수 표기
  /// - <1: 소수점 최대 8자리
  /// - ≥1e15: 지수 표기
  /// - ≥1,000,000: 정수 + 콤마
  /// - 그 외: 소수점 최대 6자리 + 콤마
  static String formatUnitResult(double value) {
    if (value == 0) return '0';

    final absVal = value.abs();

    if (absVal < 0.0001) return formatScientific(value);

    if (absVal < 1) {
      return addCommas(trimTrailingZeros(value.toStringAsFixed(8)));
    }

    if (absVal >= 1e15) return formatScientific(value);

    if (absVal >= 1000000) {
      return addCommas(value.toStringAsFixed(0));
    }

    return addCommas(trimTrailingZeros(value.toStringAsFixed(6)));
  }

  /// 온도 결과 표시 (소수점 최대 3자리 + 콤마).
  static String formatTemperature(double value) {
    if (value == 0) return '0';
    return addCommas(trimTrailingZeros(value.toStringAsFixed(3)));
  }

  /// 부가세 결과 표시 (1000 이상 콤마+정수, 정수화, 소수 2자리).
  static String formatVatResult(double value) {
    if (value == 0) return '0';
    if (value.isNaN || value.isInfinite) return '0';
    final absVal = value.abs();
    if (absVal >= 1000) return addCommas(value.toStringAsFixed(0));
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return trimTrailingZeros(value.toStringAsFixed(2));
  }

  /// 단일 숫자 입력값에 콤마 추가 (음수, 소수점 보존).
  static String formatInput(String raw) {
    if (raw.isEmpty) return '0';
    final isNegative = raw.startsWith('-');
    final body = isNegative ? raw.substring(1) : raw;

    if (body.contains('.')) {
      final parts = body.split('.');
      final intFormatted = addCommas(parts[0]);
      return '${isNegative ? '-' : ''}$intFormatted.${parts[1]}';
    }

    return '${isNegative ? '-' : ''}${addCommas(body)}';
  }
}
