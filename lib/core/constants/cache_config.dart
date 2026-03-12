/// 로컬 캐시 관련 상수.
abstract final class CacheConfig {
  /// SharedPreferences 키 — 환율 캐시.
  static const exchangeRateCacheKey = 'exchange_rate_cache';

  /// 캐시 유효 기간 (밀리초). 기본 1시간.
  static const exchangeRateTtlMs = 3600000;

  /// SharedPreferences 키 — 세율 캐시.
  static const taxRatesCacheKey = 'tax_rates_cache';

  /// SharedPreferences 키 — 세율 캐시 타임스탬프.
  static const taxRatesCacheTimestampKey = 'tax_rates_cache_ts';

  /// 세율 캐시 유효 기간 (밀리초). 7일.
  static const taxRatesTtlMs = 604800000;
}
