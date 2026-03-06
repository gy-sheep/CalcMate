import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dutch_pay_state.dart';
import '../../domain/usecases/dutch_pay_equal_split_usecase.dart';
import '../../domain/usecases/dutch_pay_individual_split_usecase.dart';

// ──────────────────────────────────────────
// Intent
// ──────────────────────────────────────────

sealed class DutchPayIntent {
  const DutchPayIntent();

  // 공통
  const factory DutchPayIntent.tabChanged(int index) = _TabChanged;

  // 균등 분배
  const factory DutchPayIntent.keyPressed(String key) = _KeyPressed;
  const factory DutchPayIntent.peopleChanged(int delta) = _PeopleChanged;
  const factory DutchPayIntent.remUnitChanged(RemUnit unit) = _RemUnitChanged;
  const factory DutchPayIntent.tipRateChanged(double rate) = _TipRateChanged;
  const factory DutchPayIntent.tipKeyPressed(String key) = _TipKeyPressed;
  const factory DutchPayIntent.keypadToggled(bool visible) = _KeypadToggled;

  // 개별 계산 — 참여자
  const factory DutchPayIntent.participantAdded() = _ParticipantAdded;
  const factory DutchPayIntent.participantRemoved(int index) =
      _ParticipantRemoved;
  const factory DutchPayIntent.participantRenamed(int index, String name) =
      _ParticipantRenamed;
  const factory DutchPayIntent.participantEditModeToggled() =
      _ParticipantEditModeToggled;

  // 개별 계산 — 항목 입력
  const factory DutchPayIntent.nameInputChanged(String value) =
      _NameInputChanged;
  const factory DutchPayIntent.amtKeyPressed(String key) = _AmtKeyPressed;
  const factory DutchPayIntent.amtInputChanged(String value) = _AmtInputChanged;
  const factory DutchPayIntent.amtFocusChanged(bool focused) =
      _AmtFocusChanged;
  const factory DutchPayIntent.participantToggled(int index) =
      _ParticipantToggled;
  const factory DutchPayIntent.itemSubmitted() = _ItemSubmitted;
  const factory DutchPayIntent.itemTapped(int index) = _ItemTapped;
  const factory DutchPayIntent.itemDeleted() = _ItemDeleted;
  const factory DutchPayIntent.inputCleared() = _InputCleared;
}

class _TabChanged extends DutchPayIntent {
  final int index;
  const _TabChanged(this.index);
}

class _KeyPressed extends DutchPayIntent {
  final String key;
  const _KeyPressed(this.key);
}

class _PeopleChanged extends DutchPayIntent {
  final int delta;
  const _PeopleChanged(this.delta);
}

class _RemUnitChanged extends DutchPayIntent {
  final RemUnit unit;
  const _RemUnitChanged(this.unit);
}

class _TipRateChanged extends DutchPayIntent {
  final double rate;
  const _TipRateChanged(this.rate);
}

class _TipKeyPressed extends DutchPayIntent {
  final String key;
  const _TipKeyPressed(this.key);
}

class _KeypadToggled extends DutchPayIntent {
  final bool visible;
  const _KeypadToggled(this.visible);
}

class _ParticipantAdded extends DutchPayIntent {
  const _ParticipantAdded();
}

class _ParticipantRemoved extends DutchPayIntent {
  final int index;
  const _ParticipantRemoved(this.index);
}

class _ParticipantRenamed extends DutchPayIntent {
  final int index;
  final String name;
  const _ParticipantRenamed(this.index, this.name);
}

class _ParticipantEditModeToggled extends DutchPayIntent {
  const _ParticipantEditModeToggled();
}

class _NameInputChanged extends DutchPayIntent {
  final String value;
  const _NameInputChanged(this.value);
}

class _AmtKeyPressed extends DutchPayIntent {
  final String key;
  const _AmtKeyPressed(this.key);
}

class _AmtInputChanged extends DutchPayIntent {
  final String value;
  const _AmtInputChanged(this.value);
}

class _AmtFocusChanged extends DutchPayIntent {
  final bool focused;
  const _AmtFocusChanged(this.focused);
}

class _ParticipantToggled extends DutchPayIntent {
  final int index;
  const _ParticipantToggled(this.index);
}

class _ItemSubmitted extends DutchPayIntent {
  const _ItemSubmitted();
}

class _ItemTapped extends DutchPayIntent {
  final int index;
  const _ItemTapped(this.index);
}

class _ItemDeleted extends DutchPayIntent {
  const _ItemDeleted();
}

class _InputCleared extends DutchPayIntent {
  const _InputCleared();
}

// ──────────────────────────────────────────
// Provider
// ──────────────────────────────────────────

final dutchPayViewModelProvider =
    NotifierProvider.autoDispose<DutchPayViewModel, DutchPayState>(
  DutchPayViewModel.new,
);

// ──────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────

class DutchPayViewModel extends AutoDisposeNotifier<DutchPayState> {
  final _equalUseCase = EqualSplitUseCase();
  final _individualUseCase = IndividualSplitUseCase();

  // 참여자 이름은 숫자로 표시 (UI에서 아이콘과 함께 노출)

  @override
  DutchPayState build() {
    final countryCode =
        PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
    final isKorea = countryCode == 'KR';
    return DutchPayState(isKorea: isKorea);
  }

  void handleIntent(DutchPayIntent intent) {
    switch (intent) {
      // ── 공통 ──────────────────────────────────────────────
      case _TabChanged(:final index):
        state = state.copyWith(
          tabIndex: index,
          equalSplit: const EqualSplitState(),
          individualSplit: const IndividualSplitState(),
        );

      // ── 균등 분배 ──────────────────────────────────────────
      case _KeyPressed(:final key):
        state = state.copyWith(equalSplit: _handleAmountKey(state.equalSplit, key));

      case _PeopleChanged(:final delta):
        final next = (state.equalSplit.people + delta).clamp(2, 30);
        state = state.copyWith(
            equalSplit: state.equalSplit.copyWith(people: next));

      case _RemUnitChanged(:final unit):
        state = state.copyWith(
            equalSplit: state.equalSplit.copyWith(remUnit: unit));

      case _TipRateChanged(:final rate):
        state = state.copyWith(
          equalSplit: state.equalSplit.copyWith(
            tipRate: rate,
            isCustomTip: false,
            tipInput: '',
          ),
        );

      case _TipKeyPressed(:final key):
        state = state.copyWith(
          equalSplit: _handleTipKey(state.equalSplit, key),
        );

      case _KeypadToggled(:final visible):
        state = state.copyWith(
            equalSplit: state.equalSplit.copyWith(keypadVisible: visible));

      // ── 개별 계산 — 참여자 ────────────────────────────────
      case _ParticipantAdded():
        final current = state.individualSplit.participants;
        if (current.length >= 10) return;
        final name = String.fromCharCode(65 + current.length % 26);
        final next = [...current, DutchParticipant(name: name)];
        state = state.copyWith(
            individualSplit:
                state.individualSplit.copyWith(participants: next));

      case _ParticipantRenamed(:final index, :final name):
        final ps = List<DutchParticipant>.from(state.individualSplit.participants);
        ps[index] = ps[index].copyWith(name: name);
        state = state.copyWith(
            individualSplit:
                state.individualSplit.copyWith(participants: ps));

      case _ParticipantRemoved(:final index):
        _removeParticipant(index);

      case _ParticipantEditModeToggled():
        final s = state.individualSplit;
        state = state.copyWith(
          individualSplit: s.copyWith(
            isParticipantEditMode: !s.isParticipantEditMode,
          ),
        );

      // ── 개별 계산 — 항목 입력 ────────────────────────────
      case _NameInputChanged(:final value):
        state = state.copyWith(
            individualSplit: state.individualSplit.copyWith(nameInput: value));

      case _AmtKeyPressed(:final key):
        state = state.copyWith(
            individualSplit:
                _handleAmtKey(state.individualSplit, key));

      case _AmtInputChanged(:final value):
        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
        final clamped = digits.length > 9 ? digits.substring(0, 9) : digits;
        state = state.copyWith(
            individualSplit:
                state.individualSplit.copyWith(amtInput: clamped));

      case _AmtFocusChanged(:final focused):
        state = state.copyWith(
            individualSplit:
                state.individualSplit.copyWith(amtFocused: focused));

      case _ParticipantToggled(:final index):
        final sel = List<int>.from(state.individualSplit.selectedParticipants);
        if (sel.contains(index)) {
          sel.remove(index);
        } else {
          sel.add(index);
        }
        state = state.copyWith(
            individualSplit:
                state.individualSplit.copyWith(selectedParticipants: sel));

      case _ItemSubmitted():
        _submitItem();

      case _ItemTapped(:final index):
        _tapItem(index);

      case _ItemDeleted():
        _deleteItem();

      case _InputCleared():
        state = state.copyWith(
            individualSplit: _clearedIndividual(state.individualSplit));
    }
  }

  // ── 균등 분배 키 처리 ───────────────────────────────────

  EqualSplitState _handleAmountKey(EqualSplitState s, String key) {
    if (key == '↵') return s.copyWith(keypadVisible: false);
    if (key == 'C') return s.copyWith(rawInput: '', keypadVisible: true);
    String raw = s.rawInput;
    switch (key) {
      case '⌫':
        raw = raw.isEmpty ? '' : raw.substring(0, raw.length - 1);
      default:
        if (key == '0' && raw.isEmpty) return s;
        if (raw.length >= 9) return s;
        raw += key;
    }
    return s.copyWith(rawInput: raw);
  }

  EqualSplitState _handleTipKey(EqualSplitState s, String key) {
    String tip = s.tipInput;
    switch (key) {
      case '⌫':
        tip = tip.isEmpty ? '' : tip.substring(0, tip.length - 1);
      case '.':
        if (tip.contains('.')) return s;
        tip = tip.isEmpty ? '0.' : '$tip.';
      default:
        if (tip.length >= 5) return s;
        tip += key;
    }
    final rate = double.tryParse(tip) ?? 0.0;
    return s.copyWith(tipInput: tip, tipRate: rate, isCustomTip: true);
  }

  // ── 개별 계산 키 처리 ───────────────────────────────────

  IndividualSplitState _handleAmtKey(IndividualSplitState s, String key) {
    if (key == '↵') return s.copyWith(amtFocused: false);
    String amt = s.amtInput;
    switch (key) {
      case '⌫':
        amt = amt.isEmpty ? '' : amt.substring(0, amt.length - 1);
      case '00':
        if (amt.isEmpty || amt == '0') return s;
        if (amt.length + 2 > 9) return s;
        amt += '00';
      default:
        if (key == '0' && amt.isEmpty) return s;
        if (amt.length >= 9) return s;
        amt += key;
    }
    return s.copyWith(amtInput: amt);
  }

  // ── 참여자 삭제 ─────────────────────────────────────────

  void _removeParticipant(int idx) {
    final s = state.individualSplit;
    final newParticipants = List<DutchParticipant>.from(s.participants)
      ..removeAt(idx);

    final newItems = s.items
        .map((item) {
          final newAssignees = item.assignees
              .where((i) => i != idx)
              .map((i) => i > idx ? i - 1 : i)
              .toList();
          return newAssignees.isEmpty
              ? null
              : item.copyWith(assignees: newAssignees);
        })
        .whereType<DutchItem>()
        .toList();

    final newSelected = s.selectedParticipants
        .where((i) => i != idx)
        .map((i) => i > idx ? i - 1 : i)
        .toList();

    final editingIndex =
        s.editingIndex == idx ? null : s.editingIndex;

    state = state.copyWith(
      individualSplit: s.copyWith(
        participants: newParticipants,
        items: newItems,
        selectedParticipants: newSelected,
        editingIndex: editingIndex,
      ),
    );
  }

  // ── 항목 제출 / 수정 / 삭제 ─────────────────────────────

  void _submitItem() {
    final s = state.individualSplit;
    final amt = int.tryParse(s.amtInput) ?? 0;
    if (amt == 0 || s.selectedParticipants.isEmpty) return;

    final name = s.nameInput.trim().isEmpty
        ? '메뉴 ${s.items.length + 1}'
        : s.nameInput.trim();

    final item = DutchItem(
      name: name,
      amount: amt,
      assignees: List.from(s.selectedParticipants),
    );

    List<DutchItem> newItems;
    if (s.editingIndex != null) {
      newItems = List.from(s.items)..[s.editingIndex!] = item;
    } else {
      newItems = [...s.items, item];
    }

    state = state.copyWith(
        individualSplit: _clearedIndividual(s.copyWith(items: newItems)));
  }

  void _tapItem(int index) {
    final s = state.individualSplit;
    final item = s.items[index];
    state = state.copyWith(
      individualSplit: s.copyWith(
        nameInput: item.name,
        amtInput: item.amount.toString(),
        selectedParticipants: List.from(item.assignees),
        editingIndex: index,
        amtFocused: false,
      ),
    );
  }

  void _deleteItem() {
    final s = state.individualSplit;
    if (s.editingIndex == null) return;
    final newItems = List<DutchItem>.from(s.items)..removeAt(s.editingIndex!);
    state = state.copyWith(
        individualSplit:
            _clearedIndividual(s.copyWith(items: newItems)));
  }

  IndividualSplitState _clearedIndividual(IndividualSplitState s) {
    return s.copyWith(
      nameInput: '',
      amtInput: '',
      selectedParticipants: [],
      editingIndex: null,
      amtFocused: false,
    );
  }

  // ── Computed getters ─────────────────────────────────────

  EqualSplitResult? get equalSplitResult {
    final total = int.tryParse(state.equalSplit.rawInput) ?? 0;
    if (total == 0) return null;
    return _equalUseCase.execute(
      total: total,
      people: state.equalSplit.people,
      remUnit: state.equalSplit.remUnit,
      tipRate: state.equalSplit.tipRate,
      isKorea: state.isKorea,
    );
  }

  IndividualSplitResult get individualSplitResult {
    return _individualUseCase.execute(
      participants: state.individualSplit.participants,
      items: state.individualSplit.items,
    );
  }

  bool get canSubmitItem {
    final amt = int.tryParse(state.individualSplit.amtInput) ?? 0;
    return amt > 0 && state.individualSplit.selectedParticipants.isNotEmpty;
  }

  String fmt(int n) {
    if (n == 0) return '0';
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return n < 0 ? '-${buf.toString()}' : buf.toString();
  }
}
