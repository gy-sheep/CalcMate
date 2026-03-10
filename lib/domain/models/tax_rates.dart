import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_rates.freezed.dart';

@freezed
class TaxRates with _$TaxRates {
  const factory TaxRates({
    required double nationalPensionRate,
    required int nationalPensionMin,
    required int nationalPensionMax,
    required double healthInsuranceRate,
    required double longTermCareRate,
    required double employmentInsuranceRate,
    required int basedYear,
  }) = _TaxRates;
}

/// 2024년 기준 오프라인 폴백 상수.
const kFallbackTaxRates = TaxRates(
  nationalPensionRate: 0.045,
  nationalPensionMin: 370000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03545,
  longTermCareRate: 0.1295,
  employmentInsuranceRate: 0.009,
  basedYear: 2024,
);
