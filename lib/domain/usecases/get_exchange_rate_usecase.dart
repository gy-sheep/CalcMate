import '../models/exchange_rate_entity.dart';
import '../repositories/exchange_rate_repository.dart';

class GetExchangeRateUseCase {
  final ExchangeRateRepository _repository;

  GetExchangeRateUseCase(this._repository);

  Future<ExchangeRateEntity> execute() => _repository.getLatestRates();
}
