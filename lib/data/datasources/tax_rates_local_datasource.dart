import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/cache_config.dart';
import '../../domain/models/tax_rates.dart';

/// SharedPreferences 기반 세율 캐시.
class TaxRatesLocalDataSource {
  final SharedPreferences _prefs;

  TaxRatesLocalDataSource(this._prefs);

  TaxRates? getCachedRates() {
    final jsonStr = _prefs.getString(CacheConfig.taxRatesCacheKey);
    if (jsonStr == null) return null;
    try {
      return TaxRates.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[TaxRatesLocal] cache parse failed: $e');
      return null;
    }
  }

  bool isCacheValid() {
    final ts = _prefs.getInt(CacheConfig.taxRatesCacheTimestampKey);
    if (ts == null) return false;
    return DateTime.now().millisecondsSinceEpoch - ts < CacheConfig.taxRatesTtlMs;
  }

  Future<void> cacheRates(TaxRates rates) async {
    await _prefs.setString(
        CacheConfig.taxRatesCacheKey, jsonEncode(rates.toJson()));
    await _prefs.setInt(CacheConfig.taxRatesCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch);
  }
}
