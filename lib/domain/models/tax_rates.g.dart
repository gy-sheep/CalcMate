// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_rates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaxRatesImpl _$$TaxRatesImplFromJson(
  Map<String, dynamic> json,
) => _$TaxRatesImpl(
  nationalPensionRate: (json['nationalPensionRate'] as num).toDouble(),
  nationalPensionMin: (json['nationalPensionMin'] as num).toInt(),
  nationalPensionMax: (json['nationalPensionMax'] as num).toInt(),
  healthInsuranceRate: (json['healthInsuranceRate'] as num).toDouble(),
  longTermCareRate: (json['longTermCareRate'] as num).toDouble(),
  employmentInsuranceRate: (json['employmentInsuranceRate'] as num).toDouble(),
  basedYear: (json['basedYear'] as num).toInt(),
  basedHalf: (json['basedHalf'] as num?)?.toInt(),
  incomeTaxTable: (json['incomeTaxTable'] as List<dynamic>?)
      ?.map((e) => IncomeTaxBracket.fromJson(e as Map<String, dynamic>))
      .toList(),
  overTenMillionBrackets: (json['overTenMillionBrackets'] as List<dynamic>?)
      ?.map((e) => OverTenMillionBracket.fromJson(e as Map<String, dynamic>))
      .toList(),
  childTaxCredit: json['childTaxCredit'] == null
      ? null
      : ChildTaxCredit.fromJson(json['childTaxCredit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TaxRatesImplToJson(_$TaxRatesImpl instance) =>
    <String, dynamic>{
      'nationalPensionRate': instance.nationalPensionRate,
      'nationalPensionMin': instance.nationalPensionMin,
      'nationalPensionMax': instance.nationalPensionMax,
      'healthInsuranceRate': instance.healthInsuranceRate,
      'longTermCareRate': instance.longTermCareRate,
      'employmentInsuranceRate': instance.employmentInsuranceRate,
      'basedYear': instance.basedYear,
      'basedHalf': instance.basedHalf,
      'incomeTaxTable': instance.incomeTaxTable,
      'overTenMillionBrackets': instance.overTenMillionBrackets,
      'childTaxCredit': instance.childTaxCredit,
    };

_$IncomeTaxBracketImpl _$$IncomeTaxBracketImplFromJson(
  Map<String, dynamic> json,
) => _$IncomeTaxBracketImpl(
  min: (json['min'] as num).toInt(),
  max: (json['max'] as num).toInt(),
  taxes: (json['taxes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$$IncomeTaxBracketImplToJson(
  _$IncomeTaxBracketImpl instance,
) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
  'taxes': instance.taxes,
};

_$OverTenMillionBracketImpl _$$OverTenMillionBracketImplFromJson(
  Map<String, dynamic> json,
) => _$OverTenMillionBracketImpl(
  min: (json['min'] as num).toInt(),
  max: (json['max'] as num).toInt(),
  baseAdd: (json['baseAdd'] as num).toInt(),
  rate: (json['rate'] as num).toDouble(),
  applyRatio: (json['applyRatio'] as num).toDouble(),
  excessFrom: (json['excessFrom'] as num).toInt(),
);

Map<String, dynamic> _$$OverTenMillionBracketImplToJson(
  _$OverTenMillionBracketImpl instance,
) => <String, dynamic>{
  'min': instance.min,
  'max': instance.max,
  'baseAdd': instance.baseAdd,
  'rate': instance.rate,
  'applyRatio': instance.applyRatio,
  'excessFrom': instance.excessFrom,
};

_$ChildTaxCreditImpl _$$ChildTaxCreditImplFromJson(Map<String, dynamic> json) =>
    _$ChildTaxCreditImpl(
      one: (json['one'] as num).toInt(),
      two: (json['two'] as num).toInt(),
      perExtra: (json['perExtra'] as num).toInt(),
    );

Map<String, dynamic> _$$ChildTaxCreditImplToJson(
  _$ChildTaxCreditImpl instance,
) => <String, dynamic>{
  'one': instance.one,
  'two': instance.two,
  'perExtra': instance.perExtra,
};
