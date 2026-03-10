// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_converter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UnitConverterState {
  int get selectedCategoryIndex => throw _privateConstructorUsedError;
  String get activeUnitCode => throw _privateConstructorUsedError;
  String get input => throw _privateConstructorUsedError;
  bool get isResult => throw _privateConstructorUsedError;
  Map<String, String> get convertedValues => throw _privateConstructorUsedError;
  Map<String, double> get rawConvertedValues =>
      throw _privateConstructorUsedError;
  String? get toastMessage => throw _privateConstructorUsedError;

  /// Create a copy of UnitConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnitConverterStateCopyWith<UnitConverterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnitConverterStateCopyWith<$Res> {
  factory $UnitConverterStateCopyWith(
    UnitConverterState value,
    $Res Function(UnitConverterState) then,
  ) = _$UnitConverterStateCopyWithImpl<$Res, UnitConverterState>;
  @useResult
  $Res call({
    int selectedCategoryIndex,
    String activeUnitCode,
    String input,
    bool isResult,
    Map<String, String> convertedValues,
    Map<String, double> rawConvertedValues,
    String? toastMessage,
  });
}

/// @nodoc
class _$UnitConverterStateCopyWithImpl<$Res, $Val extends UnitConverterState>
    implements $UnitConverterStateCopyWith<$Res> {
  _$UnitConverterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnitConverterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategoryIndex = null,
    Object? activeUnitCode = null,
    Object? input = null,
    Object? isResult = null,
    Object? convertedValues = null,
    Object? rawConvertedValues = null,
    Object? toastMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedCategoryIndex: null == selectedCategoryIndex
                ? _value.selectedCategoryIndex
                : selectedCategoryIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            activeUnitCode: null == activeUnitCode
                ? _value.activeUnitCode
                : activeUnitCode // ignore: cast_nullable_to_non_nullable
                      as String,
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as String,
            isResult: null == isResult
                ? _value.isResult
                : isResult // ignore: cast_nullable_to_non_nullable
                      as bool,
            convertedValues: null == convertedValues
                ? _value.convertedValues
                : convertedValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            rawConvertedValues: null == rawConvertedValues
                ? _value.rawConvertedValues
                : rawConvertedValues // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
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
abstract class _$$UnitConverterStateImplCopyWith<$Res>
    implements $UnitConverterStateCopyWith<$Res> {
  factory _$$UnitConverterStateImplCopyWith(
    _$UnitConverterStateImpl value,
    $Res Function(_$UnitConverterStateImpl) then,
  ) = __$$UnitConverterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int selectedCategoryIndex,
    String activeUnitCode,
    String input,
    bool isResult,
    Map<String, String> convertedValues,
    Map<String, double> rawConvertedValues,
    String? toastMessage,
  });
}

/// @nodoc
class __$$UnitConverterStateImplCopyWithImpl<$Res>
    extends _$UnitConverterStateCopyWithImpl<$Res, _$UnitConverterStateImpl>
    implements _$$UnitConverterStateImplCopyWith<$Res> {
  __$$UnitConverterStateImplCopyWithImpl(
    _$UnitConverterStateImpl _value,
    $Res Function(_$UnitConverterStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnitConverterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategoryIndex = null,
    Object? activeUnitCode = null,
    Object? input = null,
    Object? isResult = null,
    Object? convertedValues = null,
    Object? rawConvertedValues = null,
    Object? toastMessage = freezed,
  }) {
    return _then(
      _$UnitConverterStateImpl(
        selectedCategoryIndex: null == selectedCategoryIndex
            ? _value.selectedCategoryIndex
            : selectedCategoryIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        activeUnitCode: null == activeUnitCode
            ? _value.activeUnitCode
            : activeUnitCode // ignore: cast_nullable_to_non_nullable
                  as String,
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as String,
        isResult: null == isResult
            ? _value.isResult
            : isResult // ignore: cast_nullable_to_non_nullable
                  as bool,
        convertedValues: null == convertedValues
            ? _value._convertedValues
            : convertedValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        rawConvertedValues: null == rawConvertedValues
            ? _value._rawConvertedValues
            : rawConvertedValues // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        toastMessage: freezed == toastMessage
            ? _value.toastMessage
            : toastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnitConverterStateImpl implements _UnitConverterState {
  const _$UnitConverterStateImpl({
    this.selectedCategoryIndex = 0,
    this.activeUnitCode = 'cm',
    this.input = '0',
    this.isResult = false,
    final Map<String, String> convertedValues = const {},
    final Map<String, double> rawConvertedValues = const {},
    this.toastMessage,
  }) : _convertedValues = convertedValues,
       _rawConvertedValues = rawConvertedValues;

  @override
  @JsonKey()
  final int selectedCategoryIndex;
  @override
  @JsonKey()
  final String activeUnitCode;
  @override
  @JsonKey()
  final String input;
  @override
  @JsonKey()
  final bool isResult;
  final Map<String, String> _convertedValues;
  @override
  @JsonKey()
  Map<String, String> get convertedValues {
    if (_convertedValues is EqualUnmodifiableMapView) return _convertedValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_convertedValues);
  }

  final Map<String, double> _rawConvertedValues;
  @override
  @JsonKey()
  Map<String, double> get rawConvertedValues {
    if (_rawConvertedValues is EqualUnmodifiableMapView)
      return _rawConvertedValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_rawConvertedValues);
  }

  @override
  final String? toastMessage;

  @override
  String toString() {
    return 'UnitConverterState(selectedCategoryIndex: $selectedCategoryIndex, activeUnitCode: $activeUnitCode, input: $input, isResult: $isResult, convertedValues: $convertedValues, rawConvertedValues: $rawConvertedValues, toastMessage: $toastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnitConverterStateImpl &&
            (identical(other.selectedCategoryIndex, selectedCategoryIndex) ||
                other.selectedCategoryIndex == selectedCategoryIndex) &&
            (identical(other.activeUnitCode, activeUnitCode) ||
                other.activeUnitCode == activeUnitCode) &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.isResult, isResult) ||
                other.isResult == isResult) &&
            const DeepCollectionEquality().equals(
              other._convertedValues,
              _convertedValues,
            ) &&
            const DeepCollectionEquality().equals(
              other._rawConvertedValues,
              _rawConvertedValues,
            ) &&
            (identical(other.toastMessage, toastMessage) ||
                other.toastMessage == toastMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedCategoryIndex,
    activeUnitCode,
    input,
    isResult,
    const DeepCollectionEquality().hash(_convertedValues),
    const DeepCollectionEquality().hash(_rawConvertedValues),
    toastMessage,
  );

  /// Create a copy of UnitConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnitConverterStateImplCopyWith<_$UnitConverterStateImpl> get copyWith =>
      __$$UnitConverterStateImplCopyWithImpl<_$UnitConverterStateImpl>(
        this,
        _$identity,
      );
}

abstract class _UnitConverterState implements UnitConverterState {
  const factory _UnitConverterState({
    final int selectedCategoryIndex,
    final String activeUnitCode,
    final String input,
    final bool isResult,
    final Map<String, String> convertedValues,
    final Map<String, double> rawConvertedValues,
    final String? toastMessage,
  }) = _$UnitConverterStateImpl;

  @override
  int get selectedCategoryIndex;
  @override
  String get activeUnitCode;
  @override
  String get input;
  @override
  bool get isResult;
  @override
  Map<String, String> get convertedValues;
  @override
  Map<String, double> get rawConvertedValues;
  @override
  String? get toastMessage;

  /// Create a copy of UnitConverterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnitConverterStateImplCopyWith<_$UnitConverterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
