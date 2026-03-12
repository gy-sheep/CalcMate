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
    Locale? locale, // null = 시스템 기본
  }) = _SettingsState;
}

// ── Intent ──

sealed class SettingsIntent {
  const SettingsIntent();
  const factory SettingsIntent.themeModeChanged(ThemeMode mode) =
      _ThemeModeChanged;
  const factory SettingsIntent.localeChanged(Locale? locale) = _LocaleChanged;
}

class _ThemeModeChanged extends SettingsIntent {
  final ThemeMode mode;
  const _ThemeModeChanged(this.mode);
}

class _LocaleChanged extends SettingsIntent {
  final Locale? locale;
  const _LocaleChanged(this.locale);
}

// ── Provider ──
// autoDispose 제외: themeMode를 main.dart에서 항상 구독하므로 앱 생명주기와 동일하게 유지

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);

// ── ViewModel ──

const _kThemeModeKey = 'theme_mode';
const _kLocaleKey = 'locale';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedTheme = prefs.getString(_kThemeModeKey);
    final savedLocale = prefs.getString(_kLocaleKey);

    return SettingsState(
      themeMode: switch (savedTheme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: savedLocale != null ? Locale(savedLocale) : null,
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
      case _LocaleChanged(:final locale):
        state = state.copyWith(locale: locale);
        final prefs = ref.read(sharedPreferencesProvider);
        if (locale != null) {
          prefs.setString(_kLocaleKey, locale.languageCode);
        } else {
          prefs.remove(_kLocaleKey);
        }
    }
  }
}
