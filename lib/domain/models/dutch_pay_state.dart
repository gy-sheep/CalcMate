import 'package:freezed_annotation/freezed_annotation.dart';

part 'dutch_pay_state.freezed.dart';

// ── 정산 단위 ──────────────────────────────────────────
enum RemUnit { hundred, thousand }

extension RemUnitExt on RemUnit {
  int get value => this == RemUnit.hundred ? 100 : 1000;
}

// ── 참여자 ─────────────────────────────────────────────
@freezed
class DutchParticipant with _$DutchParticipant {
  const factory DutchParticipant({required String name}) = _DutchParticipant;
}

// ── 항목 ───────────────────────────────────────────────
@freezed
class DutchItem with _$DutchItem {
  const factory DutchItem({
    required String name,
    required int amount,
    required List<int> assignees,
  }) = _DutchItem;
}

// ── 균등 분배 상태 ──────────────────────────────────────
@freezed
class EqualSplitState with _$EqualSplitState {
  const factory EqualSplitState({
    @Default('') String rawInput,
    @Default(2) int people,
    @Default(RemUnit.hundred) RemUnit remUnit,
    @Default(0.0) double tipRate,
    @Default('') String tipInput,
    @Default(false) bool isCustomTip,
    @Default(false) bool keypadVisible,
  }) = _EqualSplitState;
}

// ── 개별 계산 상태 ──────────────────────────────────────
@freezed
class IndividualSplitState with _$IndividualSplitState {
  const factory IndividualSplitState({
    @Default([
      DutchParticipant(name: 'A'),
      DutchParticipant(name: 'B'),
    ])
    List<DutchParticipant> participants,
    @Default([]) List<DutchItem> items,
    @Default('') String nameInput,
    @Default('') String amtInput,
    @Default([]) List<int> selectedParticipants,
    int? editingIndex,
    @Default(false) bool isParticipantEditMode,
    @Default(false) bool amtFocused,
  }) = _IndividualSplitState;
}

// ── 최상위 상태 ─────────────────────────────────────────
@freezed
class DutchPayState with _$DutchPayState {
  const factory DutchPayState({
    @Default(0) int tabIndex,
    @Default(false) bool isKorea,
    @Default(EqualSplitState()) EqualSplitState equalSplit,
    @Default(IndividualSplitState()) IndividualSplitState individualSplit,
  }) = _DutchPayState;
}
