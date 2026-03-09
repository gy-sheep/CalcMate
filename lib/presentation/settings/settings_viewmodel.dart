import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/di/providers.dart';

part 'settings_viewmodel.freezed.dart';

// ── State ──

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
  }) = _SettingsState;
}

// ── Intent ──

sealed class SettingsIntent {
  const SettingsIntent();
  const factory SettingsIntent.themeModeChanged(ThemeMode mode) =
      _ThemeModeChanged;
}

class _ThemeModeChanged extends SettingsIntent {
  final ThemeMode mode;
  const _ThemeModeChanged(this.mode);
}

// ── Provider ──
// autoDispose 제외: themeMode를 main.dart에서 항상 구독하므로 앱 생명주기와 동일하게 유지

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);

// ── ViewModel ──

const _kThemeModeKey = 'theme_mode';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final saved =
        ref.read(sharedPreferencesProvider).getString(_kThemeModeKey);
    return SettingsState(
      themeMode: switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
    );
  }

  void handleIntent(SettingsIntent intent) {
    switch (intent) {
      case _ThemeModeChanged(:final mode):
        state = state.copyWith(themeMode: mode);
        ref.read(sharedPreferencesProvider).setString(
              _kThemeModeKey,
              switch (mode) {
                ThemeMode.light => 'light',
                ThemeMode.dark => 'dark',
                ThemeMode.system => 'system',
              },
            );
    }
  }
}
