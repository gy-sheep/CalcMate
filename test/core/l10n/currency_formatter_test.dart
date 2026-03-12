import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/core/l10n/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('krwUnit', () {
      test('ko → 원', () {
        expect(CurrencyFormatter.krwUnit(const Locale('ko')), '원');
      });

      test('en → KRW', () {
        expect(CurrencyFormatter.krwUnit(const Locale('en')), 'KRW');
      });

      test('unsupported locale falls back to en', () {
        expect(CurrencyFormatter.krwUnit(const Locale('ja')), 'KRW');
      });
    });

    group('formatKrw', () {
      test('ko → 접미사 스타일', () {
        expect(
          CurrencyFormatter.formatKrw('12,500', const Locale('ko')),
          '12,500 원',
        );
      });

      test('en → 접두사 스타일', () {
        expect(
          CurrencyFormatter.formatKrw('12,500', const Locale('en')),
          '₩12,500',
        );
      });

      test('zero value', () {
        expect(
          CurrencyFormatter.formatKrw('0', const Locale('ko')),
          '0 원',
        );
        expect(
          CurrencyFormatter.formatKrw('0', const Locale('en')),
          '₩0',
        );
      });
    });
  });
}
