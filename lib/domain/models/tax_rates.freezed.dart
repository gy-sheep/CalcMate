// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_rates.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaxRates _$TaxRatesFromJson(Map<String, dynamic> json) {
  return _TaxRates.fromJson(json);
}

/// @nodoc
mixin _$TaxRates {
  double get nationalPensionRate => throw _privateConstructorUsedError;
  int get nationalPensionMin => throw _privateConstructorUsedError;
  int get nationalPensionMax => throw _privateConstructorUsedError;
  double get healthInsuranceRate => throw _privateConstructorUsedError;
  double get longTermCareRate => throw _privateConstructorUsedError;
  double get employmentInsuranceRate => throw _privateConstructorUsedError;
  int get basedYear => throw _privateConstructorUsedError;
  int? get basedHalf => throw _privateConstructorUsedError;
  List<IncomeTaxBracket>? get incomeTaxTable =>
      throw _privateConstructorUsedError;
  List<OverTenMillionBracket>? get overTenMillionBrackets =>
      throw _privateConstructorUsedError;
  ChildTaxCredit? get childTaxCredit => throw _privateConstructorUsedError;

  /// Serializes this TaxRates to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxRatesCopyWith<TaxRates> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxRatesCopyWith<$Res> {
  factory $TaxRatesCopyWith(TaxRates value, $Res Function(TaxRates) then) =
      _$TaxRatesCopyWithImpl<$Res, TaxRates>;
  @useResult
  $Res call({
    double nationalPensionRate,
    int nationalPensionMin,
    int nationalPensionMax,
    double healthInsuranceRate,
    double longTermCareRate,
    double employmentInsuranceRate,
    int basedYear,
    int? basedHalf,
    List<IncomeTaxBracket>? incomeTaxTable,
    List<OverTenMillionBracket>? overTenMillionBrackets,
    ChildTaxCredit? childTaxCredit,
  });

  $ChildTaxCreditCopyWith<$Res>? get childTaxCredit;
}

/// @nodoc
class _$TaxRatesCopyWithImpl<$Res, $Val extends TaxRates>
    implements $TaxRatesCopyWith<$Res> {
  _$TaxRatesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nationalPensionRate = null,
    Object? nationalPensionMin = null,
    Object? nationalPensionMax = null,
    Object? healthInsuranceRate = null,
    Object? longTermCareRate = null,
    Object? employmentInsuranceRate = null,
    Object? basedYear = null,
    Object? basedHalf = freezed,
    Object? incomeTaxTable = freezed,
    Object? overTenMillionBrackets = freezed,
    Object? childTaxCredit = freezed,
  }) {
    return _then(
      _value.copyWith(
            nationalPensionRate: null == nationalPensionRate
                ? _value.nationalPensionRate
                : nationalPensionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            nationalPensionMin: null == nationalPensionMin
                ? _value.nationalPensionMin
                : nationalPensionMin // ignore: cast_nullable_to_non_nullable
                      as int,
            nationalPensionMax: null == nationalPensionMax
                ? _value.nationalPensionMax
                : nationalPensionMax // ignore: cast_nullable_to_non_nullable
                      as int,
            healthInsuranceRate: null == healthInsuranceRate
                ? _value.healthInsuranceRate
                : healthInsuranceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            longTermCareRate: null == longTermCareRate
                ? _value.longTermCareRate
                : longTermCareRate // ignore: cast_nullable_to_non_nullable
                      as double,
            employmentInsuranceRate: null == employmentInsuranceRate
                ? _value.employmentInsuranceRate
                : employmentInsuranceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            basedYear: null == basedYear
                ? _value.basedYear
                : basedYear // ignore: cast_nullable_to_non_nullable
                      as int,
            basedHalf: freezed == basedHalf
                ? _value.basedHalf
                : basedHalf // ignore: cast_nullable_to_non_nullable
                      as int?,
            incomeTaxTable: freezed == incomeTaxTable
                ? _value.incomeTaxTable
                : incomeTaxTable // ignore: cast_nullable_to_non_nullable
                      as List<IncomeTaxBracket>?,
            overTenMillionBrackets: freezed == overTenMillionBrackets
                ? _value.overTenMillionBrackets
                : overTenMillionBrackets // ignore: cast_nullable_to_non_nullable
                      as List<OverTenMillionBracket>?,
            childTaxCredit: freezed == childTaxCredit
                ? _value.childTaxCredit
                : childTaxCredit // ignore: cast_nullable_to_non_nullable
                      as ChildTaxCredit?,
          )
          as $Val,
    );
  }

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChildTaxCreditCopyWith<$Res>? get childTaxCredit {
    if (_value.childTaxCredit == null) {
      return null;
    }

    return $ChildTaxCreditCopyWith<$Res>(_value.childTaxCredit!, (value) {
      return _then(_value.copyWith(childTaxCredit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaxRatesImplCopyWith<$Res>
    implements $TaxRatesCopyWith<$Res> {
  factory _$$TaxRatesImplCopyWith(
    _$TaxRatesImpl value,
    $Res Function(_$TaxRatesImpl) then,
  ) = __$$TaxRatesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double nationalPensionRate,
    int nationalPensionMin,
    int nationalPensionMax,
    double healthInsuranceRate,
    double longTermCareRate,
    double employmentInsuranceRate,
    int basedYear,
    int? basedHalf,
    List<IncomeTaxBracket>? incomeTaxTable,
    List<OverTenMillionBracket>? overTenMillionBrackets,
    ChildTaxCredit? childTaxCredit,
  });

  @override
  $ChildTaxCreditCopyWith<$Res>? get childTaxCredit;
}

/// @nodoc
class __$$TaxRatesImplCopyWithImpl<$Res>
    extends _$TaxRatesCopyWithImpl<$Res, _$TaxRatesImpl>
    implements _$$TaxRatesImplCopyWith<$Res> {
  __$$TaxRatesImplCopyWithImpl(
    _$TaxRatesImpl _value,
    $Res Function(_$TaxRatesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nationalPensionRate = null,
    Object? nationalPensionMin = null,
    Object? nationalPensionMax = null,
    Object? healthInsuranceRate = null,
    Object? longTermCareRate = null,
    Object? employmentInsuranceRate = null,
    Object? basedYear = null,
    Object? basedHalf = freezed,
    Object? incomeTaxTable = freezed,
    Object? overTenMillionBrackets = freezed,
    Object? childTaxCredit = freezed,
  }) {
    return _then(
      _$TaxRatesImpl(
        nationalPensionRate: null == nationalPensionRate
            ? _value.nationalPensionRate
            : nationalPensionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        nationalPensionMin: null == nationalPensionMin
            ? _value.nationalPensionMin
            : nationalPensionMin // ignore: cast_nullable_to_non_nullable
                  as int,
        nationalPensionMax: null == nationalPensionMax
            ? _value.nationalPensionMax
            : nationalPensionMax // ignore: cast_nullable_to_non_nullable
                  as int,
        healthInsuranceRate: null == healthInsuranceRate
            ? _value.healthInsuranceRate
            : healthInsuranceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        longTermCareRate: null == longTermCareRate
            ? _value.longTermCareRate
            : longTermCareRate // ignore: cast_nullable_to_non_nullable
                  as double,
        employmentInsuranceRate: null == employmentInsuranceRate
            ? _value.employmentInsuranceRate
            : employmentInsuranceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        basedYear: null == basedYear
            ? _value.basedYear
            : basedYear // ignore: cast_nullable_to_non_nullable
                  as int,
        basedHalf: freezed == basedHalf
            ? _value.basedHalf
            : basedHalf // ignore: cast_nullable_to_non_nullable
                  as int?,
        incomeTaxTable: freezed == incomeTaxTable
            ? _value._incomeTaxTable
            : incomeTaxTable // ignore: cast_nullable_to_non_nullable
                  as List<IncomeTaxBracket>?,
        overTenMillionBrackets: freezed == overTenMillionBrackets
            ? _value._overTenMillionBrackets
            : overTenMillionBrackets // ignore: cast_nullable_to_non_nullable
                  as List<OverTenMillionBracket>?,
        childTaxCredit: freezed == childTaxCredit
            ? _value.childTaxCredit
            : childTaxCredit // ignore: cast_nullable_to_non_nullable
                  as ChildTaxCredit?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaxRatesImpl implements _TaxRates {
  const _$TaxRatesImpl({
    required this.nationalPensionRate,
    required this.nationalPensionMin,
    required this.nationalPensionMax,
    required this.healthInsuranceRate,
    required this.longTermCareRate,
    required this.employmentInsuranceRate,
    required this.basedYear,
    this.basedHalf,
    final List<IncomeTaxBracket>? incomeTaxTable,
    final List<OverTenMillionBracket>? overTenMillionBrackets,
    this.childTaxCredit,
  }) : _incomeTaxTable = incomeTaxTable,
       _overTenMillionBrackets = overTenMillionBrackets;

  factory _$TaxRatesImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaxRatesImplFromJson(json);

  @override
  final double nationalPensionRate;
  @override
  final int nationalPensionMin;
  @override
  final int nationalPensionMax;
  @override
  final double healthInsuranceRate;
  @override
  final double longTermCareRate;
  @override
  final double employmentInsuranceRate;
  @override
  final int basedYear;
  @override
  final int? basedHalf;
  final List<IncomeTaxBracket>? _incomeTaxTable;
  @override
  List<IncomeTaxBracket>? get incomeTaxTable {
    final value = _incomeTaxTable;
    if (value == null) return null;
    if (_incomeTaxTable is EqualUnmodifiableListView) return _incomeTaxTable;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<OverTenMillionBracket>? _overTenMillionBrackets;
  @override
  List<OverTenMillionBracket>? get overTenMillionBrackets {
    final value = _overTenMillionBrackets;
    if (value == null) return null;
    if (_overTenMillionBrackets is EqualUnmodifiableListView)
      return _overTenMillionBrackets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final ChildTaxCredit? childTaxCredit;

  @override
  String toString() {
    return 'TaxRates(nationalPensionRate: $nationalPensionRate, nationalPensionMin: $nationalPensionMin, nationalPensionMax: $nationalPensionMax, healthInsuranceRate: $healthInsuranceRate, longTermCareRate: $longTermCareRate, employmentInsuranceRate: $employmentInsuranceRate, basedYear: $basedYear, basedHalf: $basedHalf, incomeTaxTable: $incomeTaxTable, overTenMillionBrackets: $overTenMillionBrackets, childTaxCredit: $childTaxCredit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxRatesImpl &&
            (identical(other.nationalPensionRate, nationalPensionRate) ||
                other.nationalPensionRate == nationalPensionRate) &&
            (identical(other.nationalPensionMin, nationalPensionMin) ||
                other.nationalPensionMin == nationalPensionMin) &&
            (identical(other.nationalPensionMax, nationalPensionMax) ||
                other.nationalPensionMax == nationalPensionMax) &&
            (identical(other.healthInsuranceRate, healthInsuranceRate) ||
                other.healthInsuranceRate == healthInsuranceRate) &&
            (identical(other.longTermCareRate, longTermCareRate) ||
                other.longTermCareRate == longTermCareRate) &&
            (identical(
                  other.employmentInsuranceRate,
                  employmentInsuranceRate,
                ) ||
                other.employmentInsuranceRate == employmentInsuranceRate) &&
            (identical(other.basedYear, basedYear) ||
                other.basedYear == basedYear) &&
            (identical(other.basedHalf, basedHalf) ||
                other.basedHalf == basedHalf) &&
            const DeepCollectionEquality().equals(
              other._incomeTaxTable,
              _incomeTaxTable,
            ) &&
            const DeepCollectionEquality().equals(
              other._overTenMillionBrackets,
              _overTenMillionBrackets,
            ) &&
            (identical(other.childTaxCredit, childTaxCredit) ||
                other.childTaxCredit == childTaxCredit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    nationalPensionRate,
    nationalPensionMin,
    nationalPensionMax,
    healthInsuranceRate,
    longTermCareRate,
    employmentInsuranceRate,
    basedYear,
    basedHalf,
    const DeepCollectionEquality().hash(_incomeTaxTable),
    const DeepCollectionEquality().hash(_overTenMillionBrackets),
    childTaxCredit,
  );

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxRatesImplCopyWith<_$TaxRatesImpl> get copyWith =>
      __$$TaxRatesImplCopyWithImpl<_$TaxRatesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaxRatesImplToJson(this);
  }
}

abstract class _TaxRates implements TaxRates {
  const factory _TaxRates({
    required final double nationalPensionRate,
    required final int nationalPensionMin,
    required final int nationalPensionMax,
    required final double healthInsuranceRate,
    required final double longTermCareRate,
    required final double employmentInsuranceRate,
    required final int basedYear,
    final int? basedHalf,
    final List<IncomeTaxBracket>? incomeTaxTable,
    final List<OverTenMillionBracket>? overTenMillionBrackets,
    final ChildTaxCredit? childTaxCredit,
  }) = _$TaxRatesImpl;

  factory _TaxRates.fromJson(Map<String, dynamic> json) =
      _$TaxRatesImpl.fromJson;

  @override
  double get nationalPensionRate;
  @override
  int get nationalPensionMin;
  @override
  int get nationalPensionMax;
  @override
  double get healthInsuranceRate;
  @override
  double get longTermCareRate;
  @override
  double get employmentInsuranceRate;
  @override
  int get basedYear;
  @override
  int? get basedHalf;
  @override
  List<IncomeTaxBracket>? get incomeTaxTable;
  @override
  List<OverTenMillionBracket>? get overTenMillionBrackets;
  @override
  ChildTaxCredit? get childTaxCredit;

  /// Create a copy of TaxRates
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxRatesImplCopyWith<_$TaxRatesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IncomeTaxBracket _$IncomeTaxBracketFromJson(Map<String, dynamic> json) {
  return _IncomeTaxBracket.fromJson(json);
}

/// @nodoc
mixin _$IncomeTaxBracket {
  int get min => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;
  List<int> get taxes => throw _privateConstructorUsedError;

  /// Serializes this IncomeTaxBracket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IncomeTaxBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncomeTaxBracketCopyWith<IncomeTaxBracket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeTaxBracketCopyWith<$Res> {
  factory $IncomeTaxBracketCopyWith(
    IncomeTaxBracket value,
    $Res Function(IncomeTaxBracket) then,
  ) = _$IncomeTaxBracketCopyWithImpl<$Res, IncomeTaxBracket>;
  @useResult
  $Res call({int min, int max, List<int> taxes});
}

/// @nodoc
class _$IncomeTaxBracketCopyWithImpl<$Res, $Val extends IncomeTaxBracket>
    implements $IncomeTaxBracketCopyWith<$Res> {
  _$IncomeTaxBracketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncomeTaxBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null, Object? taxes = null}) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
            taxes: null == taxes
                ? _value.taxes
                : taxes // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IncomeTaxBracketImplCopyWith<$Res>
    implements $IncomeTaxBracketCopyWith<$Res> {
  factory _$$IncomeTaxBracketImplCopyWith(
    _$IncomeTaxBracketImpl value,
    $Res Function(_$IncomeTaxBracketImpl) then,
  ) = __$$IncomeTaxBracketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int min, int max, List<int> taxes});
}

/// @nodoc
class __$$IncomeTaxBracketImplCopyWithImpl<$Res>
    extends _$IncomeTaxBracketCopyWithImpl<$Res, _$IncomeTaxBracketImpl>
    implements _$$IncomeTaxBracketImplCopyWith<$Res> {
  __$$IncomeTaxBracketImplCopyWithImpl(
    _$IncomeTaxBracketImpl _value,
    $Res Function(_$IncomeTaxBracketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncomeTaxBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null, Object? taxes = null}) {
    return _then(
      _$IncomeTaxBracketImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
        taxes: null == taxes
            ? _value._taxes
            : taxes // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IncomeTaxBracketImpl implements _IncomeTaxBracket {
  const _$IncomeTaxBracketImpl({
    required this.min,
    required this.max,
    required final List<int> taxes,
  }) : _taxes = taxes;

  factory _$IncomeTaxBracketImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeTaxBracketImplFromJson(json);

  @override
  final int min;
  @override
  final int max;
  final List<int> _taxes;
  @override
  List<int> get taxes {
    if (_taxes is EqualUnmodifiableListView) return _taxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taxes);
  }

  @override
  String toString() {
    return 'IncomeTaxBracket(min: $min, max: $max, taxes: $taxes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeTaxBracketImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            const DeepCollectionEquality().equals(other._taxes, _taxes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    min,
    max,
    const DeepCollectionEquality().hash(_taxes),
  );

  /// Create a copy of IncomeTaxBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeTaxBracketImplCopyWith<_$IncomeTaxBracketImpl> get copyWith =>
      __$$IncomeTaxBracketImplCopyWithImpl<_$IncomeTaxBracketImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeTaxBracketImplToJson(this);
  }
}

abstract class _IncomeTaxBracket implements IncomeTaxBracket {
  const factory _IncomeTaxBracket({
    required final int min,
    required final int max,
    required final List<int> taxes,
  }) = _$IncomeTaxBracketImpl;

  factory _IncomeTaxBracket.fromJson(Map<String, dynamic> json) =
      _$IncomeTaxBracketImpl.fromJson;

  @override
  int get min;
  @override
  int get max;
  @override
  List<int> get taxes;

  /// Create a copy of IncomeTaxBracket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomeTaxBracketImplCopyWith<_$IncomeTaxBracketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OverTenMillionBracket _$OverTenMillionBracketFromJson(
  Map<String, dynamic> json,
) {
  return _OverTenMillionBracket.fromJson(json);
}

/// @nodoc
mixin _$OverTenMillionBracket {
  int get min => throw _privateConstructorUsedError;
  int get max => throw _privateConstructorUsedError;
  int get baseAdd => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  double get applyRatio => throw _privateConstructorUsedError;
  int get excessFrom => throw _privateConstructorUsedError;

  /// Serializes this OverTenMillionBracket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OverTenMillionBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OverTenMillionBracketCopyWith<OverTenMillionBracket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OverTenMillionBracketCopyWith<$Res> {
  factory $OverTenMillionBracketCopyWith(
    OverTenMillionBracket value,
    $Res Function(OverTenMillionBracket) then,
  ) = _$OverTenMillionBracketCopyWithImpl<$Res, OverTenMillionBracket>;
  @useResult
  $Res call({
    int min,
    int max,
    int baseAdd,
    double rate,
    double applyRatio,
    int excessFrom,
  });
}

/// @nodoc
class _$OverTenMillionBracketCopyWithImpl<
  $Res,
  $Val extends OverTenMillionBracket
>
    implements $OverTenMillionBracketCopyWith<$Res> {
  _$OverTenMillionBracketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OverTenMillionBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? baseAdd = null,
    Object? rate = null,
    Object? applyRatio = null,
    Object? excessFrom = null,
  }) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
            baseAdd: null == baseAdd
                ? _value.baseAdd
                : baseAdd // ignore: cast_nullable_to_non_nullable
                      as int,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            applyRatio: null == applyRatio
                ? _value.applyRatio
                : applyRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            excessFrom: null == excessFrom
                ? _value.excessFrom
                : excessFrom // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OverTenMillionBracketImplCopyWith<$Res>
    implements $OverTenMillionBracketCopyWith<$Res> {
  factory _$$OverTenMillionBracketImplCopyWith(
    _$OverTenMillionBracketImpl value,
    $Res Function(_$OverTenMillionBracketImpl) then,
  ) = __$$OverTenMillionBracketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int min,
    int max,
    int baseAdd,
    double rate,
    double applyRatio,
    int excessFrom,
  });
}

/// @nodoc
class __$$OverTenMillionBracketImplCopyWithImpl<$Res>
    extends
        _$OverTenMillionBracketCopyWithImpl<$Res, _$OverTenMillionBracketImpl>
    implements _$$OverTenMillionBracketImplCopyWith<$Res> {
  __$$OverTenMillionBracketImplCopyWithImpl(
    _$OverTenMillionBracketImpl _value,
    $Res Function(_$OverTenMillionBracketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OverTenMillionBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? baseAdd = null,
    Object? rate = null,
    Object? applyRatio = null,
    Object? excessFrom = null,
  }) {
    return _then(
      _$OverTenMillionBracketImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
        baseAdd: null == baseAdd
            ? _value.baseAdd
            : baseAdd // ignore: cast_nullable_to_non_nullable
                  as int,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        applyRatio: null == applyRatio
            ? _value.applyRatio
            : applyRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        excessFrom: null == excessFrom
            ? _value.excessFrom
            : excessFrom // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OverTenMillionBracketImpl implements _OverTenMillionBracket {
  const _$OverTenMillionBracketImpl({
    required this.min,
    required this.max,
    required this.baseAdd,
    required this.rate,
    required this.applyRatio,
    required this.excessFrom,
  });

  factory _$OverTenMillionBracketImpl.fromJson(Map<String, dynamic> json) =>
      _$$OverTenMillionBracketImplFromJson(json);

  @override
  final int min;
  @override
  final int max;
  @override
  final int baseAdd;
  @override
  final double rate;
  @override
  final double applyRatio;
  @override
  final int excessFrom;

  @override
  String toString() {
    return 'OverTenMillionBracket(min: $min, max: $max, baseAdd: $baseAdd, rate: $rate, applyRatio: $applyRatio, excessFrom: $excessFrom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OverTenMillionBracketImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.baseAdd, baseAdd) || other.baseAdd == baseAdd) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.applyRatio, applyRatio) ||
                other.applyRatio == applyRatio) &&
            (identical(other.excessFrom, excessFrom) ||
                other.excessFrom == excessFrom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, min, max, baseAdd, rate, applyRatio, excessFrom);

  /// Create a copy of OverTenMillionBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OverTenMillionBracketImplCopyWith<_$OverTenMillionBracketImpl>
  get copyWith =>
      __$$OverTenMillionBracketImplCopyWithImpl<_$OverTenMillionBracketImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OverTenMillionBracketImplToJson(this);
  }
}

abstract class _OverTenMillionBracket implements OverTenMillionBracket {
  const factory _OverTenMillionBracket({
    required final int min,
    required final int max,
    required final int baseAdd,
    required final double rate,
    required final double applyRatio,
    required final int excessFrom,
  }) = _$OverTenMillionBracketImpl;

  factory _OverTenMillionBracket.fromJson(Map<String, dynamic> json) =
      _$OverTenMillionBracketImpl.fromJson;

  @override
  int get min;
  @override
  int get max;
  @override
  int get baseAdd;
  @override
  double get rate;
  @override
  double get applyRatio;
  @override
  int get excessFrom;

  /// Create a copy of OverTenMillionBracket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OverTenMillionBracketImplCopyWith<_$OverTenMillionBracketImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ChildTaxCredit _$ChildTaxCreditFromJson(Map<String, dynamic> json) {
  return _ChildTaxCredit.fromJson(json);
}

/// @nodoc
mixin _$ChildTaxCredit {
  int get one => throw _privateConstructorUsedError;
  int get two => throw _privateConstructorUsedError;
  int get perExtra => throw _privateConstructorUsedError;

  /// Serializes this ChildTaxCredit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChildTaxCredit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChildTaxCreditCopyWith<ChildTaxCredit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildTaxCreditCopyWith<$Res> {
  factory $ChildTaxCreditCopyWith(
    ChildTaxCredit value,
    $Res Function(ChildTaxCredit) then,
  ) = _$ChildTaxCreditCopyWithImpl<$Res, ChildTaxCredit>;
  @useResult
  $Res call({int one, int two, int perExtra});
}

/// @nodoc
class _$ChildTaxCreditCopyWithImpl<$Res, $Val extends ChildTaxCredit>
    implements $ChildTaxCreditCopyWith<$Res> {
  _$ChildTaxCreditCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChildTaxCredit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? one = null, Object? two = null, Object? perExtra = null}) {
    return _then(
      _value.copyWith(
            one: null == one
                ? _value.one
                : one // ignore: cast_nullable_to_non_nullable
                      as int,
            two: null == two
                ? _value.two
                : two // ignore: cast_nullable_to_non_nullable
                      as int,
            perExtra: null == perExtra
                ? _value.perExtra
                : perExtra // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChildTaxCreditImplCopyWith<$Res>
    implements $ChildTaxCreditCopyWith<$Res> {
  factory _$$ChildTaxCreditImplCopyWith(
    _$ChildTaxCreditImpl value,
    $Res Function(_$ChildTaxCreditImpl) then,
  ) = __$$ChildTaxCreditImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int one, int two, int perExtra});
}

/// @nodoc
class __$$ChildTaxCreditImplCopyWithImpl<$Res>
    extends _$ChildTaxCreditCopyWithImpl<$Res, _$ChildTaxCreditImpl>
    implements _$$ChildTaxCreditImplCopyWith<$Res> {
  __$$ChildTaxCreditImplCopyWithImpl(
    _$ChildTaxCreditImpl _value,
    $Res Function(_$ChildTaxCreditImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChildTaxCredit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? one = null, Object? two = null, Object? perExtra = null}) {
    return _then(
      _$ChildTaxCreditImpl(
        one: null == one
            ? _value.one
            : one // ignore: cast_nullable_to_non_nullable
                  as int,
        two: null == two
            ? _value.two
            : two // ignore: cast_nullable_to_non_nullable
                  as int,
        perExtra: null == perExtra
            ? _value.perExtra
            : perExtra // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChildTaxCreditImpl implements _ChildTaxCredit {
  const _$ChildTaxCreditImpl({
    required this.one,
    required this.two,
    required this.perExtra,
  });

  factory _$ChildTaxCreditImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChildTaxCreditImplFromJson(json);

  @override
  final int one;
  @override
  final int two;
  @override
  final int perExtra;

  @override
  String toString() {
    return 'ChildTaxCredit(one: $one, two: $two, perExtra: $perExtra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildTaxCreditImpl &&
            (identical(other.one, one) || other.one == one) &&
            (identical(other.two, two) || other.two == two) &&
            (identical(other.perExtra, perExtra) ||
                other.perExtra == perExtra));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, one, two, perExtra);

  /// Create a copy of ChildTaxCredit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildTaxCreditImplCopyWith<_$ChildTaxCreditImpl> get copyWith =>
      __$$ChildTaxCreditImplCopyWithImpl<_$ChildTaxCreditImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChildTaxCreditImplToJson(this);
  }
}

abstract class _ChildTaxCredit implements ChildTaxCredit {
  const factory _ChildTaxCredit({
    required final int one,
    required final int two,
    required final int perExtra,
  }) = _$ChildTaxCreditImpl;

  factory _ChildTaxCredit.fromJson(Map<String, dynamic> json) =
      _$ChildTaxCreditImpl.fromJson;

  @override
  int get one;
  @override
  int get two;
  @override
  int get perExtra;

  /// Create a copy of ChildTaxCredit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChildTaxCreditImplCopyWith<_$ChildTaxCreditImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
