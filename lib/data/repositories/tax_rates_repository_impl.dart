import 'package:flutter/foundation.dart';

import '../../domain/models/tax_rates.dart';
import '../../domain/repositories/tax_rates_repository.dart';
import '../datasources/tax_rates_fallback.dart';
import '../datasources/tax_rates_local_datasource.dart';
import '../datasources/tax_rates_remote_datasource.dart';

class TaxRatesRepositoryImpl implements TaxRatesRepository {
  final TaxRatesRemoteDataSource _remote;
  final TaxRatesLocalDataSource _local;

  TaxRatesRepositoryImpl({
    required TaxRatesRemoteDataSource remote,
    required TaxRatesLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<TaxRates> getLatestRates() async {
    // 1. 캐시 유효 → 즉시 반환
    if (_local.isCacheValid()) {
      return _local.getCachedRates()!;
    }

    try {
      // 2. Firestore 읽기
      final rates = await _remote.fetchFromFirestore();
      if (rates != null) {
        await _local.cacheRates(rates);
        return rates;
      }
    } catch (e) {
      debugPrint('[TaxRatesRepo] Firestore fetch failed: $e');
    }

    // 3. 만료 캐시라도 반환
    final expired = _local.getCachedRates();
    if (expired != null) return expired;

    // 4. 모든 소스 실패 → 폴백 상수
    return kFallbackTaxRates;
  }
}
