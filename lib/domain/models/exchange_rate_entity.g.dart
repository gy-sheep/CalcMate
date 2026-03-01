// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExchangeRateEntityImpl _$$ExchangeRateEntityImplFromJson(
  Map<String, dynamic> json,
) => _$ExchangeRateEntityImpl(
  base: json['base'] as String,
  rates: (json['rates'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  fetchedAt: DateTime.parse(json['fetchedAt'] as String),
  timestamp: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$$ExchangeRateEntityImplToJson(
  _$ExchangeRateEntityImpl instance,
) => <String, dynamic>{
  'base': instance.base,
  'rates': instance.rates,
  'fetchedAt': instance.fetchedAt.toIso8601String(),
  'timestamp': instance.timestamp,
};
