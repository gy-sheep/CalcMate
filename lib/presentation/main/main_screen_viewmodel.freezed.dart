// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_screen_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MainScreenState {
  List<CalcModeEntry> get entries => throw _privateConstructorUsedError;
  bool get isScrolled => throw _privateConstructorUsedError;

  /// Create a copy of MainScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MainScreenStateCopyWith<MainScreenState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainScreenStateCopyWith<$Res> {
  factory $MainScreenStateCopyWith(
    MainScreenState value,
    $Res Function(MainScreenState) then,
  ) = _$MainScreenStateCopyWithImpl<$Res, MainScreenState>;
  @useResult
  $Res call({List<CalcModeEntry> entries, bool isScrolled});
}

/// @nodoc
class _$MainScreenStateCopyWithImpl<$Res, $Val extends MainScreenState>
    implements $MainScreenStateCopyWith<$Res> {
  _$MainScreenStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MainScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entries = null, Object? isScrolled = null}) {
    return _then(
      _value.copyWith(
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<CalcModeEntry>,
            isScrolled: null == isScrolled
                ? _value.isScrolled
                : isScrolled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MainScreenStateImplCopyWith<$Res>
    implements $MainScreenStateCopyWith<$Res> {
  factory _$$MainScreenStateImplCopyWith(
    _$MainScreenStateImpl value,
    $Res Function(_$MainScreenStateImpl) then,
  ) = __$$MainScreenStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CalcModeEntry> entries, bool isScrolled});
}

/// @nodoc
class __$$MainScreenStateImplCopyWithImpl<$Res>
    extends _$MainScreenStateCopyWithImpl<$Res, _$MainScreenStateImpl>
    implements _$$MainScreenStateImplCopyWith<$Res> {
  __$$MainScreenStateImplCopyWithImpl(
    _$MainScreenStateImpl _value,
    $Res Function(_$MainScreenStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MainScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entries = null, Object? isScrolled = null}) {
    return _then(
      _$MainScreenStateImpl(
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<CalcModeEntry>,
        isScrolled: null == isScrolled
            ? _value.isScrolled
            : isScrolled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MainScreenStateImpl implements _MainScreenState {
  const _$MainScreenStateImpl({
    final List<CalcModeEntry> entries = const [],
    this.isScrolled = false,
  }) : _entries = entries;

  final List<CalcModeEntry> _entries;
  @override
  @JsonKey()
  List<CalcModeEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  @JsonKey()
  final bool isScrolled;

  @override
  String toString() {
    return 'MainScreenState(entries: $entries, isScrolled: $isScrolled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MainScreenStateImpl &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.isScrolled, isScrolled) ||
                other.isScrolled == isScrolled));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entries),
    isScrolled,
  );

  /// Create a copy of MainScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MainScreenStateImplCopyWith<_$MainScreenStateImpl> get copyWith =>
      __$$MainScreenStateImplCopyWithImpl<_$MainScreenStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MainScreenState implements MainScreenState {
  const factory _MainScreenState({
    final List<CalcModeEntry> entries,
    final bool isScrolled,
  }) = _$MainScreenStateImpl;

  @override
  List<CalcModeEntry> get entries;
  @override
  bool get isScrolled;

  /// Create a copy of MainScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MainScreenStateImplCopyWith<_$MainScreenStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
