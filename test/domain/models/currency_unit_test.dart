import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/models/currency_unit.dart';

void main() {
  group('CurrencyUnit', () {
    group('code', () {
      test('returns uppercase currency code', () {
        expect(CurrencyUnit.krw.code, 'KRW');
        expect(CurrencyUnit.usd.code, 'USD');
        expect(CurrencyUnit.eur.code, 'EUR');
        expect(CurrencyUnit.jpy.code, 'JPY');
        expect(CurrencyUnit.cny.code, 'CNY');
        expect(CurrencyUnit.gbp.code, 'GBP');
      });
    });

    group('tryFromCode', () {
      test('parses uppercase code', () {
        expect(CurrencyUnit.tryFromCode('KRW'), CurrencyUnit.krw);
        expect(CurrencyUnit.tryFromCode('USD'), CurrencyUnit.usd);
        expect(CurrencyUnit.tryFromCode('EUR'), CurrencyUnit.eur);
        expect(CurrencyUnit.tryFromCode('JPY'), CurrencyUnit.jpy);
        expect(CurrencyUnit.tryFromCode('CNY'), CurrencyUnit.cny);
        expect(CurrencyUnit.tryFromCode('GBP'), CurrencyUnit.gbp);
      });

      test('parses lowercase code', () {
        expect(CurrencyUnit.tryFromCode('krw'), CurrencyUnit.krw);
        expect(CurrencyUnit.tryFromCode('usd'), CurrencyUnit.usd);
      });

      test('returns null for unknown code', () {
        expect(CurrencyUnit.tryFromCode('XYZ'), isNull);
        expect(CurrencyUnit.tryFromCode(''), isNull);
      });

      test('returns null for null input', () {
        expect(CurrencyUnit.tryFromCode(null), isNull);
      });
    });

    test('values has 6 entries', () {
      expect(CurrencyUnit.values.length, 6);
    });
  });
}
