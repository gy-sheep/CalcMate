import '../models/tax_rates.dart';
import '../repositories/tax_rates_repository.dart';

class GetTaxRatesUseCase {
  final TaxRatesRepository _repository;

  GetTaxRatesUseCase(this._repository);

  Future<TaxRates> execute() => _repository.getLatestRates();
}
