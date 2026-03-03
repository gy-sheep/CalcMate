// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vat_calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VatCalculatorState {
  VatMode get mode => throw _privateConstructorUsedError;
  InputTarget get inputTarget => throw _privateConstructorUsedError;
  String get input => throw _privateConstructorUsedError;
  bool get isResult => throw _privateConstructorUsedError;
  int get taxRate => throw _privateConstructorUsedError;
  String get taxRateInput => throw _privateConstructorUsedError;
  String? get toastMessage => throw _privateConstructorUsedError;

  /// Create a copy of VatCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VatCalculatorStateCopyWith<VatCalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VatCalculatorStateCopyWith<$Res> {
  factory $VatCalculatorStateCopyWith(
    VatCalculatorState value,
    $Res Function(VatCalculatorState) then,
  ) = _$VatCalculatorStateCopyWithImpl<$Res, VatCalculatorState>;
  @useResult
  $Res call({
    VatMode mode,
    InputTarget inputTarget,
    String input,
    bool isResult,
    int taxRate,
    String taxRateInput,
    String? toastMessage,
  });
}

/// @nodoc
class _$VatCalculatorStateCopyWithImpl<$Res, $Val extends VatCalculatorState>
    implements $VatCalculatorStateCopyWith<$Res> {
  _$VatCalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VatCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? inputTarget = null,
    Object? input = null,
    Object? isResult = null,
    Object? taxRate = null,
    Object? taxRateInput = null,
    Object? toastMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as VatMode,
            inputTarget: null == inputTarget
                ? _value.inputTarget
                : inputTarget // ignore: cast_nullable_to_non_nullable
                      as InputTarget,
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as String,
            isResult: null == isResult
                ? _value.isResult
                : isResult // ignore: cast_nullable_to_non_nullable
                      as bool,
            taxRate: null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as int,
            taxRateInput: null == taxRateInput
                ? _value.taxRateInput
                : taxRateInput // ignore: cast_nullable_to_non_nullable
                      as String,
            toastMessage: freezed == toastMessage
                ? _value.toastMessage
                : toastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VatCalculatorStateImplCopyWith<$Res>
    implements $VatCalculatorStateCopyWith<$Res> {
  factory _$$VatCalculatorStateImplCopyWith(
    _$VatCalculatorStateImpl value,
    $Res Function(_$VatCalculatorStateImpl) then,
  ) = __$$VatCalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    VatMode mode,
    InputTarget inputTarget,
    String input,
    bool isResult,
    int taxRate,
    String taxRateInput,
    String? toastMessage,
  });
}

/// @nodoc
class __$$VatCalculatorStateImplCopyWithImpl<$Res>
    extends _$VatCalculatorStateCopyWithImpl<$Res, _$VatCalculatorStateImpl>
    implements _$$VatCalculatorStateImplCopyWith<$Res> {
  __$$VatCalculatorStateImplCopyWithImpl(
    _$VatCalculatorStateImpl _value,
    $Res Function(_$VatCalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VatCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? inputTarget = null,
    Object? input = null,
    Object? isResult = null,
    Object? taxRate = null,
    Object? taxRateInput = null,
    Object? toastMessage = freezed,
  }) {
    return _then(
      _$VatCalculatorStateImpl(
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as VatMode,
        inputTarget: null == inputTarget
            ? _value.inputTarget
            : inputTarget // ignore: cast_nullable_to_non_nullable
                  as InputTarget,
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as String,
        isResult: null == isResult
            ? _value.isResult
            : isResult // ignore: cast_nullable_to_non_nullable
                  as bool,
        taxRate: null == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as int,
        taxRateInput: null == taxRateInput
            ? _value.taxRateInput
            : taxRateInput // ignore: cast_nullable_to_non_nullable
                  as String,
        toastMessage: freezed == toastMessage
            ? _value.toastMessage
            : toastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$VatCalculatorStateImpl implements _VatCalculatorState {
  const _$VatCalculatorStateImpl({
    this.mode = VatMode.exclusive,
    this.inputTarget = InputTarget.amount,
    this.input = '0',
    this.isResult = false,
    this.taxRate = 10,
    this.taxRateInput = '',
    this.toastMessage,
  });

  @override
  @JsonKey()
  final VatMode mode;
  @override
  @JsonKey()
  final InputTarget inputTarget;
  @override
  @JsonKey()
  final String input;
  @override
  @JsonKey()
  final bool isResult;
  @override
  @JsonKey()
  final int taxRate;
  @override
  @JsonKey()
  final String taxRateInput;
  @override
  final String? toastMessage;

  @override
  String toString() {
    return 'VatCalculatorState(mode: $mode, inputTarget: $inputTarget, input: $input, isResult: $isResult, taxRate: $taxRate, taxRateInput: $taxRateInput, toastMessage: $toastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VatCalculatorStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.inputTarget, inputTarget) ||
                other.inputTarget == inputTarget) &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.isResult, isResult) ||
                other.isResult == isResult) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.taxRateInput, taxRateInput) ||
                other.taxRateInput == taxRateInput) &&
            (identical(other.toastMessage, toastMessage) ||
                other.toastMessage == toastMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    inputTarget,
    input,
    isResult,
    taxRate,
    taxRateInput,
    toastMessage,
  );

  /// Create a copy of VatCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VatCalculatorStateImplCopyWith<_$VatCalculatorStateImpl> get copyWith =>
      __$$VatCalculatorStateImplCopyWithImpl<_$VatCalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _VatCalculatorState implements VatCalculatorState {
  const factory _VatCalculatorState({
    final VatMode mode,
    final InputTarget inputTarget,
    final String input,
    final bool isResult,
    final int taxRate,
    final String taxRateInput,
    final String? toastMessage,
  }) = _$VatCalculatorStateImpl;

  @override
  VatMode get mode;
  @override
  InputTarget get inputTarget;
  @override
  String get input;
  @override
  bool get isResult;
  @override
  int get taxRate;
  @override
  String get taxRateInput;
  @override
  String? get toastMessage;

  /// Create a copy of VatCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VatCalculatorStateImplCopyWith<_$VatCalculatorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
