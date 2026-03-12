import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ARB 키 일관성', () {
    late Map<String, dynamic> ko;
    late Map<String, dynamic> en;

    setUpAll(() {
      ko = jsonDecode(File('lib/l10n/app_ko.arb').readAsStringSync())
          as Map<String, dynamic>;
      en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
    });

    test('ko/en 키 수 동일', () {
      final koKeys = ko.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      expect(koKeys.length, enKeys.length,
          reason: 'ko: ${koKeys.length}, en: ${enKeys.length}');
    });

    test('ko에만 있는 키 없음', () {
      final koKeys = ko.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      final onlyKo = koKeys.difference(enKeys);
      expect(onlyKo, isEmpty, reason: 'Only in ko: $onlyKo');
    });

    test('en에만 있는 키 없음', () {
      final koKeys = ko.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      final onlyEn = enKeys.difference(koKeys);
      expect(onlyEn, isEmpty, reason: 'Only in en: $onlyEn');
    });

    test('파라미터 키(@key)에 대응하는 메시지 키 존재', () {
      for (final entry in ko.entries) {
        if (entry.key.startsWith('@') && entry.key != '@@locale') {
          final msgKey = entry.key.substring(1);
          expect(ko.containsKey(msgKey), isTrue,
              reason: 'ko: @$msgKey metadata without message key');
        }
      }
      for (final entry in en.entries) {
        if (entry.key.startsWith('@') && entry.key != '@@locale') {
          final msgKey = entry.key.substring(1);
          expect(en.containsKey(msgKey), isTrue,
              reason: 'en: @$msgKey metadata without message key');
        }
      }
    });

    test('모든 값이 비어있지 않음', () {
      for (final entry in ko.entries) {
        if (!entry.key.startsWith('@')) {
          expect((entry.value as String).isNotEmpty, isTrue,
              reason: 'ko: ${entry.key} is empty');
        }
      }
      for (final entry in en.entries) {
        if (!entry.key.startsWith('@')) {
          expect((entry.value as String).isNotEmpty, isTrue,
              reason: 'en: ${entry.key} is empty');
        }
      }
    });
  });
}
