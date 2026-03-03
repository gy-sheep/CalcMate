// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'age_calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AgeCalculatorState {
  AgeCalendarType get calendarType => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get day => throw _privateConstructorUsedError;
  bool get isLeapMonth => throw _privateConstructorUsedError;

  /// Create a copy of AgeCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgeCalculatorStateCopyWith<AgeCalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgeCalculatorStateCopyWith<$Res> {
  factory $AgeCalculatorStateCopyWith(
    AgeCalculatorState value,
    $Res Function(AgeCalculatorState) then,
  ) = _$AgeCalculatorStateCopyWithImpl<$Res, AgeCalculatorState>;
  @useResult
  $Res call({
    AgeCalendarType calendarType,
    int year,
    int month,
    int day,
    bool isLeapMonth,
  });
}

/// @nodoc
class _$AgeCalculatorStateCopyWithImpl<$Res, $Val extends AgeCalculatorState>
    implements $AgeCalculatorStateCopyWith<$Res> {
  _$AgeCalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgeCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calendarType = null,
    Object? year = null,
    Object? month = null,
    Object? day = null,
    Object? isLeapMonth = null,
  }) {
    return _then(
      _value.copyWith(
            calendarType: null == calendarType
                ? _value.calendarType
                : calendarType // ignore: cast_nullable_to_non_nullable
                      as AgeCalendarType,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as int,
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as int,
            isLeapMonth: null == isLeapMonth
                ? _value.isLeapMonth
                : isLeapMonth // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgeCalculatorStateImplCopyWith<$Res>
    implements $AgeCalculatorStateCopyWith<$Res> {
  factory _$$AgeCalculatorStateImplCopyWith(
    _$AgeCalculatorStateImpl value,
    $Res Function(_$AgeCalculatorStateImpl) then,
  ) = __$$AgeCalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AgeCalendarType calendarType,
    int year,
    int month,
    int day,
    bool isLeapMonth,
  });
}

/// @nodoc
class __$$AgeCalculatorStateImplCopyWithImpl<$Res>
    extends _$AgeCalculatorStateCopyWithImpl<$Res, _$AgeCalculatorStateImpl>
    implements _$$AgeCalculatorStateImplCopyWith<$Res> {
  __$$AgeCalculatorStateImplCopyWithImpl(
    _$AgeCalculatorStateImpl _value,
    $Res Function(_$AgeCalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgeCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calendarType = null,
    Object? year = null,
    Object? month = null,
    Object? day = null,
    Object? isLeapMonth = null,
  }) {
    return _then(
      _$AgeCalculatorStateImpl(
        calendarType: null == calendarType
            ? _value.calendarType
            : calendarType // ignore: cast_nullable_to_non_nullable
                  as AgeCalendarType,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as int,
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as int,
        isLeapMonth: null == isLeapMonth
            ? _value.isLeapMonth
            : isLeapMonth // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AgeCalculatorStateImpl implements _AgeCalculatorState {
  const _$AgeCalculatorStateImpl({
    this.calendarType = AgeCalendarType.solar,
    required this.year,
    this.month = 1,
    this.day = 1,
    this.isLeapMonth = false,
  });

  @override
  @JsonKey()
  final AgeCalendarType calendarType;
  @override
  final int year;
  @override
  @JsonKey()
  final int month;
  @override
  @JsonKey()
  final int day;
  @override
  @JsonKey()
  final bool isLeapMonth;

  @override
  String toString() {
    return 'AgeCalculatorState(calendarType: $calendarType, year: $year, month: $month, day: $day, isLeapMonth: $isLeapMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgeCalculatorStateImpl &&
            (identical(other.calendarType, calendarType) ||
                other.calendarType == calendarType) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.isLeapMonth, isLeapMonth) ||
                other.isLeapMonth == isLeapMonth));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, calendarType, year, month, day, isLeapMonth);

  /// Create a copy of AgeCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgeCalculatorStateImplCopyWith<_$AgeCalculatorStateImpl> get copyWith =>
      __$$AgeCalculatorStateImplCopyWithImpl<_$AgeCalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AgeCalculatorState implements AgeCalculatorState {
  const factory _AgeCalculatorState({
    final AgeCalendarType calendarType,
    required final int year,
    final int month,
    final int day,
    final bool isLeapMonth,
  }) = _$AgeCalculatorStateImpl;

  @override
  AgeCalendarType get calendarType;
  @override
  int get year;
  @override
  int get month;
  @override
  int get day;
  @override
  bool get isLeapMonth;

  /// Create a copy of AgeCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgeCalculatorStateImplCopyWith<_$AgeCalculatorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
