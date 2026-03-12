import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/di/providers.dart';
import '../../domain/models/currency_unit.dart';

part 'settings_viewmodel.freezed.dart';

// ── State ──

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    Locale? locale, // null = 시스템 기본
    CurrencyUnit? displayCurrency, // null = 자동(기기 지역)
  }) = _SettingsState;
}

// ── Intent ──

sealed class SettingsIntent {
  const SettingsIntent();
  const factory SettingsIntent.themeModeChanged(ThemeMode mode) =
      _ThemeModeChanged;
  const factory SettingsIntent.localeChanged(Locale? locale) = _LocaleChanged;
  const factory SettingsIntent.displayCurrencyChanged(CurrencyUnit? currency) =
      _DisplayCurrencyChanged;
}

class _ThemeModeChanged extends SettingsIntent {
  final ThemeMode mode;
  const _ThemeModeChanged(this.mode);
}

class _LocaleChanged extends SettingsIntent {
  final Locale? locale;
  const _LocaleChanged(this.locale);
}

class _DisplayCurrencyChanged extends SettingsIntent {
  final CurrencyUnit? currency;
  const _DisplayCurrencyChanged(this.currency);
}

// ── Provider ──
// autoDispose 제외: themeMode를 main.dart에서 항상 구독하므로 앱 생명주기와 동일하게 유지

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);

/// 최종 표시 통화를 제공하는 Provider.
/// 사용자가 명시 선택하면 해당 값, null이면 기기 지역 기반 자동 감지.
final displayCurrencyProvider = Provider<CurrencyUnit>((ref) {
  final settings = ref.watch(settingsViewModelProvider);
  return settings.displayCurrency ?? _detectCurrencyFromDevice();
});

// ── ViewModel ──

const _kThemeModeKey = 'theme_mode';
const _kLocaleKey = 'locale';
const _kDisplayCurrencyKey = 'display_currency';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedTheme = prefs.getString(_kThemeModeKey);
    final savedLocale = prefs.getString(_kLocaleKey);
    final savedCurrency = prefs.getString(_kDisplayCurrencyKey);

    return SettingsState(
      themeMode: switch (savedTheme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: savedLocale != null ? Locale(savedLocale) : null,
      displayCurrency: CurrencyUnit.tryFromCode(savedCurrency),
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
      case _DisplayCurrencyChanged(:final currency):
        state = state.copyWith(displayCurrency: currency);
        final prefs = ref.read(sharedPreferencesProvider);
        if (currency != null) {
          prefs.setString(_kDisplayCurrencyKey, currency.code);
        } else {
          prefs.remove(_kDisplayCurrencyKey);
        }
    }
  }
}

/// 기기 countryCode → CurrencyUnit 매핑.
CurrencyUnit _detectCurrencyFromDevice() {
  final countryCode =
      PlatformDispatcher.instance.locale.countryCode?.toUpperCase();
  return switch (countryCode) {
    'KR' => CurrencyUnit.krw,
    'US' || 'CA' || 'AU' => CurrencyUnit.usd,
    'JP' => CurrencyUnit.jpy,
    'CN' => CurrencyUnit.cny,
    'GB' => CurrencyUnit.gbp,
    'DE' || 'FR' || 'IT' || 'ES' || 'NL' || 'PT' || 'AT' || 'BE' || 'FI' ||
    'IE' ||
    'GR' ||
    'LU' ||
    'SK' ||
    'SI' ||
    'EE' ||
    'LV' ||
    'LT' ||
    'CY' ||
    'MT' =>
      CurrencyUnit.eur,
    _ => CurrencyUnit.usd,
  };
}
