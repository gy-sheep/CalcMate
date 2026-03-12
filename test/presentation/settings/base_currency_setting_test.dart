import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calcmate/core/di/providers.dart';
import 'package:calcmate/presentation/settings/settings_viewmodel.dart';

Future<ProviderContainer> createContainer([
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(instance),
    ],
  );
}

void main() {
  group('환율 기준 통화 설정', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('저장값 없으면 baseCurrency가 null (기기 기본)', () async {
      container = await createContainer();
      final state = container.read(settingsViewModelProvider);
      expect(state.baseCurrency, isNull);
    });

    test('저장값 USD → baseCurrency "USD"', () async {
      container = await createContainer({'default_currency': 'USD'});
      final state = container.read(settingsViewModelProvider);
      expect(state.baseCurrency, 'USD');
    });

    test('저장값 EUR → baseCurrency "EUR"', () async {
      container = await createContainer({'default_currency': 'EUR'});
      final state = container.read(settingsViewModelProvider);
      expect(state.baseCurrency, 'EUR');
    });

    test('baseCurrencyProvider — 저장값 없으면 기기 기반 기본값', () async {
      container = await createContainer();
      final resolved = container.read(baseCurrencyProvider);
      // 테스트 환경 locale en_US → 'USD'
      expect(resolved, 'USD');
    });

    test('baseCurrencyProvider — KRW 저장 시 KRW', () async {
      container = await createContainer({'default_currency': 'KRW'});
      final resolved = container.read(baseCurrencyProvider);
      expect(resolved, 'KRW');
    });

    test('설정에서 기준 통화 변경 → State + SharedPreferences 반영', () async {
      container = await createContainer();
      final vm = container.read(settingsViewModelProvider.notifier);
      vm.handleIntent(const SettingsIntent.baseCurrencyChanged('JPY'));

      expect(container.read(settingsViewModelProvider).baseCurrency, 'JPY');
      expect(container.read(baseCurrencyProvider), 'JPY');
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('default_currency'), 'JPY');
    });

    test('설정에서 기준 통화 다시 변경 → 덮어쓰기', () async {
      container = await createContainer({'default_currency': 'JPY'});
      final vm = container.read(settingsViewModelProvider.notifier);
      vm.handleIntent(const SettingsIntent.baseCurrencyChanged('EUR'));

      expect(container.read(baseCurrencyProvider), 'EUR');
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('default_currency'), 'EUR');
    });

    test('null 전달 → SharedPreferences 키 제거 + 기기 기본값 복귀', () async {
      container = await createContainer({'default_currency': 'GBP'});
      final vm = container.read(settingsViewModelProvider.notifier);
      vm.handleIntent(const SettingsIntent.baseCurrencyChanged(null));

      expect(container.read(settingsViewModelProvider).baseCurrency, isNull);
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('default_currency'), isNull);
      // 기기 기본값으로 복귀 (en_US → USD)
      expect(container.read(baseCurrencyProvider), 'USD');
    });
  });
}
