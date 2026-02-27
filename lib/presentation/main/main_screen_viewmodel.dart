import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/calc_mode_config.dart';
import '../../domain/models/calc_mode_entry.dart';

part 'main_screen_viewmodel.freezed.dart';

// --- State ---

@freezed
class MainScreenState with _$MainScreenState {
  const factory MainScreenState({
    @Default([]) List<CalcModeEntry> entries,
    @Default(false) bool isScrolled,
  }) = _MainScreenState;
}

// --- Intent ---

sealed class MainScreenIntent {
  const factory MainScreenIntent.scrollChanged(bool isScrolled) = _ScrollChanged;
  const factory MainScreenIntent.cardTapped(String id) = _CardTapped;
}

class _ScrollChanged implements MainScreenIntent {
  final bool isScrolled;
  const _ScrollChanged(this.isScrolled);
}

class _CardTapped implements MainScreenIntent {
  final String id;
  const _CardTapped(this.id);
}

// --- ViewModel ---

class MainScreenViewModel extends Notifier<MainScreenState> {
  @override
  MainScreenState build() => const MainScreenState(entries: kCalcModeEntries);

  void handleIntent(MainScreenIntent intent) {
    switch (intent) {
      case _ScrollChanged(:final isScrolled):
        state = state.copyWith(isScrolled: isScrolled);
      case _CardTapped():
        // 라우팅 처리 — Phase 1 이후 확장
        break;
    }
  }
}

final mainScreenViewModelProvider =
    NotifierProvider<MainScreenViewModel, MainScreenState>(
  MainScreenViewModel.new,
);
