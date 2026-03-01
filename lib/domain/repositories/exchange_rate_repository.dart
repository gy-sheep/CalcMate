import '../models/exchange_rate_entity.dart';

abstract class ExchangeRateRepository {
  Future<ExchangeRateEntity> getLatestRates();
}
