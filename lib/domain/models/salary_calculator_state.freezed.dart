// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'salary_calculator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalaryCalculatorState {
  SalaryMode get mode => throw _privateConstructorUsedError;
  int get salary => throw _privateConstructorUsedError;
  int get dependents => throw _privateConstructorUsedError; // 계산 결과
  int get nationalPension => throw _privateConstructorUsedError;
  int get healthInsurance => throw _privateConstructorUsedError;
  int get longTermCare => throw _privateConstructorUsedError;
  int get employmentInsurance => throw _privateConstructorUsedError;
  int get incomeTax => throw _privateConstructorUsedError;
  int get localTax => throw _privateConstructorUsedError; // 세율 기준 정보
  bool get isLoading => throw _privateConstructorUsedError;
  int get basedYear => throw _privateConstructorUsedError;
  int? get basedHalf => throw _privateConstructorUsedError;

  /// Create a copy of SalaryCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalaryCalculatorStateCopyWith<SalaryCalculatorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalaryCalculatorStateCopyWith<$Res> {
  factory $SalaryCalculatorStateCopyWith(
    SalaryCalculatorState value,
    $Res Function(SalaryCalculatorState) then,
  ) = _$SalaryCalculatorStateCopyWithImpl<$Res, SalaryCalculatorState>;
  @useResult
  $Res call({
    SalaryMode mode,
    int salary,
    int dependents,
    int nationalPension,
    int healthInsurance,
    int longTermCare,
    int employmentInsurance,
    int incomeTax,
    int localTax,
    bool isLoading,
    int basedYear,
    int? basedHalf,
  });
}

/// @nodoc
class _$SalaryCalculatorStateCopyWithImpl<
  $Res,
  $Val extends SalaryCalculatorState
>
    implements $SalaryCalculatorStateCopyWith<$Res> {
  _$SalaryCalculatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalaryCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? salary = null,
    Object? dependents = null,
    Object? nationalPension = null,
    Object? healthInsurance = null,
    Object? longTermCare = null,
    Object? employmentInsurance = null,
    Object? incomeTax = null,
    Object? localTax = null,
    Object? isLoading = null,
    Object? basedYear = null,
    Object? basedHalf = freezed,
  }) {
    return _then(
      _value.copyWith(
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as SalaryMode,
            salary: null == salary
                ? _value.salary
                : salary // ignore: cast_nullable_to_non_nullable
                      as int,
            dependents: null == dependents
                ? _value.dependents
                : dependents // ignore: cast_nullable_to_non_nullable
                      as int,
            nationalPension: null == nationalPension
                ? _value.nationalPension
                : nationalPension // ignore: cast_nullable_to_non_nullable
                      as int,
            healthInsurance: null == healthInsurance
                ? _value.healthInsurance
                : healthInsurance // ignore: cast_nullable_to_non_nullable
                      as int,
            longTermCare: null == longTermCare
                ? _value.longTermCare
                : longTermCare // ignore: cast_nullable_to_non_nullable
                      as int,
            employmentInsurance: null == employmentInsurance
                ? _value.employmentInsurance
                : employmentInsurance // ignore: cast_nullable_to_non_nullable
                      as int,
            incomeTax: null == incomeTax
                ? _value.incomeTax
                : incomeTax // ignore: cast_nullable_to_non_nullable
                      as int,
            localTax: null == localTax
                ? _value.localTax
                : localTax // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            basedYear: null == basedYear
                ? _value.basedYear
                : basedYear // ignore: cast_nullable_to_non_nullable
                      as int,
            basedHalf: freezed == basedHalf
                ? _value.basedHalf
                : basedHalf // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalaryCalculatorStateImplCopyWith<$Res>
    implements $SalaryCalculatorStateCopyWith<$Res> {
  factory _$$SalaryCalculatorStateImplCopyWith(
    _$SalaryCalculatorStateImpl value,
    $Res Function(_$SalaryCalculatorStateImpl) then,
  ) = __$$SalaryCalculatorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SalaryMode mode,
    int salary,
    int dependents,
    int nationalPension,
    int healthInsurance,
    int longTermCare,
    int employmentInsurance,
    int incomeTax,
    int localTax,
    bool isLoading,
    int basedYear,
    int? basedHalf,
  });
}

/// @nodoc
class __$$SalaryCalculatorStateImplCopyWithImpl<$Res>
    extends
        _$SalaryCalculatorStateCopyWithImpl<$Res, _$SalaryCalculatorStateImpl>
    implements _$$SalaryCalculatorStateImplCopyWith<$Res> {
  __$$SalaryCalculatorStateImplCopyWithImpl(
    _$SalaryCalculatorStateImpl _value,
    $Res Function(_$SalaryCalculatorStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalaryCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? salary = null,
    Object? dependents = null,
    Object? nationalPension = null,
    Object? healthInsurance = null,
    Object? longTermCare = null,
    Object? employmentInsurance = null,
    Object? incomeTax = null,
    Object? localTax = null,
    Object? isLoading = null,
    Object? basedYear = null,
    Object? basedHalf = freezed,
  }) {
    return _then(
      _$SalaryCalculatorStateImpl(
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as SalaryMode,
        salary: null == salary
            ? _value.salary
            : salary // ignore: cast_nullable_to_non_nullable
                  as int,
        dependents: null == dependents
            ? _value.dependents
            : dependents // ignore: cast_nullable_to_non_nullable
                  as int,
        nationalPension: null == nationalPension
            ? _value.nationalPension
            : nationalPension // ignore: cast_nullable_to_non_nullable
                  as int,
        healthInsurance: null == healthInsurance
            ? _value.healthInsurance
            : healthInsurance // ignore: cast_nullable_to_non_nullable
                  as int,
        longTermCare: null == longTermCare
            ? _value.longTermCare
            : longTermCare // ignore: cast_nullable_to_non_nullable
                  as int,
        employmentInsurance: null == employmentInsurance
            ? _value.employmentInsurance
            : employmentInsurance // ignore: cast_nullable_to_non_nullable
                  as int,
        incomeTax: null == incomeTax
            ? _value.incomeTax
            : incomeTax // ignore: cast_nullable_to_non_nullable
                  as int,
        localTax: null == localTax
            ? _value.localTax
            : localTax // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        basedYear: null == basedYear
            ? _value.basedYear
            : basedYear // ignore: cast_nullable_to_non_nullable
                  as int,
        basedHalf: freezed == basedHalf
            ? _value.basedHalf
            : basedHalf // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$SalaryCalculatorStateImpl implements _SalaryCalculatorState {
  const _$SalaryCalculatorStateImpl({
    this.mode = SalaryMode.monthly,
    this.salary = 3000000,
    this.dependents = 1,
    this.nationalPension = 0,
    this.healthInsurance = 0,
    this.longTermCare = 0,
    this.employmentInsurance = 0,
    this.incomeTax = 0,
    this.localTax = 0,
    this.isLoading = false,
    this.basedYear = 0,
    this.basedHalf,
  });

  @override
  @JsonKey()
  final SalaryMode mode;
  @override
  @JsonKey()
  final int salary;
  @override
  @JsonKey()
  final int dependents;
  // 계산 결과
  @override
  @JsonKey()
  final int nationalPension;
  @override
  @JsonKey()
  final int healthInsurance;
  @override
  @JsonKey()
  final int longTermCare;
  @override
  @JsonKey()
  final int employmentInsurance;
  @override
  @JsonKey()
  final int incomeTax;
  @override
  @JsonKey()
  final int localTax;
  // 세율 기준 정보
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int basedYear;
  @override
  final int? basedHalf;

  @override
  String toString() {
    return 'SalaryCalculatorState(mode: $mode, salary: $salary, dependents: $dependents, nationalPension: $nationalPension, healthInsurance: $healthInsurance, longTermCare: $longTermCare, employmentInsurance: $employmentInsurance, incomeTax: $incomeTax, localTax: $localTax, isLoading: $isLoading, basedYear: $basedYear, basedHalf: $basedHalf)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalaryCalculatorStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.salary, salary) || other.salary == salary) &&
            (identical(other.dependents, dependents) ||
                other.dependents == dependents) &&
            (identical(other.nationalPension, nationalPension) ||
                other.nationalPension == nationalPension) &&
            (identical(other.healthInsurance, healthInsurance) ||
                other.healthInsurance == healthInsurance) &&
            (identical(other.longTermCare, longTermCare) ||
                other.longTermCare == longTermCare) &&
            (identical(other.employmentInsurance, employmentInsurance) ||
                other.employmentInsurance == employmentInsurance) &&
            (identical(other.incomeTax, incomeTax) ||
                other.incomeTax == incomeTax) &&
            (identical(other.localTax, localTax) ||
                other.localTax == localTax) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.basedYear, basedYear) ||
                other.basedYear == basedYear) &&
            (identical(other.basedHalf, basedHalf) ||
                other.basedHalf == basedHalf));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    salary,
    dependents,
    nationalPension,
    healthInsurance,
    longTermCare,
    employmentInsurance,
    incomeTax,
    localTax,
    isLoading,
    basedYear,
    basedHalf,
  );

  /// Create a copy of SalaryCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalaryCalculatorStateImplCopyWith<_$SalaryCalculatorStateImpl>
  get copyWith =>
      __$$SalaryCalculatorStateImplCopyWithImpl<_$SalaryCalculatorStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SalaryCalculatorState implements SalaryCalculatorState {
  const factory _SalaryCalculatorState({
    final SalaryMode mode,
    final int salary,
    final int dependents,
    final int nationalPension,
    final int healthInsurance,
    final int longTermCare,
    final int employmentInsurance,
    final int incomeTax,
    final int localTax,
    final bool isLoading,
    final int basedYear,
    final int? basedHalf,
  }) = _$SalaryCalculatorStateImpl;

  @override
  SalaryMode get mode;
  @override
  int get salary;
  @override
  int get dependents; // 계산 결과
  @override
  int get nationalPension;
  @override
  int get healthInsurance;
  @override
  int get longTermCare;
  @override
  int get employmentInsurance;
  @override
  int get incomeTax;
  @override
  int get localTax; // 세율 기준 정보
  @override
  bool get isLoading;
  @override
  int get basedYear;
  @override
  int? get basedHalf;

  /// Create a copy of SalaryCalculatorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalaryCalculatorStateImplCopyWith<_$SalaryCalculatorStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
