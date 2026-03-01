// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExchangeRateDtoImpl _$$ExchangeRateDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ExchangeRateDtoImpl(
  base: json['base'] as String,
  rates: (json['rates'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  timestamp: (json['timestamp'] as num).toInt(),
  source: json['source'] as String,
);

Map<String, dynamic> _$$ExchangeRateDtoImplToJson(
  _$ExchangeRateDtoImpl instance,
) => <String, dynamic>{
  'base': instance.base,
  'rates': instance.rates,
  'timestamp': instance.timestamp,
  'source': instance.source,
};
