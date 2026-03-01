// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExchangeRateEntity _$ExchangeRateEntityFromJson(Map<String, dynamic> json) {
  return _ExchangeRateEntity.fromJson(json);
}

/// @nodoc
mixin _$ExchangeRateEntity {
  String get base => throw _privateConstructorUsedError;
  Map<String, double> get rates => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ExchangeRateEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateEntityCopyWith<ExchangeRateEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateEntityCopyWith<$Res> {
  factory $ExchangeRateEntityCopyWith(
    ExchangeRateEntity value,
    $Res Function(ExchangeRateEntity) then,
  ) = _$ExchangeRateEntityCopyWithImpl<$Res, ExchangeRateEntity>;
  @useResult
  $Res call({
    String base,
    Map<String, double> rates,
    DateTime fetchedAt,
    int timestamp,
  });
}

/// @nodoc
class _$ExchangeRateEntityCopyWithImpl<$Res, $Val extends ExchangeRateEntity>
    implements $ExchangeRateEntityCopyWith<$Res> {
  _$ExchangeRateEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? rates = null,
    Object? fetchedAt = null,
    Object? timestamp = null,
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
            fetchedAt: null == fetchedAt
                ? _value.fetchedAt
                : fetchedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateEntityImplCopyWith<$Res>
    implements $ExchangeRateEntityCopyWith<$Res> {
  factory _$$ExchangeRateEntityImplCopyWith(
    _$ExchangeRateEntityImpl value,
    $Res Function(_$ExchangeRateEntityImpl) then,
  ) = __$$ExchangeRateEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String base,
    Map<String, double> rates,
    DateTime fetchedAt,
    int timestamp,
  });
}

/// @nodoc
class __$$ExchangeRateEntityImplCopyWithImpl<$Res>
    extends _$ExchangeRateEntityCopyWithImpl<$Res, _$ExchangeRateEntityImpl>
    implements _$$ExchangeRateEntityImplCopyWith<$Res> {
  __$$ExchangeRateEntityImplCopyWithImpl(
    _$ExchangeRateEntityImpl _value,
    $Res Function(_$ExchangeRateEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base = null,
    Object? rates = null,
    Object? fetchedAt = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$ExchangeRateEntityImpl(
        base: null == base
            ? _value.base
            : base // ignore: cast_nullable_to_non_nullable
                  as String,
        rates: null == rates
            ? _value._rates
            : rates // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        fetchedAt: null == fetchedAt
            ? _value.fetchedAt
            : fetchedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExchangeRateEntityImpl implements _ExchangeRateEntity {
  const _$ExchangeRateEntityImpl({
    required this.base,
    required final Map<String, double> rates,
    required this.fetchedAt,
    required this.timestamp,
  }) : _rates = rates;

  factory _$ExchangeRateEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExchangeRateEntityImplFromJson(json);

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
  final DateTime fetchedAt;
  @override
  final int timestamp;

  @override
  String toString() {
    return 'ExchangeRateEntity(base: $base, rates: $rates, fetchedAt: $fetchedAt, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateEntityImpl &&
            (identical(other.base, base) || other.base == base) &&
            const DeepCollectionEquality().equals(other._rates, _rates) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    base,
    const DeepCollectionEquality().hash(_rates),
    fetchedAt,
    timestamp,
  );

  /// Create a copy of ExchangeRateEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateEntityImplCopyWith<_$ExchangeRateEntityImpl> get copyWith =>
      __$$ExchangeRateEntityImplCopyWithImpl<_$ExchangeRateEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExchangeRateEntityImplToJson(this);
  }
}

abstract class _ExchangeRateEntity implements ExchangeRateEntity {
  const factory _ExchangeRateEntity({
    required final String base,
    required final Map<String, double> rates,
    required final DateTime fetchedAt,
    required final int timestamp,
  }) = _$ExchangeRateEntityImpl;

  factory _ExchangeRateEntity.fromJson(Map<String, dynamic> json) =
      _$ExchangeRateEntityImpl.fromJson;

  @override
  String get base;
  @override
  Map<String, double> get rates;
  @override
  DateTime get fetchedAt;
  @override
  int get timestamp;

  /// Create a copy of ExchangeRateEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateEntityImplCopyWith<_$ExchangeRateEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
