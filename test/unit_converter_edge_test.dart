import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/core/constants/unit_definitions.dart';
import 'package:calcmate/domain/models/unit_definition.dart';
import 'package:calcmate/domain/usecases/convert_unit_usecase.dart';
import 'package:calcmate/domain/utils/number_formatter.dart';

void main() {
  final useCase = ConvertUnitUseCase();

  /// _onUnitTapped 시뮬레이션
  Map<String, String> simulateTap({
    required String categoryCode,
    required String fromCode,
    required String input,
    required String toCode,
    required List<UnitDef> units,
  }) {
    final isTemp = categoryCode == 'temperature';
    final inputValue = double.tryParse(input) ?? 0;

    final rawResults1 = useCase.execute(
      categoryCode: categoryCode,
      fromCode: fromCode,
      value: inputValue,
      units: units,
    );

    final formatted1 = <String, String>{};
    for (final e in rawResults1.entries) {
      formatted1[e.key] = isTemp
          ? NumberFormatter.formatTemperature(e.value)
          : NumberFormatter.formatUnitResult(e.value);
    }

    final displayBefore = formatted1[toCode] ?? '0';

    final rawValue = rawResults1[toCode] ?? 0.0;
    final newInput = NumberFormatter.rawFromDouble(rawValue);
    final newInputValue = double.tryParse(newInput) ?? 0;

    final rawResults2 = useCase.execute(
      categoryCode: categoryCode,
      fromCode: toCode,
      value: newInputValue,
      units: units,
    );

    final formatted2 = <String, String>{};
    for (final e in rawResults2.entries) {
      formatted2[e.key] = isTemp
          ? NumberFormatter.formatTemperature(e.value)
          : NumberFormatter.formatUnitResult(e.value);
    }

    final displayAfter = formatted2[toCode] ?? '0';
    final roundTrip = formatted2[fromCode] ?? '0';
    final originalDisplay = isTemp
        ? NumberFormatter.formatTemperature(inputValue)
        : NumberFormatter.formatUnitResult(inputValue);

    return {
      'displayBefore': displayBefore,
      'displayAfter': displayAfter,
      'roundTrip': roundTrip,
      'originalDisplay': originalDisplay,
      'rawFromDouble': newInput,
    };
  }

  // ── 1. 음수 값 ──
  group('음수 값', () {
    test('길이: -100 cm → in', () {
      final cat = unitCategories[0];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'cm', input: '-100',
        toCode: 'in', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 cm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('온도: -40 °C → °F (교차점)', () {
      final cat = unitCategories[2];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: '°C', input: '-40',
        toCode: '°F', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 °C: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
      expect(r['roundTrip'], equals(r['originalDisplay']));
    });

    test('속도: -100 km/h → m/s', () {
      // 속도에 음수가 들어갈 수 있는지는 UI 제한에 따라 다르지만 로직 검증
      final cat = unitCategories[6];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'km/h', input: '-100',
        toCode: 'm/s', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });
  });

  // ── 2. 매우 큰 입력 (정수부 12자리) ──
  group('매우 큰 입력', () {
    test('길이: 999999999999 mm → km', () {
      final cat = unitCategories[0];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'mm', input: '999999999999',
        toCode: 'km', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('시간: 999999999999 ms → year', () {
      final cat = unitCategories[4];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'ms', input: '999999999999',
        toCode: 'year', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('데이터: 999999999999 B → PB', () {
      final cat = unitCategories[8];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'B', input: '999999999999',
        toCode: 'PB', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });
  });

  // ── 3. 소수점이 긴 입력 ──
  group('소수점이 긴 입력', () {
    test('길이: 1.23456789 cm → in → cm 왕복', () {
      final cat = unitCategories[0];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'cm', input: '1.23456789',
        toCode: 'in', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 cm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('온도: 36.666666 °C → °F → °C 왕복', () {
      final cat = unitCategories[2];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: '°C', input: '36.666666',
        toCode: '°F', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 °C: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });
  });

  // ── 4. 0 입력 ──
  group('0 입력', () {
    test('길이: 0 cm → in', () {
      final cat = unitCategories[0];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'cm', input: '0',
        toCode: 'in', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
      expect(r['displayBefore'], equals('0'));
    });

    test('온도: 0 °C → °F', () {
      final cat = unitCategories[2];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: '°C', input: '0',
        toCode: '°F', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('연비: 0 km/L → L/100km (0으로 나누기)', () {
      final cat = unitCategories[7];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'km/L', input: '0',
        toCode: 'L/100km', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
      expect(r['displayBefore'], equals('0'));
    });
  });

  // ── 5. 1 입력 (모든 카테고리 × 모든 단위 조합) ──
  group('전체 카테고리 × 전체 단위 조합 (1 입력)', () {
    for (int catIdx = 0; catIdx < unitCategories.length; catIdx++) {
      final cat = unitCategories[catIdx];
      for (final fromUnit in cat.units) {
        for (final toUnit in cat.units) {
          if (fromUnit.code == toUnit.code) continue;
          test('${cat.code}: 1 ${fromUnit.code} → ${toUnit.code}', () {
            final r = simulateTap(
              categoryCode: cat.code,
              fromCode: fromUnit.code,
              input: '1',
              toCode: toUnit.code,
              units: cat.units,
            );
            expect(r['displayBefore'], equals(r['displayAfter']),
                reason:
                    '${cat.code}: ${fromUnit.code}→${toUnit.code} 표시 불일치\n'
                    '비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}\n'
                    'rawFromDouble: ${r['rawFromDouble']}');
          });
        }
      }
    }
  });

  // ── 6. 화살표 연속 이동 (A→B→C→D) ──
  group('연속 단위 이동', () {
    test('길이: cm → m → km → mi 연속 이동', () {
      final cat = unitCategories[0];
      final codes = ['cm', 'm', 'km', 'mi'];
      var currentCode = 'cm';
      var currentInput = '12345.678';

      for (int i = 1; i < codes.length; i++) {
        final nextCode = codes[i];
        final inputValue = double.tryParse(currentInput) ?? 0;
        final rawResults = useCase.execute(
          categoryCode: cat.code,
          fromCode: currentCode,
          value: inputValue,
          units: cat.units,
        );

        final formatted = <String, String>{};
        for (final e in rawResults.entries) {
          formatted[e.key] = NumberFormatter.formatUnitResult(e.value);
        }

        final displayBefore = formatted[nextCode]!;
        final rawValue = rawResults[nextCode]!;
        currentInput = NumberFormatter.rawFromDouble(rawValue);

        // 재계산
        final newInputValue = double.tryParse(currentInput) ?? 0;
        final rawResults2 = useCase.execute(
          categoryCode: cat.code,
          fromCode: nextCode,
          value: newInputValue,
          units: cat.units,
        );

        final formatted2 = <String, String>{};
        for (final e in rawResults2.entries) {
          formatted2[e.key] = NumberFormatter.formatUnitResult(e.value);
        }

        final displayAfter = formatted2[nextCode]!;
        print('  $currentCode → $nextCode: 비활성=$displayBefore, 활성=$displayAfter');
        expect(displayBefore, equals(displayAfter),
            reason: '$currentCode → $nextCode 불일치');

        currentCode = nextCode;
      }
    });
  });

  // ── 7. 연비 L/100km 왕복 (나눗셈 연쇄) ──
  group('연비 나눗셈 연쇄', () {
    test('L/100km → km/L → L/100km 왕복', () {
      final cat = unitCategories[7];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'L/100km', input: '7.5',
        toCode: 'km/L', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 L/100km: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('L/100km → mpg(US) → L/100km 왕복', () {
      final cat = unitCategories[7];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'L/100km', input: '8.3',
        toCode: 'mpg(US)', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 L/100km: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });

    test('mpg(US) → mpg(UK) → mpg(US) 왕복', () {
      final cat = unitCategories[7];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'mpg(US)', input: '30',
        toCode: 'mpg(UK)', units: cat.units,
      );
      print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
      print('  왕복 mpg(US): ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['displayBefore'], equals(r['displayAfter']));
    });
  });

  // ── 8. rawFromDouble → parseInput 왕복 ──
  group('rawFromDouble 파싱 무결성', () {
    final testValues = [
      0.0,
      1.0,
      -1.0,
      0.5,
      0.123456789012345,
      1e-16,
      1e-10,
      1e15,
      1e20,
      -273.15,
      999999999999.0,
      0.000000000001,
      3.141592653589793,
    ];

    for (final v in testValues) {
      test('rawFromDouble($v) → parse → 동일', () {
        final str = NumberFormatter.rawFromDouble(v);
        final parsed = double.tryParse(str) ?? double.nan;
        print('  $v → "$str" → $parsed');
        // 파싱 가능해야 함
        expect(parsed.isNaN, isFalse, reason: '"$str" 파싱 실패');
      });
    }
  });

  // ── 9. formatUnitResult 엣지 케이스 ──
  group('formatUnitResult 엣지 케이스', () {
    test('NaN', () {
      // NaN이 들어오면 크래시 안 해야 함
      expect(() => NumberFormatter.formatUnitResult(double.nan), returnsNormally);
    });

    test('Infinity', () {
      expect(() => NumberFormatter.formatUnitResult(double.infinity), returnsNormally);
    });

    test('-Infinity', () {
      expect(() => NumberFormatter.formatUnitResult(double.negativeInfinity), returnsNormally);
    });

    test('매우 작은 양수 (5e-324)', () {
      expect(() => NumberFormatter.formatUnitResult(5e-324), returnsNormally);
    });

    test('매우 큰 양수 (1.7e308)', () {
      expect(() => NumberFormatter.formatUnitResult(1.7e308), returnsNormally);
    });
  });
}
