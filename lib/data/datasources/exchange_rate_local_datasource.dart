import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/cache_config.dart';
import '../../domain/models/exchange_rate_entity.dart';

class ExchangeRateLocalDataSource {

  final SharedPreferences _prefs;

  ExchangeRateLocalDataSource(this._prefs);

  /// 캐시된 환율 반환. 없으면 null.
  ExchangeRateEntity? getCachedRates() {
    final jsonStr = _prefs.getString(CacheConfig.exchangeRateCacheKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ExchangeRateEntity.fromJson(json);
    } catch (e) {
      debugPrint('[ExchangeRateLocal] cache parse failed: $e');
      return null;
    }
  }

  /// 캐시가 유효한지 확인 (1시간 이내).
  bool isCacheValid() {
    final cached = getCachedRates();
    if (cached == null) return false;
    return DateTime.now().difference(cached.fetchedAt).inMilliseconds < CacheConfig.exchangeRateTtlMs;
  }

  /// 환율 데이터를 로컬에 저장.
  Future<void> cacheRates(ExchangeRateEntity entity) async {
    final jsonStr = jsonEncode(entity.toJson());
    await _prefs.setString(CacheConfig.exchangeRateCacheKey, jsonStr);
  }
}
