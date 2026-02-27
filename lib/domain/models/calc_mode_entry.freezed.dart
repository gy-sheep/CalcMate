// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calc_mode_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CalcModeEntry {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Create a copy of CalcModeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalcModeEntryCopyWith<CalcModeEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalcModeEntryCopyWith<$Res> {
  factory $CalcModeEntryCopyWith(
    CalcModeEntry value,
    $Res Function(CalcModeEntry) then,
  ) = _$CalcModeEntryCopyWithImpl<$Res, CalcModeEntry>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    IconData icon,
    String imagePath,
    bool isVisible,
    int order,
  });
}

/// @nodoc
class _$CalcModeEntryCopyWithImpl<$Res, $Val extends CalcModeEntry>
    implements $CalcModeEntryCopyWith<$Res> {
  _$CalcModeEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalcModeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? imagePath = null,
    Object? isVisible = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            isVisible: null == isVisible
                ? _value.isVisible
                : isVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalcModeEntryImplCopyWith<$Res>
    implements $CalcModeEntryCopyWith<$Res> {
  factory _$$CalcModeEntryImplCopyWith(
    _$CalcModeEntryImpl value,
    $Res Function(_$CalcModeEntryImpl) then,
  ) = __$$CalcModeEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    IconData icon,
    String imagePath,
    bool isVisible,
    int order,
  });
}

/// @nodoc
class __$$CalcModeEntryImplCopyWithImpl<$Res>
    extends _$CalcModeEntryCopyWithImpl<$Res, _$CalcModeEntryImpl>
    implements _$$CalcModeEntryImplCopyWith<$Res> {
  __$$CalcModeEntryImplCopyWithImpl(
    _$CalcModeEntryImpl _value,
    $Res Function(_$CalcModeEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalcModeEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? imagePath = null,
    Object? isVisible = null,
    Object? order = null,
  }) {
    return _then(
      _$CalcModeEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        isVisible: null == isVisible
            ? _value.isVisible
            : isVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$CalcModeEntryImpl implements _CalcModeEntry {
  const _$CalcModeEntryImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
    this.isVisible = true,
    required this.order,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final IconData icon;
  @override
  final String imagePath;
  @override
  @JsonKey()
  final bool isVisible;
  @override
  final int order;

  @override
  String toString() {
    return 'CalcModeEntry(id: $id, title: $title, description: $description, icon: $icon, imagePath: $imagePath, isVisible: $isVisible, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalcModeEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    icon,
    imagePath,
    isVisible,
    order,
  );

  /// Create a copy of CalcModeEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalcModeEntryImplCopyWith<_$CalcModeEntryImpl> get copyWith =>
      __$$CalcModeEntryImplCopyWithImpl<_$CalcModeEntryImpl>(this, _$identity);
}

abstract class _CalcModeEntry implements CalcModeEntry {
  const factory _CalcModeEntry({
    required final String id,
    required final String title,
    required final String description,
    required final IconData icon,
    required final String imagePath,
    final bool isVisible,
    required final int order,
  }) = _$CalcModeEntryImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  IconData get icon;
  @override
  String get imagePath;
  @override
  bool get isVisible;
  @override
  int get order;

  /// Create a copy of CalcModeEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalcModeEntryImplCopyWith<_$CalcModeEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
