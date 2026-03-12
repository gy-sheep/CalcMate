// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SettingsState {
  ThemeMode get themeMode => throw _privateConstructorUsedError;
  String? get appLanguage =>
      throw _privateConstructorUsedError; // 앱 표시 언어 코드 ('ko', 'en'), null = 시스템 기본
  CurrencyUnit? get displayCurrency =>
      throw _privateConstructorUsedError; // null = 자동(기기 지역)
  String? get baseCurrency => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
    SettingsState value,
    $Res Function(SettingsState) then,
  ) = _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call({
    ThemeMode themeMode,
    String? appLanguage,
    CurrencyUnit? displayCurrency,
    String? baseCurrency,
  });
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? appLanguage = freezed,
    Object? displayCurrency = freezed,
    Object? baseCurrency = freezed,
  }) {
    return _then(
      _value.copyWith(
            themeMode: null == themeMode
                ? _value.themeMode
                : themeMode // ignore: cast_nullable_to_non_nullable
                      as ThemeMode,
            appLanguage: freezed == appLanguage
                ? _value.appLanguage
                : appLanguage // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayCurrency: freezed == displayCurrency
                ? _value.displayCurrency
                : displayCurrency // ignore: cast_nullable_to_non_nullable
                      as CurrencyUnit?,
            baseCurrency: freezed == baseCurrency
                ? _value.baseCurrency
                : baseCurrency // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
    _$SettingsStateImpl value,
    $Res Function(_$SettingsStateImpl) then,
  ) = __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ThemeMode themeMode,
    String? appLanguage,
    CurrencyUnit? displayCurrency,
    String? baseCurrency,
  });
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
    _$SettingsStateImpl _value,
    $Res Function(_$SettingsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? appLanguage = freezed,
    Object? displayCurrency = freezed,
    Object? baseCurrency = freezed,
  }) {
    return _then(
      _$SettingsStateImpl(
        themeMode: null == themeMode
            ? _value.themeMode
            : themeMode // ignore: cast_nullable_to_non_nullable
                  as ThemeMode,
        appLanguage: freezed == appLanguage
            ? _value.appLanguage
            : appLanguage // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayCurrency: freezed == displayCurrency
            ? _value.displayCurrency
            : displayCurrency // ignore: cast_nullable_to_non_nullable
                  as CurrencyUnit?,
        baseCurrency: freezed == baseCurrency
            ? _value.baseCurrency
            : baseCurrency // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl({
    this.themeMode = ThemeMode.system,
    this.appLanguage,
    this.displayCurrency,
    this.baseCurrency,
  });

  @override
  @JsonKey()
  final ThemeMode themeMode;
  @override
  final String? appLanguage;
  // 앱 표시 언어 코드 ('ko', 'en'), null = 시스템 기본
  @override
  final CurrencyUnit? displayCurrency;
  // null = 자동(기기 지역)
  @override
  final String? baseCurrency;

  @override
  String toString() {
    return 'SettingsState(themeMode: $themeMode, appLanguage: $appLanguage, displayCurrency: $displayCurrency, baseCurrency: $baseCurrency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.appLanguage, appLanguage) ||
                other.appLanguage == appLanguage) &&
            (identical(other.displayCurrency, displayCurrency) ||
                other.displayCurrency == displayCurrency) &&
            (identical(other.baseCurrency, baseCurrency) ||
                other.baseCurrency == baseCurrency));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    themeMode,
    appLanguage,
    displayCurrency,
    baseCurrency,
  );

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState({
    final ThemeMode themeMode,
    final String? appLanguage,
    final CurrencyUnit? displayCurrency,
    final String? baseCurrency,
  }) = _$SettingsStateImpl;

  @override
  ThemeMode get themeMode;
  @override
  String? get appLanguage; // 앱 표시 언어 코드 ('ko', 'en'), null = 시스템 기본
  @override
  CurrencyUnit? get displayCurrency; // null = 자동(기기 지역)
  @override
  String? get baseCurrency;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
