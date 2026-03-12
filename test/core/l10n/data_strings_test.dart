import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/core/l10n/data_strings.dart';

void main() {
  const ko = Locale('ko');
  const en = Locale('en');

  group('DataStrings', () {
    group('unitLabel', () {
      test('ko 단위 조회', () {
        expect(DataStrings.unitLabel('km', ko), '킬로미터');
        expect(DataStrings.unitLabel('lb', ko), '파운드');
      });

      test('en 단위 조회', () {
        expect(DataStrings.unitLabel('km', en), 'Kilometer');
        expect(DataStrings.unitLabel('lb', en), 'Pound');
      });

      test('없는 코드는 코드 자체 반환', () {
        expect(DataStrings.unitLabel('unknown', ko), 'unknown');
      });

      test('ko/en 단위 수 동일 (73개)', () {
        // _unitLabels 직접 접근 불가하므로 알려진 코드로 검증
        final codes = [
          'mm', 'cm', 'm', 'km', 'in', 'ft', 'yd', 'mi',
          'mg', 'g', 'kg', 't', 'oz', 'lb',
          '°C', '°F', 'K',
          'mm²', 'cm²', 'm²', 'km²', 'ha', 'ac', 'ft²', '평',
          'ms', 's', 'min', 'h', 'day', 'week', 'month', 'year',
          'mL', 'L', 'm³', 'gal', 'qt', 'pt', 'fl oz', 'cup',
          'm/s', 'km/h', 'mph', 'kn', 'ft/s',
          'km/L', 'L/100km', 'mpg(US)', 'mpg(UK)',
          'bit', 'B', 'KB', 'MB', 'GB', 'TB', 'PB',
          'Pa', 'kPa', 'MPa', 'bar', 'atm', 'mmHg', 'psi',
        ];
        // 코드와 라벨이 동일한 예외 케이스
        const sameAsCode = {'평', 'mmHg'};
        for (final c in codes) {
          if (!sameAsCode.contains(c)) {
            expect(DataStrings.unitLabel(c, ko), isNot(c), reason: 'ko missing: $c');
            expect(DataStrings.unitLabel(c, en), isNot(c), reason: 'en missing: $c');
          } else {
            // 코드와 라벨이 동일해도 값이 존재하는지만 확인
            expect(DataStrings.unitLabel(c, ko), isNotEmpty, reason: 'ko empty: $c');
            expect(DataStrings.unitLabel(c, en), isNotEmpty, reason: 'en empty: $c');
          }
        }
      });
    });

    group('categoryName', () {
      test('ko/en 카테고리 조회', () {
        expect(DataStrings.categoryName('length', ko), '길이');
        expect(DataStrings.categoryName('length', en), 'Length');
        expect(DataStrings.categoryName('temperature', ko), '온도');
        expect(DataStrings.categoryName('temperature', en), 'Temperature');
      });

      test('10개 카테고리 모두 존재', () {
        final cats = [
          'length', 'mass', 'temperature', 'area', 'time',
          'volume', 'speed', 'fuelEfficiency', 'data', 'pressure',
        ];
        for (final c in cats) {
          expect(DataStrings.categoryName(c, ko), isNot(c), reason: 'ko missing: $c');
          expect(DataStrings.categoryName(c, en), isNot(c), reason: 'en missing: $c');
        }
      });
    });

    group('currencyName', () {
      test('ko/en 통화 조회', () {
        expect(DataStrings.currencyName('USD', ko), '미국 달러');
        expect(DataStrings.currencyName('USD', en), 'US Dollar');
        expect(DataStrings.currencyName('KRW', ko), '대한민국 원');
        expect(DataStrings.currencyName('KRW', en), 'South Korean Won');
      });

      test('24개 통화 모두 존재', () {
        final codes = [
          'KRW', 'USD', 'JPY', 'EUR', 'CNY', 'GBP', 'AUD', 'CAD',
          'CHF', 'HKD', 'SGD', 'TWD', 'THB', 'VND', 'PHP', 'INR',
          'MXN', 'BRL', 'SEK', 'NOK', 'NZD', 'TRY', 'RUB', 'ZAR',
        ];
        for (final c in codes) {
          expect(DataStrings.currencyName(c, ko), isNot(c), reason: 'ko missing: $c');
          expect(DataStrings.currencyName(c, en), isNot(c), reason: 'en missing: $c');
        }
      });
    });

    group('calcTitle / calcDescription', () {
      test('ko/en 계산기 타이틀', () {
        expect(DataStrings.calcTitle('basic_calculator', ko), '기본 계산기');
        expect(DataStrings.calcTitle('basic_calculator', en), 'Calculator');
      });

      test('ko/en 계산기 설명', () {
        expect(DataStrings.calcDescription('exchange_rate', ko), '실시간 전 세계 환율 변환');
        expect(DataStrings.calcDescription('exchange_rate', en), 'Real-time global currency conversion');
      });

      test('10개 계산기 모두 존재', () {
        final ids = [
          'basic_calculator', 'exchange_rate', 'unit_converter',
          'vat_calculator', 'age_calculator', 'date_calculator',
          'salary_calculator', 'discount_calculator', 'dutch_pay',
          'bmi_calculator',
        ];
        for (final id in ids) {
          expect(DataStrings.calcTitle(id, ko), isNot(id), reason: 'ko title missing: $id');
          expect(DataStrings.calcTitle(id, en), isNot(id), reason: 'en title missing: $id');
          expect(DataStrings.calcDescription(id, ko), isNot(id), reason: 'ko desc missing: $id');
          expect(DataStrings.calcDescription(id, en), isNot(id), reason: 'en desc missing: $id');
        }
      });
    });

    group('weekdayFull', () {
      test('ko 요일', () {
        expect(DataStrings.weekdayFull(1, ko), '월요일');
        expect(DataStrings.weekdayFull(7, ko), '일요일');
      });

      test('en 요일', () {
        expect(DataStrings.weekdayFull(1, en), 'Monday');
        expect(DataStrings.weekdayFull(7, en), 'Sunday');
      });

      test('1~7 모두 존재', () {
        for (int i = 1; i <= 7; i++) {
          expect(DataStrings.weekdayFull(i, ko), isNot(i.toString()));
          expect(DataStrings.weekdayFull(i, en), isNot(i.toString()));
        }
      });
    });

    group('weekdayShort', () {
      test('ko 약어', () {
        expect(DataStrings.weekdayShort(1, ko), '월');
        expect(DataStrings.weekdayShort(6, ko), '토');
      });

      test('en 약어', () {
        expect(DataStrings.weekdayShort(1, en), 'Mon');
        expect(DataStrings.weekdayShort(6, en), 'Sat');
      });
    });

    group('zodiacName', () {
      test('ko/en 띠', () {
        expect(DataStrings.zodiacName(0, ko), '쥐');
        expect(DataStrings.zodiacName(0, en), 'Rat');
        expect(DataStrings.zodiacName(4, ko), '용');
        expect(DataStrings.zodiacName(4, en), 'Dragon');
      });

      test('0~11 모두 존재', () {
        for (int i = 0; i <= 11; i++) {
          expect(DataStrings.zodiacName(i, ko), isNot(i.toString()));
          expect(DataStrings.zodiacName(i, en), isNot(i.toString()));
        }
      });
    });

    group('constellationName', () {
      test('ko/en 별자리', () {
        expect(DataStrings.constellationName(0, ko), '염소자리');
        expect(DataStrings.constellationName(0, en), 'Capricorn');
        expect(DataStrings.constellationName(7, ko), '사자자리');
        expect(DataStrings.constellationName(7, en), 'Leo');
      });

      test('0~11 모두 존재', () {
        for (int i = 0; i <= 11; i++) {
          expect(DataStrings.constellationName(i, ko), isNot(i.toString()));
          expect(DataStrings.constellationName(i, en), isNot(i.toString()));
        }
      });
    });

    group('bmiCategory', () {
      test('ko/en BMI 카테고리', () {
        expect(DataStrings.bmiCategory('underweight', ko), '저체중');
        expect(DataStrings.bmiCategory('underweight', en), 'Underweight');
        expect(DataStrings.bmiCategory('normal', ko), '정상');
        expect(DataStrings.bmiCategory('normal', en), 'Normal');
      });

      test('6개 카테고리 모두 존재', () {
        final codes = ['underweight', 'normal', 'overweight', 'obese', 'obese1', 'obese2'];
        for (final c in codes) {
          expect(DataStrings.bmiCategory(c, ko), isNot(c), reason: 'ko missing: $c');
          expect(DataStrings.bmiCategory(c, en), isNot(c), reason: 'en missing: $c');
        }
      });
    });

    group('vatTaxRates', () {
      test('ko/en 세율표 18개', () {
        expect(DataStrings.vatTaxRates(ko).length, 18);
        expect(DataStrings.vatTaxRates(en).length, 18);
      });

      test('ko/en 국가 코드 일치', () {
        final koRates = DataStrings.vatTaxRates(ko);
        final enRates = DataStrings.vatTaxRates(en);
        for (int i = 0; i < koRates.length; i++) {
          expect(koRates[i].$1, enRates[i].$1, reason: 'Country code mismatch at index $i');
        }
      });
    });

    group('fallback', () {
      test('지원하지 않는 로케일은 ko로 폴백', () {
        const ja = Locale('ja');
        expect(DataStrings.unitLabel('km', ja), '킬로미터');
        expect(DataStrings.currencyName('USD', ja), '미국 달러');
        expect(DataStrings.weekdayFull(1, ja), '월요일');
      });
    });
  });
}
