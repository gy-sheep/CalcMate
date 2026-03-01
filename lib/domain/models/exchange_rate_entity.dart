import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate_entity.freezed.dart';
part 'exchange_rate_entity.g.dart';

@freezed
class ExchangeRateEntity with _$ExchangeRateEntity {
  const factory ExchangeRateEntity({
    required String base,
    required Map<String, double> rates,
    required DateTime fetchedAt,
    required int timestamp,
  }) = _ExchangeRateEntity;

  factory ExchangeRateEntity.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateEntityFromJson(json);
}
