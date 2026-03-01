import '../../domain/models/exchange_rate_entity.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/exchange_rate_local_datasource.dart';
import '../datasources/exchange_rate_remote_datasource.dart';
import '../dto/exchange_rate_dto.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource _remote;
  final ExchangeRateLocalDataSource _local;

  ExchangeRateRepositoryImpl({
    required ExchangeRateRemoteDataSource remote,
    required ExchangeRateLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<ExchangeRateEntity> getLatestRates() async {
    // 1단계: 로컬 캐시 (유효하면 즉시 반환)
    if (_local.isCacheValid()) {
      return _local.getCachedRates()!;
    }

    try {
      // 2단계: Firestore 읽기 (Cloud Scheduler가 1시간마다 최신 상태 유지)
      final firestoreDto = await _remote.fetchFromFirestore();
      if (firestoreDto != null) {
        final entity = firestoreDto.toEntity();
        await _local.cacheRates(entity);
        return entity;
      }
      throw Exception('No exchange rate data available in Firestore');
    } catch (_) {
      // 실패 시: 만료된 로컬 캐시라도 반환
      final expired = _local.getCachedRates();
      if (expired != null) return expired;
      rethrow;
    }
  }
}
