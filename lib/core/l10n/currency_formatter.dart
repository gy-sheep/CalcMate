import 'dart:ui';

/// 로케일 인식 통화 포맷 헬퍼.
///
/// 현재 앱에서 KRW(원) 표시에만 사용.
/// - ko: 접미사 스타일 `"12,500 원"`
/// - en: 접두사 스타일 `"₩12,500"`
abstract final class CurrencyFormatter {
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
}
