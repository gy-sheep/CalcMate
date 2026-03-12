import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/core/l10n/currency_formatter.dart';
import 'package:calcmate/domain/models/currency_unit.dart';

void main() {
  group('CurrencyFormatter', () {
    // ── KRW 전용 (기존 테스트 유지) ──

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

    // ── CurrencyUnit 기반 ──

    group('symbol', () {
      test('KRW → ₩', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.krw, const Locale('ko')), '₩');
        expect(CurrencyFormatter.symbol(CurrencyUnit.krw, const Locale('en')), '₩');
      });

      test('USD → \$', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.usd, const Locale('ko')), '\$');
        expect(CurrencyFormatter.symbol(CurrencyUnit.usd, const Locale('en')), '\$');
      });

      test('EUR → €', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.eur, const Locale('ko')), '€');
      });

      test('JPY → ¥', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.jpy, const Locale('ko')), '¥');
      });

      test('CNY → ¥ (ko), CN¥ (en)', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.cny, const Locale('ko')), '¥');
        expect(CurrencyFormatter.symbol(CurrencyUnit.cny, const Locale('en')), 'CN¥');
      });

      test('GBP → £', () {
        expect(CurrencyFormatter.symbol(CurrencyUnit.gbp, const Locale('ko')), '£');
      });
    });

    group('unitLabel', () {
      test('KRW ko → 원', () {
        expect(CurrencyFormatter.unitLabel(CurrencyUnit.krw, const Locale('ko')), '원');
      });

      test('KRW en → KRW', () {
        expect(CurrencyFormatter.unitLabel(CurrencyUnit.krw, const Locale('en')), 'KRW');
      });

      test('USD → USD regardless of locale', () {
        expect(CurrencyFormatter.unitLabel(CurrencyUnit.usd, const Locale('ko')), 'USD');
        expect(CurrencyFormatter.unitLabel(CurrencyUnit.usd, const Locale('en')), 'USD');
      });

      test('all non-KRW return code', () {
        for (final unit in CurrencyUnit.values) {
          if (unit == CurrencyUnit.krw) continue;
          expect(CurrencyFormatter.unitLabel(unit, const Locale('ko')), unit.code);
        }
      });
    });

    group('format', () {
      test('KRW ko → 접미사 스타일', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.krw, const Locale('ko')),
          '12,500 원',
        );
      });

      test('KRW en → 접두사 스타일', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.krw, const Locale('en')),
          '₩12,500',
        );
      });

      test('USD → \$ prefix', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.usd, const Locale('ko')),
          '\$12,500',
        );
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.usd, const Locale('en')),
          '\$12,500',
        );
      });

      test('EUR → € prefix', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.eur, const Locale('en')),
          '€12,500',
        );
      });

      test('JPY → ¥ prefix', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.jpy, const Locale('en')),
          '¥12,500',
        );
      });

      test('CNY ko → ¥ prefix, en → CN¥ prefix', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.cny, const Locale('ko')),
          '¥12,500',
        );
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.cny, const Locale('en')),
          'CN¥12,500',
        );
      });

      test('GBP → £ prefix', () {
        expect(
          CurrencyFormatter.format('12,500', CurrencyUnit.gbp, const Locale('en')),
          '£12,500',
        );
      });

      test('zero value', () {
        expect(
          CurrencyFormatter.format('0', CurrencyUnit.usd, const Locale('en')),
          '\$0',
        );
      });
    });
  });
}
