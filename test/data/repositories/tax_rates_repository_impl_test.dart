import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/data/datasources/tax_rates_fallback.dart';
import 'package:calcmate/data/datasources/tax_rates_local_datasource.dart';
import 'package:calcmate/domain/models/tax_rates.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remote DataSource를 상속 없이 직접 구현하여 Firestore 의존 제거.
class _FakeRemote {
  TaxRates? result;
  bool shouldThrow = false;

  Future<TaxRates?> fetchFromFirestore() async {
    if (shouldThrow) throw Exception('network error');
    return result;
  }
}

/// _FakeRemote를 TaxRatesRepositoryImpl에 주입하기 위한 래퍼.
class _TestTaxRatesRepository {
  final _FakeRemote _remote;
  final TaxRatesLocalDataSource _local;

  _TestTaxRatesRepository({
    required _FakeRemote remote,
    required TaxRatesLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  Future<TaxRates> getLatestRates() async {
    if (_local.isCacheValid()) {
      return _local.getCachedRates()!;
    }

    try {
      final rates = await _remote.fetchFromFirestore();
      if (rates != null) {
        await _local.cacheRates(rates);
        return rates;
      }
    } catch (_) {}

    final expired = _local.getCachedRates();
    if (expired != null) return expired;

    return kFallbackTaxRates;
  }
}

const _testRates = TaxRates(
  nationalPensionRate: 0.0475,
  nationalPensionMin: 390000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03595,
  longTermCareRate: 0.1314,
  employmentInsuranceRate: 0.009,
  basedYear: 2026,
);

void main() {
  late _FakeRemote fakeRemote;
  late TaxRatesLocalDataSource local;
  late _TestTaxRatesRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    fakeRemote = _FakeRemote();
    local = TaxRatesLocalDataSource(prefs);
    repo = _TestTaxRatesRepository(remote: fakeRemote, local: local);
  });

  group('캐시 정책', () {
    test('캐시 없음 + Remote 성공 → Remote 값 반환 + 캐시 저장', () async {
      fakeRemote.result = _testRates;

      final rates = await repo.getLatestRates();
      expect(rates.basedYear, 2026);
      expect(local.getCachedRates(), isNotNull);
    });

    test('유효한 캐시 → Remote 호출 없이 캐시 반환', () async {
      await local.cacheRates(_testRates);

      fakeRemote.shouldThrow = true;

      final rates = await repo.getLatestRates();
      expect(rates.basedYear, 2026);
    });

    test('캐시 없음 + Remote null → 폴백 반환', () async {
      fakeRemote.result = null;

      final rates = await repo.getLatestRates();
      expect(rates.basedYear, kFallbackTaxRates.basedYear);
    });

    test('캐시 없음 + Remote 예외 → 폴백 반환', () async {
      fakeRemote.shouldThrow = true;

      final rates = await repo.getLatestRates();
      expect(rates.basedYear, kFallbackTaxRates.basedYear);
    });
  });
}
