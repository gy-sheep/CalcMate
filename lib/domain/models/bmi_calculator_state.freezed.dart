// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bmi_calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BmiCalculatorState {
  double get heightCm => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  bool get isMetric => throw _privateConstructorUsedError;
  BmiStandard get standard => throw _privateConstructorUsedError;

  /// Create a copy of BmiCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BmiCalculatorStateCopyWith<BmiCalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BmiCalculatorStateCopyWith<$Res> {
  factory $BmiCalculatorStateCopyWith(
    BmiCalculatorState value,
    $Res Function(BmiCalculatorState) then,
  ) = _$BmiCalculatorStateCopyWithImpl<$Res, BmiCalculatorState>;
  @useResult
  $Res call({
    double heightCm,
    double weightKg,
    bool isMetric,
    BmiStandard standard,
  });
}

/// @nodoc
class _$BmiCalculatorStateCopyWithImpl<$Res, $Val extends BmiCalculatorState>
    implements $BmiCalculatorStateCopyWith<$Res> {
  _$BmiCalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BmiCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = null,
    Object? weightKg = null,
    Object? isMetric = null,
    Object? standard = null,
  }) {
    return _then(
      _value.copyWith(
            heightCm: null == heightCm
                ? _value.heightCm
                : heightCm // ignore: cast_nullable_to_non_nullable
                      as double,
            weightKg: null == weightKg
                ? _value.weightKg
                : weightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            isMetric: null == isMetric
                ? _value.isMetric
                : isMetric // ignore: cast_nullable_to_non_nullable
                      as bool,
            standard: null == standard
                ? _value.standard
                : standard // ignore: cast_nullable_to_non_nullable
                      as BmiStandard,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BmiCalculatorStateImplCopyWith<$Res>
    implements $BmiCalculatorStateCopyWith<$Res> {
  factory _$$BmiCalculatorStateImplCopyWith(
    _$BmiCalculatorStateImpl value,
    $Res Function(_$BmiCalculatorStateImpl) then,
  ) = __$$BmiCalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double heightCm,
    double weightKg,
    bool isMetric,
    BmiStandard standard,
  });
}

/// @nodoc
class __$$BmiCalculatorStateImplCopyWithImpl<$Res>
    extends _$BmiCalculatorStateCopyWithImpl<$Res, _$BmiCalculatorStateImpl>
    implements _$$BmiCalculatorStateImplCopyWith<$Res> {
  __$$BmiCalculatorStateImplCopyWithImpl(
    _$BmiCalculatorStateImpl _value,
    $Res Function(_$BmiCalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BmiCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? heightCm = null,
    Object? weightKg = null,
    Object? isMetric = null,
    Object? standard = null,
  }) {
    return _then(
      _$BmiCalculatorStateImpl(
        heightCm: null == heightCm
            ? _value.heightCm
            : heightCm // ignore: cast_nullable_to_non_nullable
                  as double,
        weightKg: null == weightKg
            ? _value.weightKg
            : weightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        isMetric: null == isMetric
            ? _value.isMetric
            : isMetric // ignore: cast_nullable_to_non_nullable
                  as bool,
        standard: null == standard
            ? _value.standard
            : standard // ignore: cast_nullable_to_non_nullable
                  as BmiStandard,
      ),
    );
  }
}

/// @nodoc

class _$BmiCalculatorStateImpl implements _BmiCalculatorState {
  const _$BmiCalculatorStateImpl({
    this.heightCm = 170.0,
    this.weightKg = 65.0,
    this.isMetric = true,
    this.standard = BmiStandard.global,
  });

  @override
  @JsonKey()
  final double heightCm;
  @override
  @JsonKey()
  final double weightKg;
  @override
  @JsonKey()
  final bool isMetric;
  @override
  @JsonKey()
  final BmiStandard standard;

  @override
  String toString() {
    return 'BmiCalculatorState(heightCm: $heightCm, weightKg: $weightKg, isMetric: $isMetric, standard: $standard)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BmiCalculatorStateImpl &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.isMetric, isMetric) ||
                other.isMetric == isMetric) &&
            (identical(other.standard, standard) ||
                other.standard == standard));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, heightCm, weightKg, isMetric, standard);

  /// Create a copy of BmiCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BmiCalculatorStateImplCopyWith<_$BmiCalculatorStateImpl> get copyWith =>
      __$$BmiCalculatorStateImplCopyWithImpl<_$BmiCalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _BmiCalculatorState implements BmiCalculatorState {
  const factory _BmiCalculatorState({
    final double heightCm,
    final double weightKg,
    final bool isMetric,
    final BmiStandard standard,
  }) = _$BmiCalculatorStateImpl;

  @override
  double get heightCm;
  @override
  double get weightKg;
  @override
  bool get isMetric;
  @override
  BmiStandard get standard;

  /// Create a copy of BmiCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BmiCalculatorStateImplCopyWith<_$BmiCalculatorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
