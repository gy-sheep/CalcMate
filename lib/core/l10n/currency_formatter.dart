import 'dart:ui';

import '../../domain/models/currency_unit.dart';

/// 로케일 인식 통화 포맷 헬퍼.
///
/// KRW 전용 메서드(`krwUnit`, `formatKrw`)는 실수령액 계산기에서 계속 사용.
/// [CurrencyUnit] 기반 메서드(`symbol`, `unitLabel`, `format`)는
/// 부가세·할인·더치페이에서 사용.
abstract final class CurrencyFormatter {
  // ── KRW 전용 (실수령액) ──

  /// 통화 단위 문자열 (별도 Text 위젯용).
  /// ko → `'원'`, en → `'KRW'`
  static String krwUnit(Locale locale) =>
      locale.languageCode == 'ko' ? '원' : 'KRW';

  /// 숫자와 통화 단위를 결합한 인라인 포맷.
  /// ko → `'12,500 원'`, en → `'₩12,500'`
  static String formatKrw(String formattedNumber, Locale locale) =>
      locale.languageCode == 'ko'
          ? '$formattedNumber 원'
          : '₩$formattedNumber';

  // ── CurrencyUnit 기반 ──

  /// 통화 기호.
  /// CNY는 en에서 `'CN¥'`로 구분.
  static String symbol(CurrencyUnit unit, Locale locale) {
    final isKo = locale.languageCode == 'ko';
    return switch (unit) {
      CurrencyUnit.krw => '₩',
      CurrencyUnit.usd => '\$',
      CurrencyUnit.eur => '€',
      CurrencyUnit.jpy => '¥',
      CurrencyUnit.cny => isKo ? '¥' : 'CN¥',
      CurrencyUnit.gbp => '£',
    };
  }

  /// 통화 단위 텍스트 (별도 Text 위젯용).
  /// ko KRW → `'원'`, en KRW → `'KRW'`, ko USD → `'USD'`, etc.
  static String unitLabel(CurrencyUnit unit, Locale locale) {
    if (unit == CurrencyUnit.krw && locale.languageCode == 'ko') return '원';
    return unit.code;
  }

  /// 숫자와 통화를 결합한 인라인 포맷.
  ///
  /// | 통화 | ko           | en           |
  /// |------|-------------|-------------|
  /// | KRW  | `12,500 원`  | `₩12,500`   |
  /// | USD  | `$12,500`   | `$12,500`   |
  /// | EUR  | `€12,500`   | `€12,500`   |
  /// | JPY  | `¥12,500`   | `¥12,500`   |
  /// | CNY  | `¥12,500`   | `CN¥12,500` |
  /// | GBP  | `£12,500`   | `£12,500`   |
  static String format(
      String formattedNumber, CurrencyUnit unit, Locale locale) {
    if (unit == CurrencyUnit.krw && locale.languageCode == 'ko') {
      return '$formattedNumber 원';
    }
    return '${symbol(unit, locale)}$formattedNumber';
  }
}
