/// 표시 통화 단위.
///
/// 부가세, 할인, 더치페이 계산기에서 사용.
/// 환율 계산기는 별도 체계를 유지.
enum CurrencyUnit {
  krw,
  usd,
  eur,
  jpy,
  cny,
  gbp;

  /// 대문자 통화 코드 (e.g. `'KRW'`, `'USD'`).
  String get code => name.toUpperCase();

  /// 문자열로부터 [CurrencyUnit] 파싱. 실패 시 `null`.
  static CurrencyUnit? tryFromCode(String? code) {
    if (code == null) return null;
    final lower = code.toLowerCase();
    for (final unit in values) {
      if (unit.name == lower) return unit;
    }
    return null;
  }
}
