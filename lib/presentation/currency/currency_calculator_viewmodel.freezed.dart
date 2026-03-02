// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency_calculator_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExchangeRateState {
  Map<String, double> get rates => throw _privateConstructorUsedError;
  String get fromCode => throw _privateConstructorUsedError;
  List<String> get toCodes => throw _privateConstructorUsedError;
  String get input => throw _privateConstructorUsedError;
  bool get isResult => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get toastMessage => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateStateCopyWith<ExchangeRateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateStateCopyWith<$Res> {
  factory $ExchangeRateStateCopyWith(
    ExchangeRateState value,
    $Res Function(ExchangeRateState) then,
  ) = _$ExchangeRateStateCopyWithImpl<$Res, ExchangeRateState>;
  @useResult
  $Res call({
    Map<String, double> rates,
    String fromCode,
    List<String> toCodes,
    String input,
    bool isResult,
    bool isLoading,
    bool isRefreshing,
    String? error,
    String? toastMessage,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$ExchangeRateStateCopyWithImpl<$Res, $Val extends ExchangeRateState>
    implements $ExchangeRateStateCopyWith<$Res> {
  _$ExchangeRateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rates = null,
    Object? fromCode = null,
    Object? toCodes = null,
    Object? input = null,
    Object? isResult = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? toastMessage = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            rates: null == rates
                ? _value.rates
                : rates // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            fromCode: null == fromCode
                ? _value.fromCode
                : fromCode // ignore: cast_nullable_to_non_nullable
                      as String,
            toCodes: null == toCodes
                ? _value.toCodes
                : toCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as String,
            isResult: null == isResult
                ? _value.isResult
                : isResult // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRefreshing: null == isRefreshing
                ? _value.isRefreshing
                : isRefreshing // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            toastMessage: freezed == toastMessage
                ? _value.toastMessage
                : toastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateStateImplCopyWith<$Res>
    implements $ExchangeRateStateCopyWith<$Res> {
  factory _$$ExchangeRateStateImplCopyWith(
    _$ExchangeRateStateImpl value,
    $Res Function(_$ExchangeRateStateImpl) then,
  ) = __$$ExchangeRateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, double> rates,
    String fromCode,
    List<String> toCodes,
    String input,
    bool isResult,
    bool isLoading,
    bool isRefreshing,
    String? error,
    String? toastMessage,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$ExchangeRateStateImplCopyWithImpl<$Res>
    extends _$ExchangeRateStateCopyWithImpl<$Res, _$ExchangeRateStateImpl>
    implements _$$ExchangeRateStateImplCopyWith<$Res> {
  __$$ExchangeRateStateImplCopyWithImpl(
    _$ExchangeRateStateImpl _value,
    $Res Function(_$ExchangeRateStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rates = null,
    Object? fromCode = null,
    Object? toCodes = null,
    Object? input = null,
    Object? isResult = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? toastMessage = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$ExchangeRateStateImpl(
        rates: null == rates
            ? _value._rates
            : rates // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        fromCode: null == fromCode
            ? _value.fromCode
            : fromCode // ignore: cast_nullable_to_non_nullable
                  as String,
        toCodes: null == toCodes
            ? _value._toCodes
            : toCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as String,
        isResult: null == isResult
            ? _value.isResult
            : isResult // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRefreshing: null == isRefreshing
            ? _value.isRefreshing
            : isRefreshing // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        toastMessage: freezed == toastMessage
            ? _value.toastMessage
            : toastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ExchangeRateStateImpl
    with DiagnosticableTreeMixin
    implements _ExchangeRateState {
  const _$ExchangeRateStateImpl({
    final Map<String, double> rates = const {},
    this.fromCode = 'KRW',
    final List<String> toCodes = const ['USD', 'EUR', 'JPY'],
    this.input = '0',
    this.isResult = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.toastMessage,
    this.lastUpdated,
  }) : _rates = rates,
       _toCodes = toCodes;

  final Map<String, double> _rates;
  @override
  @JsonKey()
  Map<String, double> get rates {
    if (_rates is EqualUnmodifiableMapView) return _rates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rates);
  }

  @override
  @JsonKey()
  final String fromCode;
  final List<String> _toCodes;
  @override
  @JsonKey()
  List<String> get toCodes {
    if (_toCodes is EqualUnmodifiableListView) return _toCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_toCodes);
  }

  @override
  @JsonKey()
  final String input;
  @override
  @JsonKey()
  final bool isResult;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final String? error;
  @override
  final String? toastMessage;
  @override
  final DateTime? lastUpdated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ExchangeRateState(rates: $rates, fromCode: $fromCode, toCodes: $toCodes, input: $input, isResult: $isResult, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error, toastMessage: $toastMessage, lastUpdated: $lastUpdated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ExchangeRateState'))
      ..add(DiagnosticsProperty('rates', rates))
      ..add(DiagnosticsProperty('fromCode', fromCode))
      ..add(DiagnosticsProperty('toCodes', toCodes))
      ..add(DiagnosticsProperty('input', input))
      ..add(DiagnosticsProperty('isResult', isResult))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isRefreshing', isRefreshing))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('toastMessage', toastMessage))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateStateImpl &&
            const DeepCollectionEquality().equals(other._rates, _rates) &&
            (identical(other.fromCode, fromCode) ||
                other.fromCode == fromCode) &&
            const DeepCollectionEquality().equals(other._toCodes, _toCodes) &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.isResult, isResult) ||
                other.isResult == isResult) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.toastMessage, toastMessage) ||
                other.toastMessage == toastMessage) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_rates),
    fromCode,
    const DeepCollectionEquality().hash(_toCodes),
    input,
    isResult,
    isLoading,
    isRefreshing,
    error,
    toastMessage,
    lastUpdated,
  );

  /// Create a copy of ExchangeRateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateStateImplCopyWith<_$ExchangeRateStateImpl> get copyWith =>
      __$$ExchangeRateStateImplCopyWithImpl<_$ExchangeRateStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ExchangeRateState implements ExchangeRateState {
  const factory _ExchangeRateState({
    final Map<String, double> rates,
    final String fromCode,
    final List<String> toCodes,
    final String input,
    final bool isResult,
    final bool isLoading,
    final bool isRefreshing,
    final String? error,
    final String? toastMessage,
    final DateTime? lastUpdated,
  }) = _$ExchangeRateStateImpl;

  @override
  Map<String, double> get rates;
  @override
  String get fromCode;
  @override
  List<String> get toCodes;
  @override
  String get input;
  @override
  bool get isResult;
  @override
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override
  String? get error;
  @override
  String? get toastMessage;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of ExchangeRateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateStateImplCopyWith<_$ExchangeRateStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
