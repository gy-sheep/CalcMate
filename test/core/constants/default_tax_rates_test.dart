import 'package:calcmate/core/constants/default_tax_rates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getDefaultTaxRateForCountry', () {
    test('한국 (KR) → 10%', () {
      expect(getDefaultTaxRateForCountry('KR'), 10);
    });

    test('일본 (JP) → 10%', () {
      expect(getDefaultTaxRateForCountry('JP'), 10);
    });

    test('영국 (GB) → 20%', () {
      expect(getDefaultTaxRateForCountry('GB'), 20);
    });

    test('독일 (DE) → 19%', () {
      expect(getDefaultTaxRateForCountry('DE'), 19);
    });

    test('이탈리아 (IT) → 22%', () {
      expect(getDefaultTaxRateForCountry('IT'), 22);
    });

    test('캐나다 (CA) → 5%', () {
      expect(getDefaultTaxRateForCountry('CA'), 5);
    });

    test('싱가포르 (SG) → 9%', () {
      expect(getDefaultTaxRateForCountry('SG'), 9);
    });

    test('매핑 없는 국가 → fallback 10%', () {
      expect(getDefaultTaxRateForCountry('ZZ'), kDefaultTaxRate);
    });

    test('null → fallback 10%', () {
      expect(getDefaultTaxRateForCountry(null), kDefaultTaxRate);
    });

    test('소문자 입력 → fallback (대소문자 구분)', () {
      expect(getDefaultTaxRateForCountry('kr'), kDefaultTaxRate);
    });
  });

  group('kCountryTaxRates', () {
    test('15개국 매핑 존재', () {
      expect(kCountryTaxRates.length, 15);
    });

    test('kDefaultTaxRate 상수 = 10', () {
      expect(kDefaultTaxRate, 10);
    });
  });
}
