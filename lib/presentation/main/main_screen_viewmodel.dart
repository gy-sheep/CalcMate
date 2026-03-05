import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/calc_mode_config.dart';
import '../../domain/models/calc_mode_entry.dart';

part 'main_screen_viewmodel.freezed.dart';

const _kOrderKey = 'calc_entry_order';

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

// --- ViewModel ---

class MainScreenViewModel extends Notifier<MainScreenState> {
  @override
  MainScreenState build() {
    _loadSavedOrder();
    return const MainScreenState(entries: kCalcModeEntries);
  }

  Future<void> _loadSavedOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList(_kOrderKey);
    if (savedOrder == null) return;

    final entryMap = {for (final e in kCalcModeEntries) e.id: e};
    final ordered = [
      ...savedOrder.map((id) => entryMap[id]).whereType<CalcModeEntry>(),
      ...kCalcModeEntries.where((e) => !savedOrder.contains(e.id)),
    ];

    state = state.copyWith(entries: ordered);
  }

  Future<void> _saveOrder(List<CalcModeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kOrderKey, entries.map((e) => e.id).toList());
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
    }
  }
}

final mainScreenViewModelProvider =
    NotifierProvider<MainScreenViewModel, MainScreenState>(
  MainScreenViewModel.new,
);
