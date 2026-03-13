import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_rates.freezed.dart';
part 'tax_rates.g.dart';

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
    int? basedHalf,
    List<IncomeTaxBracket>? incomeTaxTable,
    List<OverTenMillionBracket>? overTenMillionBrackets,
    ChildTaxCredit? childTaxCredit,
  }) = _TaxRates;

  factory TaxRates.fromJson(Map<String, dynamic> json) =>
      _$TaxRatesFromJson(json);
}

@freezed
class IncomeTaxBracket with _$IncomeTaxBracket {
  const factory IncomeTaxBracket({
    required int min,
    required int max,
    required List<int> taxes,
  }) = _IncomeTaxBracket;

  factory IncomeTaxBracket.fromJson(Map<String, dynamic> json) =>
      _$IncomeTaxBracketFromJson(json);
}

@freezed
class OverTenMillionBracket with _$OverTenMillionBracket {
  const factory OverTenMillionBracket({
    required int min,
    required int max,
    required int baseAdd,
    required double rate,
    required double applyRatio,
    required int excessFrom,
  }) = _OverTenMillionBracket;

  factory OverTenMillionBracket.fromJson(Map<String, dynamic> json) =>
      _$OverTenMillionBracketFromJson(json);
}

@freezed
class ChildTaxCredit with _$ChildTaxCredit {
  const factory ChildTaxCredit({
    required int one,
    required int two,
    required int perExtra,
  }) = _ChildTaxCredit;

  factory ChildTaxCredit.fromJson(Map<String, dynamic> json) =>
      _$ChildTaxCreditFromJson(json);
}
