import '../models/tax_rates.dart';

abstract class TaxRatesRepository {
  Future<TaxRates> getLatestRates();
}
