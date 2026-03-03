import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    // ── addCommas ──
    group('addCommas', () {
      test('3자리 이하는 콤마 없음', () {
        expect(NumberFormatter.addCommas('123'), '123');
        expect(NumberFormatter.addCommas('0'), '0');
      });

      test('4자리 이상 천 단위 콤마', () {
        expect(NumberFormatter.addCommas('1234'), '1,234');
        expect(NumberFormatter.addCommas('1234567'), '1,234,567');
      });

      test('음수 처리', () {
        expect(NumberFormatter.addCommas('-1234'), '-1,234');
      });

      test('소수점 포함 시 정수부만 콤마', () {
        expect(NumberFormatter.addCommas('1234.56'), '1,234.56');
        expect(NumberFormatter.addCommas('-1234567.89'), '-1,234,567.89');
      });
    });

    // ── trimTrailingZeros ──
    group('trimTrailingZeros', () {
      test('후행 0 제거', () {
        expect(NumberFormatter.trimTrailingZeros('1.200'), '1.2');
        expect(NumberFormatter.trimTrailingZeros('3.1400'), '3.14');
      });

      test('소수 전체가 0이면 소수점도 제거', () {
        expect(NumberFormatter.trimTrailingZeros('5.000'), '5');
      });

      test('소수점 없으면 그대로', () {
        expect(NumberFormatter.trimTrailingZeros('123'), '123');
      });
    });

    // ── formatScientific ──
    group('formatScientific', () {
      test('큰 값 지수 표기', () {
        expect(NumberFormatter.formatScientific(1.5e15), '1.5e+15');
        expect(NumberFormatter.formatScientific(2.5e10), '2.5e+10');
      });

      test('작은 값 지수 표기', () {
        expect(NumberFormatter.formatScientific(0.00001), '1e-5');
      });
    });

    // ── rawFromDouble ──
    group('rawFromDouble', () {
      test('정수값은 정수 문자열', () {
        expect(NumberFormatter.rawFromDouble(5.0), '5');
        expect(NumberFormatter.rawFromDouble(100.0), '100');
      });

      test('소수값은 후행 0 제거', () {
        expect(NumberFormatter.rawFromDouble(3.14), '3.14');
      });

      test('0은 "0"', () {
        expect(NumberFormatter.rawFromDouble(0), '0');
      });
    });

    // ── formatResult ──
    group('formatResult', () {
      test('정수 결과', () {
        expect(NumberFormatter.formatResult(5.0), '5');
        expect(NumberFormatter.formatResult(100.0), '100');
      });

      test('소수 결과 후행 0 제거', () {
        expect(NumberFormatter.formatResult(3.14), '3.14');
      });

      test('무한대/NaN', () {
        expect(NumberFormatter.formatResult(double.infinity), '정의되지 않음');
        expect(NumberFormatter.formatResult(double.negativeInfinity), '정의되지 않음');
        expect(NumberFormatter.formatResult(double.nan), '정의되지 않음');
      });
    });

    // ── formatAmount ──
    group('formatAmount', () {
      test('0은 "0"', () {
        expect(NumberFormatter.formatAmount(0), '0');
      });

      test('1000 이상은 콤마 + 정수', () {
        expect(NumberFormatter.formatAmount(1234.5), '1,235');
        expect(NumberFormatter.formatAmount(1000000.0), '1,000,000');
      });

      test('1 이상 1000 미만은 소수 2자리', () {
        expect(NumberFormatter.formatAmount(1.5), '1.50');
        expect(NumberFormatter.formatAmount(999.99), '999.99');
      });

      test('1 미만은 소수 4자리', () {
        expect(NumberFormatter.formatAmount(0.1234), '0.1234');
        expect(NumberFormatter.formatAmount(0.0007), '0.0007');
      });
    });

    // ── formatUnitResult ──
    group('formatUnitResult', () {
      test('0은 "0"', () {
        expect(NumberFormatter.formatUnitResult(0), '0');
      });

      test('아주 작은 값은 지수 표기', () {
        final result = NumberFormatter.formatUnitResult(0.00001);
        expect(result, contains('e'));
      });

      test('0.0001~1 범위는 소수점 최대 8자리', () {
        expect(NumberFormatter.formatUnitResult(0.5), '0.5');
        expect(NumberFormatter.formatUnitResult(0.001), '0.001');
      });

      test('매우 큰 값은 지수 표기', () {
        final result = NumberFormatter.formatUnitResult(1e15);
        expect(result, contains('e'));
      });

      test('1,000,000 이상은 정수 + 콤마', () {
        expect(NumberFormatter.formatUnitResult(1234567.0), '1,234,567');
      });

      test('1~1,000,000 범위는 소수점 최대 6자리 + 콤마', () {
        expect(NumberFormatter.formatUnitResult(1234.5), '1,234.5');
      });
    });

    // ── formatTemperature ──
    group('formatTemperature', () {
      test('0은 "0"', () {
        expect(NumberFormatter.formatTemperature(0), '0');
      });

      test('소수점 최대 3자리 + 콤마', () {
        expect(NumberFormatter.formatTemperature(1234.5678), '1,234.568');
        expect(NumberFormatter.formatTemperature(100.0), '100');
      });
    });

    // ── formatInput ──
    group('formatInput', () {
      test('빈 문자열은 "0"', () {
        expect(NumberFormatter.formatInput(''), '0');
      });

      test('정수 콤마 추가', () {
        expect(NumberFormatter.formatInput('1234567'), '1,234,567');
      });

      test('소수점 보존', () {
        expect(NumberFormatter.formatInput('1234.56'), '1,234.56');
      });

      test('음수 처리', () {
        expect(NumberFormatter.formatInput('-1234567'), '-1,234,567');
        expect(NumberFormatter.formatInput('-1234.5'), '-1,234.5');
      });
    });
  });
}
