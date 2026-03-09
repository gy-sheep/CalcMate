import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/calc_mode_config.dart';
import '../../domain/models/calc_mode_entry.dart';

part 'main_screen_viewmodel.freezed.dart';

const _kOrderKey = 'calc_entry_order';
const _kHiddenKey = 'calc_entry_hidden';

// --- State ---

@freezed
class MainScreenState with _$MainScreenState {
  const factory MainScreenState({
    @Default([]) List<CalcModeEntry> entries,
    @Default(false) bool isScrolled,
    @Default(false) bool isEditMode,
  }) = _MainScreenState;
}

// --- Intent ---

sealed class MainScreenIntent {
  const MainScreenIntent();
  const factory MainScreenIntent.scrollChanged(bool isScrolled) = _ScrollChanged;
  const factory MainScreenIntent.cardTapped(String id) = _CardTapped;
  const factory MainScreenIntent.toggleEditMode() = _ToggleEditMode;
  const factory MainScreenIntent.reorderEntries(int oldIndex, int newIndex) = _ReorderEntries;
  const factory MainScreenIntent.toggleVisibility(String id) = _ToggleVisibility;
  const factory MainScreenIntent.setAllVisibility(bool visible) = _SetAllVisibility;
}

class _ScrollChanged extends MainScreenIntent {
  final bool isScrolled;
  const _ScrollChanged(this.isScrolled);
}

class _CardTapped extends MainScreenIntent {
  final String id;
  const _CardTapped(this.id);
}

class _ToggleEditMode extends MainScreenIntent {
  const _ToggleEditMode();
}

class _ReorderEntries extends MainScreenIntent {
  final int oldIndex;
  final int newIndex;
  const _ReorderEntries(this.oldIndex, this.newIndex);
}

class _ToggleVisibility extends MainScreenIntent {
  final String id;
  const _ToggleVisibility(this.id);
}

class _SetAllVisibility extends MainScreenIntent {
  final bool visible;
  const _SetAllVisibility(this.visible);
}

// --- ViewModel ---

class MainScreenViewModel extends Notifier<MainScreenState> {
  @override
  MainScreenState build() {
    _loadSavedData();
    return const MainScreenState(entries: kCalcModeEntries);
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 순서 복원
    final savedOrder = prefs.getStringList(_kOrderKey);
    final hiddenIds = prefs.getStringList(_kHiddenKey)?.toSet() ?? {};

    final entryMap = {for (final e in kCalcModeEntries) e.id: e};
    List<CalcModeEntry> entries;

    if (savedOrder != null) {
      entries = [
        ...savedOrder.map((id) => entryMap[id]).whereType<CalcModeEntry>(),
        ...kCalcModeEntries.where((e) => !savedOrder.contains(e.id)),
      ];
    } else {
      entries = kCalcModeEntries.toList();
    }

    // 가시성 복원
    if (hiddenIds.isNotEmpty) {
      entries = entries
          .map((e) => e.copyWith(isVisible: !hiddenIds.contains(e.id)))
          .toList();
    }

    state = state.copyWith(entries: entries);
  }

  Future<void> _saveOrder(List<CalcModeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kOrderKey, entries.map((e) => e.id).toList());
  }

  Future<void> _saveHidden(List<CalcModeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenIds = entries.where((e) => !e.isVisible).map((e) => e.id).toList();
    await prefs.setStringList(_kHiddenKey, hiddenIds);
  }

  void handleIntent(MainScreenIntent intent) {
    switch (intent) {
      case _ScrollChanged(:final isScrolled):
        state = state.copyWith(isScrolled: isScrolled);
      case _CardTapped():
        break;
      case _ToggleEditMode():
        if (state.isEditMode) _saveOrder(state.entries);
        state = state.copyWith(isEditMode: !state.isEditMode);
      case _ReorderEntries(:final oldIndex, :final newIndex):
        final entries = [...state.entries];
        final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final item = entries.removeAt(oldIndex);
        entries.insert(adjusted, item);
        state = state.copyWith(entries: entries);
      case _ToggleVisibility(:final id):
        final visibleCount = state.entries.where((e) => e.isVisible).length;
        final target = state.entries.firstWhere((e) => e.id == id);
        // 마지막 1개는 숨기기 불가
        if (target.isVisible && visibleCount <= 1) return;
        final entries = state.entries
            .map((e) => e.id == id ? e.copyWith(isVisible: !e.isVisible) : e)
            .toList();
        state = state.copyWith(entries: entries);
        _saveHidden(entries);
      case _SetAllVisibility(:final visible):
        if (!visible) {
          // 전체 해제: 첫 번째 항목만 유지
          final entries = state.entries
              .asMap()
              .entries
              .map((e) => e.value.copyWith(isVisible: e.key == 0))
              .toList();
          state = state.copyWith(entries: entries);
          _saveHidden(entries);
        } else {
          // 전체 선택
          final entries = state.entries
              .map((e) => e.copyWith(isVisible: true))
              .toList();
          state = state.copyWith(entries: entries);
          _saveHidden(entries);
        }
    }
  }
}

final mainScreenViewModelProvider =
    NotifierProvider<MainScreenViewModel, MainScreenState>(
  MainScreenViewModel.new,
);
