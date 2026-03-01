import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/exchange_rate_entity.dart';

part 'exchange_rate_dto.freezed.dart';
part 'exchange_rate_dto.g.dart';

@freezed
class ExchangeRateDto with _$ExchangeRateDto {
  const factory ExchangeRateDto({
    required String base,
    required Map<String, double> rates,
    required int timestamp,
    required String source,
  }) = _ExchangeRateDto;

  factory ExchangeRateDto.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateDtoFromJson(json);
}

extension ExchangeRateDtoX on ExchangeRateDto {
  ExchangeRateEntity toEntity() => ExchangeRateEntity(
        base: base,
        rates: rates,
        fetchedAt: DateTime.now(),
        timestamp: timestamp,
      );
}
