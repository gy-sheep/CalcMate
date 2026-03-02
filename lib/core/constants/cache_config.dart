/// 로컬 캐시 관련 상수.
abstract final class CacheConfig {
  /// SharedPreferences 키 — 환율 캐시.
  static const exchangeRateCacheKey = 'exchange_rate_cache';

  /// 캐시 유효 기간 (밀리초). 기본 1시간.
  static const exchangeRateTtlMs = 3600000;
}
