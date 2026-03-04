// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'date_calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DateCalculatorState {
  int get mode => throw _privateConstructorUsedError; // 모드 0: 기간 계산
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  bool get includeStartDay => throw _privateConstructorUsedError; // 모드 1: 날짜 계산
  DateTime get calcBase => throw _privateConstructorUsedError;
  String get calcNumberInput => throw _privateConstructorUsedError;
  int get calcDirection => throw _privateConstructorUsedError; // 0=더하기, 1=빼기
  int get calcUnit => throw _privateConstructorUsedError; // 0=일, 1=주, 2=월, 3=년
  // 모드 2: D-Day
  DateTime get ddayTarget => throw _privateConstructorUsedError;
  DateTime get ddayReference => throw _privateConstructorUsedError;
  bool get ddayRefIsToday => throw _privateConstructorUsedError;

  /// Create a copy of DateCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DateCalculatorStateCopyWith<DateCalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DateCalculatorStateCopyWith<$Res> {
  factory $DateCalculatorStateCopyWith(
    DateCalculatorState value,
    $Res Function(DateCalculatorState) then,
  ) = _$DateCalculatorStateCopyWithImpl<$Res, DateCalculatorState>;
  @useResult
  $Res call({
    int mode,
    DateTime periodStart,
    DateTime periodEnd,
    bool includeStartDay,
    DateTime calcBase,
    String calcNumberInput,
    int calcDirection,
    int calcUnit,
    DateTime ddayTarget,
    DateTime ddayReference,
    bool ddayRefIsToday,
  });
}

/// @nodoc
class _$DateCalculatorStateCopyWithImpl<$Res, $Val extends DateCalculatorState>
    implements $DateCalculatorStateCopyWith<$Res> {
  _$DateCalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DateCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? includeStartDay = null,
    Object? calcBase = null,
    Object? calcNumberInput = null,
    Object? calcDirection = null,
    Object? calcUnit = null,
    Object? ddayTarget = null,
    Object? ddayReference = null,
    Object? ddayRefIsToday = null,
  }) {
    return _then(
      _value.copyWith(
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as int,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            includeStartDay: null == includeStartDay
                ? _value.includeStartDay
                : includeStartDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            calcBase: null == calcBase
                ? _value.calcBase
                : calcBase // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            calcNumberInput: null == calcNumberInput
                ? _value.calcNumberInput
                : calcNumberInput // ignore: cast_nullable_to_non_nullable
                      as String,
            calcDirection: null == calcDirection
                ? _value.calcDirection
                : calcDirection // ignore: cast_nullable_to_non_nullable
                      as int,
            calcUnit: null == calcUnit
                ? _value.calcUnit
                : calcUnit // ignore: cast_nullable_to_non_nullable
                      as int,
            ddayTarget: null == ddayTarget
                ? _value.ddayTarget
                : ddayTarget // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ddayReference: null == ddayReference
                ? _value.ddayReference
                : ddayReference // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ddayRefIsToday: null == ddayRefIsToday
                ? _value.ddayRefIsToday
                : ddayRefIsToday // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DateCalculatorStateImplCopyWith<$Res>
    implements $DateCalculatorStateCopyWith<$Res> {
  factory _$$DateCalculatorStateImplCopyWith(
    _$DateCalculatorStateImpl value,
    $Res Function(_$DateCalculatorStateImpl) then,
  ) = __$$DateCalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int mode,
    DateTime periodStart,
    DateTime periodEnd,
    bool includeStartDay,
    DateTime calcBase,
    String calcNumberInput,
    int calcDirection,
    int calcUnit,
    DateTime ddayTarget,
    DateTime ddayReference,
    bool ddayRefIsToday,
  });
}

/// @nodoc
class __$$DateCalculatorStateImplCopyWithImpl<$Res>
    extends _$DateCalculatorStateCopyWithImpl<$Res, _$DateCalculatorStateImpl>
    implements _$$DateCalculatorStateImplCopyWith<$Res> {
  __$$DateCalculatorStateImplCopyWithImpl(
    _$DateCalculatorStateImpl _value,
    $Res Function(_$DateCalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DateCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? includeStartDay = null,
    Object? calcBase = null,
    Object? calcNumberInput = null,
    Object? calcDirection = null,
    Object? calcUnit = null,
    Object? ddayTarget = null,
    Object? ddayReference = null,
    Object? ddayRefIsToday = null,
  }) {
    return _then(
      _$DateCalculatorStateImpl(
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as int,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        includeStartDay: null == includeStartDay
            ? _value.includeStartDay
            : includeStartDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        calcBase: null == calcBase
            ? _value.calcBase
            : calcBase // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        calcNumberInput: null == calcNumberInput
            ? _value.calcNumberInput
            : calcNumberInput // ignore: cast_nullable_to_non_nullable
                  as String,
        calcDirection: null == calcDirection
            ? _value.calcDirection
            : calcDirection // ignore: cast_nullable_to_non_nullable
                  as int,
        calcUnit: null == calcUnit
            ? _value.calcUnit
            : calcUnit // ignore: cast_nullable_to_non_nullable
                  as int,
        ddayTarget: null == ddayTarget
            ? _value.ddayTarget
            : ddayTarget // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ddayReference: null == ddayReference
            ? _value.ddayReference
            : ddayReference // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ddayRefIsToday: null == ddayRefIsToday
            ? _value.ddayRefIsToday
            : ddayRefIsToday // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$DateCalculatorStateImpl implements _DateCalculatorState {
  const _$DateCalculatorStateImpl({
    this.mode = 0,
    required this.periodStart,
    required this.periodEnd,
    this.includeStartDay = false,
    required this.calcBase,
    this.calcNumberInput = '100',
    this.calcDirection = 0,
    this.calcUnit = 0,
    required this.ddayTarget,
    required this.ddayReference,
    this.ddayRefIsToday = true,
  });

  @override
  @JsonKey()
  final int mode;
  // 모드 0: 기간 계산
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  @JsonKey()
  final bool includeStartDay;
  // 모드 1: 날짜 계산
  @override
  final DateTime calcBase;
  @override
  @JsonKey()
  final String calcNumberInput;
  @override
  @JsonKey()
  final int calcDirection;
  // 0=더하기, 1=빼기
  @override
  @JsonKey()
  final int calcUnit;
  // 0=일, 1=주, 2=월, 3=년
  // 모드 2: D-Day
  @override
  final DateTime ddayTarget;
  @override
  final DateTime ddayReference;
  @override
  @JsonKey()
  final bool ddayRefIsToday;

  @override
  String toString() {
    return 'DateCalculatorState(mode: $mode, periodStart: $periodStart, periodEnd: $periodEnd, includeStartDay: $includeStartDay, calcBase: $calcBase, calcNumberInput: $calcNumberInput, calcDirection: $calcDirection, calcUnit: $calcUnit, ddayTarget: $ddayTarget, ddayReference: $ddayReference, ddayRefIsToday: $ddayRefIsToday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DateCalculatorStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.includeStartDay, includeStartDay) ||
                other.includeStartDay == includeStartDay) &&
            (identical(other.calcBase, calcBase) ||
                other.calcBase == calcBase) &&
            (identical(other.calcNumberInput, calcNumberInput) ||
                other.calcNumberInput == calcNumberInput) &&
            (identical(other.calcDirection, calcDirection) ||
                other.calcDirection == calcDirection) &&
            (identical(other.calcUnit, calcUnit) ||
                other.calcUnit == calcUnit) &&
            (identical(other.ddayTarget, ddayTarget) ||
                other.ddayTarget == ddayTarget) &&
            (identical(other.ddayReference, ddayReference) ||
                other.ddayReference == ddayReference) &&
            (identical(other.ddayRefIsToday, ddayRefIsToday) ||
                other.ddayRefIsToday == ddayRefIsToday));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    periodStart,
    periodEnd,
    includeStartDay,
    calcBase,
    calcNumberInput,
    calcDirection,
    calcUnit,
    ddayTarget,
    ddayReference,
    ddayRefIsToday,
  );

  /// Create a copy of DateCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DateCalculatorStateImplCopyWith<_$DateCalculatorStateImpl> get copyWith =>
      __$$DateCalculatorStateImplCopyWithImpl<_$DateCalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DateCalculatorState implements DateCalculatorState {
  const factory _DateCalculatorState({
    final int mode,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    final bool includeStartDay,
    required final DateTime calcBase,
    final String calcNumberInput,
    final int calcDirection,
    final int calcUnit,
    required final DateTime ddayTarget,
    required final DateTime ddayReference,
    final bool ddayRefIsToday,
  }) = _$DateCalculatorStateImpl;

  @override
  int get mode; // 모드 0: 기간 계산
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  bool get includeStartDay; // 모드 1: 날짜 계산
  @override
  DateTime get calcBase;
  @override
  String get calcNumberInput;
  @override
  int get calcDirection; // 0=더하기, 1=빼기
  @override
  int get calcUnit; // 0=일, 1=주, 2=월, 3=년
  // 모드 2: D-Day
  @override
  DateTime get ddayTarget;
  @override
  DateTime get ddayReference;
  @override
  bool get ddayRefIsToday;

  /// Create a copy of DateCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DateCalculatorStateImplCopyWith<_$DateCalculatorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
