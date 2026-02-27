// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CalculatorState {
  String get input => throw _privateConstructorUsedError;
  String get expression => throw _privateConstructorUsedError;
  bool get isResult => throw _privateConstructorUsedError;

  /// Create a copy of CalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalculatorStateCopyWith<CalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculatorStateCopyWith<$Res> {
  factory $CalculatorStateCopyWith(
    CalculatorState value,
    $Res Function(CalculatorState) then,
  ) = _$CalculatorStateCopyWithImpl<$Res, CalculatorState>;
  @useResult
  $Res call({String input, String expression, bool isResult});
}

/// @nodoc
class _$CalculatorStateCopyWithImpl<$Res, $Val extends CalculatorState>
    implements $CalculatorStateCopyWith<$Res> {
  _$CalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? expression = null,
    Object? isResult = null,
  }) {
    return _then(
      _value.copyWith(
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as String,
            expression: null == expression
                ? _value.expression
                : expression // ignore: cast_nullable_to_non_nullable
                      as String,
            isResult: null == isResult
                ? _value.isResult
                : isResult // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalculatorStateImplCopyWith<$Res>
    implements $CalculatorStateCopyWith<$Res> {
  factory _$$CalculatorStateImplCopyWith(
    _$CalculatorStateImpl value,
    $Res Function(_$CalculatorStateImpl) then,
  ) = __$$CalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String input, String expression, bool isResult});
}

/// @nodoc
class __$$CalculatorStateImplCopyWithImpl<$Res>
    extends _$CalculatorStateCopyWithImpl<$Res, _$CalculatorStateImpl>
    implements _$$CalculatorStateImplCopyWith<$Res> {
  __$$CalculatorStateImplCopyWithImpl(
    _$CalculatorStateImpl _value,
    $Res Function(_$CalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? expression = null,
    Object? isResult = null,
  }) {
    return _then(
      _$CalculatorStateImpl(
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as String,
        expression: null == expression
            ? _value.expression
            : expression // ignore: cast_nullable_to_non_nullable
                  as String,
        isResult: null == isResult
            ? _value.isResult
            : isResult // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CalculatorStateImpl implements _CalculatorState {
  const _$CalculatorStateImpl({
    this.input = '0',
    this.expression = '',
    this.isResult = false,
  });

  @override
  @JsonKey()
  final String input;
  @override
  @JsonKey()
  final String expression;
  @override
  @JsonKey()
  final bool isResult;

  @override
  String toString() {
    return 'CalculatorState(input: $input, expression: $expression, isResult: $isResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculatorStateImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.expression, expression) ||
                other.expression == expression) &&
            (identical(other.isResult, isResult) ||
                other.isResult == isResult));
  }

  @override
  int get hashCode => Object.hash(runtimeType, input, expression, isResult);

  /// Create a copy of CalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculatorStateImplCopyWith<_$CalculatorStateImpl> get copyWith =>
      __$$CalculatorStateImplCopyWithImpl<_$CalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CalculatorState implements CalculatorState {
  const factory _CalculatorState({
    final String input,
    final String expression,
    final bool isResult,
  }) = _$CalculatorStateImpl;

  @override
  String get input;
  @override
  String get expression;
  @override
  bool get isResult;

  /// Create a copy of CalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalculatorStateImplCopyWith<_$CalculatorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
