// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dutch_pay_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DutchParticipant {
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of DutchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DutchParticipantCopyWith<DutchParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DutchParticipantCopyWith<$Res> {
  factory $DutchParticipantCopyWith(
    DutchParticipant value,
    $Res Function(DutchParticipant) then,
  ) = _$DutchParticipantCopyWithImpl<$Res, DutchParticipant>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$DutchParticipantCopyWithImpl<$Res, $Val extends DutchParticipant>
    implements $DutchParticipantCopyWith<$Res> {
  _$DutchParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DutchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DutchParticipantImplCopyWith<$Res>
    implements $DutchParticipantCopyWith<$Res> {
  factory _$$DutchParticipantImplCopyWith(
    _$DutchParticipantImpl value,
    $Res Function(_$DutchParticipantImpl) then,
  ) = __$$DutchParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$DutchParticipantImplCopyWithImpl<$Res>
    extends _$DutchParticipantCopyWithImpl<$Res, _$DutchParticipantImpl>
    implements _$$DutchParticipantImplCopyWith<$Res> {
  __$$DutchParticipantImplCopyWithImpl(
    _$DutchParticipantImpl _value,
    $Res Function(_$DutchParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DutchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$DutchParticipantImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DutchParticipantImpl implements _DutchParticipant {
  const _$DutchParticipantImpl({required this.name});

  @override
  final String name;

  @override
  String toString() {
    return 'DutchParticipant(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DutchParticipantImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of DutchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DutchParticipantImplCopyWith<_$DutchParticipantImpl> get copyWith =>
      __$$DutchParticipantImplCopyWithImpl<_$DutchParticipantImpl>(
        this,
        _$identity,
      );
}

abstract class _DutchParticipant implements DutchParticipant {
  const factory _DutchParticipant({required final String name}) =
      _$DutchParticipantImpl;

  @override
  String get name;

  /// Create a copy of DutchParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DutchParticipantImplCopyWith<_$DutchParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DutchItem {
  String get name => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  List<int> get assignees => throw _privateConstructorUsedError;

  /// Create a copy of DutchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DutchItemCopyWith<DutchItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DutchItemCopyWith<$Res> {
  factory $DutchItemCopyWith(DutchItem value, $Res Function(DutchItem) then) =
      _$DutchItemCopyWithImpl<$Res, DutchItem>;
  @useResult
  $Res call({String name, int amount, List<int> assignees});
}

/// @nodoc
class _$DutchItemCopyWithImpl<$Res, $Val extends DutchItem>
    implements $DutchItemCopyWith<$Res> {
  _$DutchItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DutchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? amount = null,
    Object? assignees = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            assignees: null == assignees
                ? _value.assignees
                : assignees // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DutchItemImplCopyWith<$Res>
    implements $DutchItemCopyWith<$Res> {
  factory _$$DutchItemImplCopyWith(
    _$DutchItemImpl value,
    $Res Function(_$DutchItemImpl) then,
  ) = __$$DutchItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int amount, List<int> assignees});
}

/// @nodoc
class __$$DutchItemImplCopyWithImpl<$Res>
    extends _$DutchItemCopyWithImpl<$Res, _$DutchItemImpl>
    implements _$$DutchItemImplCopyWith<$Res> {
  __$$DutchItemImplCopyWithImpl(
    _$DutchItemImpl _value,
    $Res Function(_$DutchItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DutchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? amount = null,
    Object? assignees = null,
  }) {
    return _then(
      _$DutchItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        assignees: null == assignees
            ? _value._assignees
            : assignees // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc

class _$DutchItemImpl implements _DutchItem {
  const _$DutchItemImpl({
    required this.name,
    required this.amount,
    required final List<int> assignees,
  }) : _assignees = assignees;

  @override
  final String name;
  @override
  final int amount;
  final List<int> _assignees;
  @override
  List<int> get assignees {
    if (_assignees is EqualUnmodifiableListView) return _assignees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignees);
  }

  @override
  String toString() {
    return 'DutchItem(name: $name, amount: $amount, assignees: $assignees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DutchItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            const DeepCollectionEquality().equals(
              other._assignees,
              _assignees,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    amount,
    const DeepCollectionEquality().hash(_assignees),
  );

  /// Create a copy of DutchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DutchItemImplCopyWith<_$DutchItemImpl> get copyWith =>
      __$$DutchItemImplCopyWithImpl<_$DutchItemImpl>(this, _$identity);
}

abstract class _DutchItem implements DutchItem {
  const factory _DutchItem({
    required final String name,
    required final int amount,
    required final List<int> assignees,
  }) = _$DutchItemImpl;

  @override
  String get name;
  @override
  int get amount;
  @override
  List<int> get assignees;

  /// Create a copy of DutchItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DutchItemImplCopyWith<_$DutchItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EqualSplitState {
  String get rawInput => throw _privateConstructorUsedError;
  int get people => throw _privateConstructorUsedError;
  RemUnit get remUnit => throw _privateConstructorUsedError;
  double get tipRate => throw _privateConstructorUsedError;
  String get tipInput => throw _privateConstructorUsedError;
  bool get isCustomTip => throw _privateConstructorUsedError;
  bool get keypadVisible => throw _privateConstructorUsedError;

  /// Create a copy of EqualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EqualSplitStateCopyWith<EqualSplitState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EqualSplitStateCopyWith<$Res> {
  factory $EqualSplitStateCopyWith(
    EqualSplitState value,
    $Res Function(EqualSplitState) then,
  ) = _$EqualSplitStateCopyWithImpl<$Res, EqualSplitState>;
  @useResult
  $Res call({
    String rawInput,
    int people,
    RemUnit remUnit,
    double tipRate,
    String tipInput,
    bool isCustomTip,
    bool keypadVisible,
  });
}

/// @nodoc
class _$EqualSplitStateCopyWithImpl<$Res, $Val extends EqualSplitState>
    implements $EqualSplitStateCopyWith<$Res> {
  _$EqualSplitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EqualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawInput = null,
    Object? people = null,
    Object? remUnit = null,
    Object? tipRate = null,
    Object? tipInput = null,
    Object? isCustomTip = null,
    Object? keypadVisible = null,
  }) {
    return _then(
      _value.copyWith(
            rawInput: null == rawInput
                ? _value.rawInput
                : rawInput // ignore: cast_nullable_to_non_nullable
                      as String,
            people: null == people
                ? _value.people
                : people // ignore: cast_nullable_to_non_nullable
                      as int,
            remUnit: null == remUnit
                ? _value.remUnit
                : remUnit // ignore: cast_nullable_to_non_nullable
                      as RemUnit,
            tipRate: null == tipRate
                ? _value.tipRate
                : tipRate // ignore: cast_nullable_to_non_nullable
                      as double,
            tipInput: null == tipInput
                ? _value.tipInput
                : tipInput // ignore: cast_nullable_to_non_nullable
                      as String,
            isCustomTip: null == isCustomTip
                ? _value.isCustomTip
                : isCustomTip // ignore: cast_nullable_to_non_nullable
                      as bool,
            keypadVisible: null == keypadVisible
                ? _value.keypadVisible
                : keypadVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EqualSplitStateImplCopyWith<$Res>
    implements $EqualSplitStateCopyWith<$Res> {
  factory _$$EqualSplitStateImplCopyWith(
    _$EqualSplitStateImpl value,
    $Res Function(_$EqualSplitStateImpl) then,
  ) = __$$EqualSplitStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rawInput,
    int people,
    RemUnit remUnit,
    double tipRate,
    String tipInput,
    bool isCustomTip,
    bool keypadVisible,
  });
}

/// @nodoc
class __$$EqualSplitStateImplCopyWithImpl<$Res>
    extends _$EqualSplitStateCopyWithImpl<$Res, _$EqualSplitStateImpl>
    implements _$$EqualSplitStateImplCopyWith<$Res> {
  __$$EqualSplitStateImplCopyWithImpl(
    _$EqualSplitStateImpl _value,
    $Res Function(_$EqualSplitStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EqualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawInput = null,
    Object? people = null,
    Object? remUnit = null,
    Object? tipRate = null,
    Object? tipInput = null,
    Object? isCustomTip = null,
    Object? keypadVisible = null,
  }) {
    return _then(
      _$EqualSplitStateImpl(
        rawInput: null == rawInput
            ? _value.rawInput
            : rawInput // ignore: cast_nullable_to_non_nullable
                  as String,
        people: null == people
            ? _value.people
            : people // ignore: cast_nullable_to_non_nullable
                  as int,
        remUnit: null == remUnit
            ? _value.remUnit
            : remUnit // ignore: cast_nullable_to_non_nullable
                  as RemUnit,
        tipRate: null == tipRate
            ? _value.tipRate
            : tipRate // ignore: cast_nullable_to_non_nullable
                  as double,
        tipInput: null == tipInput
            ? _value.tipInput
            : tipInput // ignore: cast_nullable_to_non_nullable
                  as String,
        isCustomTip: null == isCustomTip
            ? _value.isCustomTip
            : isCustomTip // ignore: cast_nullable_to_non_nullable
                  as bool,
        keypadVisible: null == keypadVisible
            ? _value.keypadVisible
            : keypadVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$EqualSplitStateImpl implements _EqualSplitState {
  const _$EqualSplitStateImpl({
    this.rawInput = '',
    this.people = 2,
    this.remUnit = RemUnit.hundred,
    this.tipRate = 0.0,
    this.tipInput = '',
    this.isCustomTip = false,
    this.keypadVisible = false,
  });

  @override
  @JsonKey()
  final String rawInput;
  @override
  @JsonKey()
  final int people;
  @override
  @JsonKey()
  final RemUnit remUnit;
  @override
  @JsonKey()
  final double tipRate;
  @override
  @JsonKey()
  final String tipInput;
  @override
  @JsonKey()
  final bool isCustomTip;
  @override
  @JsonKey()
  final bool keypadVisible;

  @override
  String toString() {
    return 'EqualSplitState(rawInput: $rawInput, people: $people, remUnit: $remUnit, tipRate: $tipRate, tipInput: $tipInput, isCustomTip: $isCustomTip, keypadVisible: $keypadVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EqualSplitStateImpl &&
            (identical(other.rawInput, rawInput) ||
                other.rawInput == rawInput) &&
            (identical(other.people, people) || other.people == people) &&
            (identical(other.remUnit, remUnit) || other.remUnit == remUnit) &&
            (identical(other.tipRate, tipRate) || other.tipRate == tipRate) &&
            (identical(other.tipInput, tipInput) ||
                other.tipInput == tipInput) &&
            (identical(other.isCustomTip, isCustomTip) ||
                other.isCustomTip == isCustomTip) &&
            (identical(other.keypadVisible, keypadVisible) ||
                other.keypadVisible == keypadVisible));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    rawInput,
    people,
    remUnit,
    tipRate,
    tipInput,
    isCustomTip,
    keypadVisible,
  );

  /// Create a copy of EqualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EqualSplitStateImplCopyWith<_$EqualSplitStateImpl> get copyWith =>
      __$$EqualSplitStateImplCopyWithImpl<_$EqualSplitStateImpl>(
        this,
        _$identity,
      );
}

abstract class _EqualSplitState implements EqualSplitState {
  const factory _EqualSplitState({
    final String rawInput,
    final int people,
    final RemUnit remUnit,
    final double tipRate,
    final String tipInput,
    final bool isCustomTip,
    final bool keypadVisible,
  }) = _$EqualSplitStateImpl;

  @override
  String get rawInput;
  @override
  int get people;
  @override
  RemUnit get remUnit;
  @override
  double get tipRate;
  @override
  String get tipInput;
  @override
  bool get isCustomTip;
  @override
  bool get keypadVisible;

  /// Create a copy of EqualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EqualSplitStateImplCopyWith<_$EqualSplitStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IndividualSplitState {
  List<DutchParticipant> get participants => throw _privateConstructorUsedError;
  List<DutchItem> get items => throw _privateConstructorUsedError;
  String get nameInput => throw _privateConstructorUsedError;
  String get amtInput => throw _privateConstructorUsedError;
  List<int> get selectedParticipants => throw _privateConstructorUsedError;
  int? get editingIndex => throw _privateConstructorUsedError;
  bool get isParticipantEditMode => throw _privateConstructorUsedError;
  bool get amtFocused => throw _privateConstructorUsedError;

  /// Create a copy of IndividualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IndividualSplitStateCopyWith<IndividualSplitState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndividualSplitStateCopyWith<$Res> {
  factory $IndividualSplitStateCopyWith(
    IndividualSplitState value,
    $Res Function(IndividualSplitState) then,
  ) = _$IndividualSplitStateCopyWithImpl<$Res, IndividualSplitState>;
  @useResult
  $Res call({
    List<DutchParticipant> participants,
    List<DutchItem> items,
    String nameInput,
    String amtInput,
    List<int> selectedParticipants,
    int? editingIndex,
    bool isParticipantEditMode,
    bool amtFocused,
  });
}

/// @nodoc
class _$IndividualSplitStateCopyWithImpl<
  $Res,
  $Val extends IndividualSplitState
>
    implements $IndividualSplitStateCopyWith<$Res> {
  _$IndividualSplitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IndividualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participants = null,
    Object? items = null,
    Object? nameInput = null,
    Object? amtInput = null,
    Object? selectedParticipants = null,
    Object? editingIndex = freezed,
    Object? isParticipantEditMode = null,
    Object? amtFocused = null,
  }) {
    return _then(
      _value.copyWith(
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<DutchParticipant>,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<DutchItem>,
            nameInput: null == nameInput
                ? _value.nameInput
                : nameInput // ignore: cast_nullable_to_non_nullable
                      as String,
            amtInput: null == amtInput
                ? _value.amtInput
                : amtInput // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedParticipants: null == selectedParticipants
                ? _value.selectedParticipants
                : selectedParticipants // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            editingIndex: freezed == editingIndex
                ? _value.editingIndex
                : editingIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            isParticipantEditMode: null == isParticipantEditMode
                ? _value.isParticipantEditMode
                : isParticipantEditMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            amtFocused: null == amtFocused
                ? _value.amtFocused
                : amtFocused // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IndividualSplitStateImplCopyWith<$Res>
    implements $IndividualSplitStateCopyWith<$Res> {
  factory _$$IndividualSplitStateImplCopyWith(
    _$IndividualSplitStateImpl value,
    $Res Function(_$IndividualSplitStateImpl) then,
  ) = __$$IndividualSplitStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DutchParticipant> participants,
    List<DutchItem> items,
    String nameInput,
    String amtInput,
    List<int> selectedParticipants,
    int? editingIndex,
    bool isParticipantEditMode,
    bool amtFocused,
  });
}

/// @nodoc
class __$$IndividualSplitStateImplCopyWithImpl<$Res>
    extends _$IndividualSplitStateCopyWithImpl<$Res, _$IndividualSplitStateImpl>
    implements _$$IndividualSplitStateImplCopyWith<$Res> {
  __$$IndividualSplitStateImplCopyWithImpl(
    _$IndividualSplitStateImpl _value,
    $Res Function(_$IndividualSplitStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IndividualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participants = null,
    Object? items = null,
    Object? nameInput = null,
    Object? amtInput = null,
    Object? selectedParticipants = null,
    Object? editingIndex = freezed,
    Object? isParticipantEditMode = null,
    Object? amtFocused = null,
  }) {
    return _then(
      _$IndividualSplitStateImpl(
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<DutchParticipant>,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<DutchItem>,
        nameInput: null == nameInput
            ? _value.nameInput
            : nameInput // ignore: cast_nullable_to_non_nullable
                  as String,
        amtInput: null == amtInput
            ? _value.amtInput
            : amtInput // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedParticipants: null == selectedParticipants
            ? _value._selectedParticipants
            : selectedParticipants // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        editingIndex: freezed == editingIndex
            ? _value.editingIndex
            : editingIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        isParticipantEditMode: null == isParticipantEditMode
            ? _value.isParticipantEditMode
            : isParticipantEditMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        amtFocused: null == amtFocused
            ? _value.amtFocused
            : amtFocused // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$IndividualSplitStateImpl implements _IndividualSplitState {
  const _$IndividualSplitStateImpl({
    final List<DutchParticipant> participants = const [
      DutchParticipant(name: 'A'),
      DutchParticipant(name: 'B'),
    ],
    final List<DutchItem> items = const [],
    this.nameInput = '',
    this.amtInput = '',
    final List<int> selectedParticipants = const [],
    this.editingIndex,
    this.isParticipantEditMode = false,
    this.amtFocused = false,
  }) : _participants = participants,
       _items = items,
       _selectedParticipants = selectedParticipants;

  final List<DutchParticipant> _participants;
  @override
  @JsonKey()
  List<DutchParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  final List<DutchItem> _items;
  @override
  @JsonKey()
  List<DutchItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final String nameInput;
  @override
  @JsonKey()
  final String amtInput;
  final List<int> _selectedParticipants;
  @override
  @JsonKey()
  List<int> get selectedParticipants {
    if (_selectedParticipants is EqualUnmodifiableListView)
      return _selectedParticipants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedParticipants);
  }

  @override
  final int? editingIndex;
  @override
  @JsonKey()
  final bool isParticipantEditMode;
  @override
  @JsonKey()
  final bool amtFocused;

  @override
  String toString() {
    return 'IndividualSplitState(participants: $participants, items: $items, nameInput: $nameInput, amtInput: $amtInput, selectedParticipants: $selectedParticipants, editingIndex: $editingIndex, isParticipantEditMode: $isParticipantEditMode, amtFocused: $amtFocused)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndividualSplitStateImpl &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nameInput, nameInput) ||
                other.nameInput == nameInput) &&
            (identical(other.amtInput, amtInput) ||
                other.amtInput == amtInput) &&
            const DeepCollectionEquality().equals(
              other._selectedParticipants,
              _selectedParticipants,
            ) &&
            (identical(other.editingIndex, editingIndex) ||
                other.editingIndex == editingIndex) &&
            (identical(other.isParticipantEditMode, isParticipantEditMode) ||
                other.isParticipantEditMode == isParticipantEditMode) &&
            (identical(other.amtFocused, amtFocused) ||
                other.amtFocused == amtFocused));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_participants),
    const DeepCollectionEquality().hash(_items),
    nameInput,
    amtInput,
    const DeepCollectionEquality().hash(_selectedParticipants),
    editingIndex,
    isParticipantEditMode,
    amtFocused,
  );

  /// Create a copy of IndividualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IndividualSplitStateImplCopyWith<_$IndividualSplitStateImpl>
  get copyWith =>
      __$$IndividualSplitStateImplCopyWithImpl<_$IndividualSplitStateImpl>(
        this,
        _$identity,
      );
}

abstract class _IndividualSplitState implements IndividualSplitState {
  const factory _IndividualSplitState({
    final List<DutchParticipant> participants,
    final List<DutchItem> items,
    final String nameInput,
    final String amtInput,
    final List<int> selectedParticipants,
    final int? editingIndex,
    final bool isParticipantEditMode,
    final bool amtFocused,
  }) = _$IndividualSplitStateImpl;

  @override
  List<DutchParticipant> get participants;
  @override
  List<DutchItem> get items;
  @override
  String get nameInput;
  @override
  String get amtInput;
  @override
  List<int> get selectedParticipants;
  @override
  int? get editingIndex;
  @override
  bool get isParticipantEditMode;
  @override
  bool get amtFocused;

  /// Create a copy of IndividualSplitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IndividualSplitStateImplCopyWith<_$IndividualSplitStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DutchPayState {
  int get tabIndex => throw _privateConstructorUsedError;
  bool get isKorea => throw _privateConstructorUsedError;
  EqualSplitState get equalSplit => throw _privateConstructorUsedError;
  IndividualSplitState get individualSplit =>
      throw _privateConstructorUsedError;

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DutchPayStateCopyWith<DutchPayState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DutchPayStateCopyWith<$Res> {
  factory $DutchPayStateCopyWith(
    DutchPayState value,
    $Res Function(DutchPayState) then,
  ) = _$DutchPayStateCopyWithImpl<$Res, DutchPayState>;
  @useResult
  $Res call({
    int tabIndex,
    bool isKorea,
    EqualSplitState equalSplit,
    IndividualSplitState individualSplit,
  });

  $EqualSplitStateCopyWith<$Res> get equalSplit;
  $IndividualSplitStateCopyWith<$Res> get individualSplit;
}

/// @nodoc
class _$DutchPayStateCopyWithImpl<$Res, $Val extends DutchPayState>
    implements $DutchPayStateCopyWith<$Res> {
  _$DutchPayStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tabIndex = null,
    Object? isKorea = null,
    Object? equalSplit = null,
    Object? individualSplit = null,
  }) {
    return _then(
      _value.copyWith(
            tabIndex: null == tabIndex
                ? _value.tabIndex
                : tabIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isKorea: null == isKorea
                ? _value.isKorea
                : isKorea // ignore: cast_nullable_to_non_nullable
                      as bool,
            equalSplit: null == equalSplit
                ? _value.equalSplit
                : equalSplit // ignore: cast_nullable_to_non_nullable
                      as EqualSplitState,
            individualSplit: null == individualSplit
                ? _value.individualSplit
                : individualSplit // ignore: cast_nullable_to_non_nullable
                      as IndividualSplitState,
          )
          as $Val,
    );
  }

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EqualSplitStateCopyWith<$Res> get equalSplit {
    return $EqualSplitStateCopyWith<$Res>(_value.equalSplit, (value) {
      return _then(_value.copyWith(equalSplit: value) as $Val);
    });
  }

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IndividualSplitStateCopyWith<$Res> get individualSplit {
    return $IndividualSplitStateCopyWith<$Res>(_value.individualSplit, (value) {
      return _then(_value.copyWith(individualSplit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DutchPayStateImplCopyWith<$Res>
    implements $DutchPayStateCopyWith<$Res> {
  factory _$$DutchPayStateImplCopyWith(
    _$DutchPayStateImpl value,
    $Res Function(_$DutchPayStateImpl) then,
  ) = __$$DutchPayStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int tabIndex,
    bool isKorea,
    EqualSplitState equalSplit,
    IndividualSplitState individualSplit,
  });

  @override
  $EqualSplitStateCopyWith<$Res> get equalSplit;
  @override
  $IndividualSplitStateCopyWith<$Res> get individualSplit;
}

/// @nodoc
class __$$DutchPayStateImplCopyWithImpl<$Res>
    extends _$DutchPayStateCopyWithImpl<$Res, _$DutchPayStateImpl>
    implements _$$DutchPayStateImplCopyWith<$Res> {
  __$$DutchPayStateImplCopyWithImpl(
    _$DutchPayStateImpl _value,
    $Res Function(_$DutchPayStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tabIndex = null,
    Object? isKorea = null,
    Object? equalSplit = null,
    Object? individualSplit = null,
  }) {
    return _then(
      _$DutchPayStateImpl(
        tabIndex: null == tabIndex
            ? _value.tabIndex
            : tabIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isKorea: null == isKorea
            ? _value.isKorea
            : isKorea // ignore: cast_nullable_to_non_nullable
                  as bool,
        equalSplit: null == equalSplit
            ? _value.equalSplit
            : equalSplit // ignore: cast_nullable_to_non_nullable
                  as EqualSplitState,
        individualSplit: null == individualSplit
            ? _value.individualSplit
            : individualSplit // ignore: cast_nullable_to_non_nullable
                  as IndividualSplitState,
      ),
    );
  }
}

/// @nodoc

class _$DutchPayStateImpl implements _DutchPayState {
  const _$DutchPayStateImpl({
    this.tabIndex = 0,
    this.isKorea = false,
    this.equalSplit = const EqualSplitState(),
    this.individualSplit = const IndividualSplitState(),
  });

  @override
  @JsonKey()
  final int tabIndex;
  @override
  @JsonKey()
  final bool isKorea;
  @override
  @JsonKey()
  final EqualSplitState equalSplit;
  @override
  @JsonKey()
  final IndividualSplitState individualSplit;

  @override
  String toString() {
    return 'DutchPayState(tabIndex: $tabIndex, isKorea: $isKorea, equalSplit: $equalSplit, individualSplit: $individualSplit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DutchPayStateImpl &&
            (identical(other.tabIndex, tabIndex) ||
                other.tabIndex == tabIndex) &&
            (identical(other.isKorea, isKorea) || other.isKorea == isKorea) &&
            (identical(other.equalSplit, equalSplit) ||
                other.equalSplit == equalSplit) &&
            (identical(other.individualSplit, individualSplit) ||
                other.individualSplit == individualSplit));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, tabIndex, isKorea, equalSplit, individualSplit);

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DutchPayStateImplCopyWith<_$DutchPayStateImpl> get copyWith =>
      __$$DutchPayStateImplCopyWithImpl<_$DutchPayStateImpl>(this, _$identity);
}

abstract class _DutchPayState implements DutchPayState {
  const factory _DutchPayState({
    final int tabIndex,
    final bool isKorea,
    final EqualSplitState equalSplit,
    final IndividualSplitState individualSplit,
  }) = _$DutchPayStateImpl;

  @override
  int get tabIndex;
  @override
  bool get isKorea;
  @override
  EqualSplitState get equalSplit;
  @override
  IndividualSplitState get individualSplit;

  /// Create a copy of DutchPayState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DutchPayStateImplCopyWith<_$DutchPayStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
