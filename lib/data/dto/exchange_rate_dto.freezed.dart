// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExchangeRateDto _$ExchangeRateDtoFromJson(Map<String, dynamic> json) {
  return _ExchangeRateDto.fromJson(json);
}

/// @nodoc
mixin _$ExchangeRateDto {
  String get base => throw _privateConstructorUsedError;
  Map<String, double> get rates => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;

  /// Serializes this ExchangeRateDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateDtoCopyWith<ExchangeRateDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateDtoCopyWith<$Res> {
  factory $ExchangeRateDtoCopyWith(
    ExchangeRateDto value,
    $Res Function(ExchangeRateDto) then,
  ) = _$ExchangeRateDtoCopyWithImpl<$Res, ExchangeRateDto>;
  @useResult
  $Res call({
    String base,
    Map<String, double> rates,
    int timestamp,
    String source,
  });
}

/// @nodoc
class _$ExchangeRateDtoCopyWithImpl<$Res, $Val extends ExchangeRateDto>
    implements $ExchangeRateDtoCopyWith<$Res> {
  _$ExchangeRateDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? rates = null,
    Object? timestamp = null,
    Object? source = null,
  }) {
    return _then(
      _value.copyWith(
            base: null == base
                ? _value.base
                : base // ignore: cast_nullable_to_non_nullable
                      as String,
            rates: null == rates
                ? _value.rates
                : rates // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateDtoImplCopyWith<$Res>
    implements $ExchangeRateDtoCopyWith<$Res> {
  factory _$$ExchangeRateDtoImplCopyWith(
    _$ExchangeRateDtoImpl value,
    $Res Function(_$ExchangeRateDtoImpl) then,
  ) = __$$ExchangeRateDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String base,
    Map<String, double> rates,
    int timestamp,
    String source,
  });
}

/// @nodoc
class __$$ExchangeRateDtoImplCopyWithImpl<$Res>
    extends _$ExchangeRateDtoCopyWithImpl<$Res, _$ExchangeRateDtoImpl>
    implements _$$ExchangeRateDtoImplCopyWith<$Res> {
  __$$ExchangeRateDtoImplCopyWithImpl(
    _$ExchangeRateDtoImpl _value,
    $Res Function(_$ExchangeRateDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? rates = null,
    Object? timestamp = null,
    Object? source = null,
  }) {
    return _then(
      _$ExchangeRateDtoImpl(
        base: null == base
            ? _value.base
            : base // ignore: cast_nullable_to_non_nullable
                  as String,
        rates: null == rates
            ? _value._rates
            : rates // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExchangeRateDtoImpl implements _ExchangeRateDto {
  const _$ExchangeRateDtoImpl({
    required this.base,
    required final Map<String, double> rates,
    required this.timestamp,
    required this.source,
  }) : _rates = rates;

  factory _$ExchangeRateDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExchangeRateDtoImplFromJson(json);

  @override
  final String base;
  final Map<String, double> _rates;
  @override
  Map<String, double> get rates {
    if (_rates is EqualUnmodifiableMapView) return _rates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rates);
  }

  @override
  final int timestamp;
  @override
  final String source;

  @override
  String toString() {
    return 'ExchangeRateDto(base: $base, rates: $rates, timestamp: $timestamp, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateDtoImpl &&
            (identical(other.base, base) || other.base == base) &&
            const DeepCollectionEquality().equals(other._rates, _rates) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    base,
    const DeepCollectionEquality().hash(_rates),
    timestamp,
    source,
  );

  /// Create a copy of ExchangeRateDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateDtoImplCopyWith<_$ExchangeRateDtoImpl> get copyWith =>
      __$$ExchangeRateDtoImplCopyWithImpl<_$ExchangeRateDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExchangeRateDtoImplToJson(this);
  }
}

abstract class _ExchangeRateDto implements ExchangeRateDto {
  const factory _ExchangeRateDto({
    required final String base,
    required final Map<String, double> rates,
    required final int timestamp,
    required final String source,
  }) = _$ExchangeRateDtoImpl;

  factory _ExchangeRateDto.fromJson(Map<String, dynamic> json) =
      _$ExchangeRateDtoImpl.fromJson;

  @override
  String get base;
  @override
  Map<String, double> get rates;
  @override
  int get timestamp;
  @override
  String get source;

  /// Create a copy of ExchangeRateDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateDtoImplCopyWith<_$ExchangeRateDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
