import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/core/constants/unit_definitions.dart';
import 'package:calcmate/domain/models/unit_definition.dart';
import 'package:calcmate/domain/usecases/convert_unit_usecase.dart';
import 'package:calcmate/domain/utils/number_formatter.dart';

/// _onUnitTapped 시뮬레이션:
/// 1. fromCode에서 input 입력
/// 2. 변환 계산 (rawResults + formatted)
/// 3. toCode 탭 → rawFromDouble로 newInput 생성
/// 4. 재계산
/// 5. formattedInput(isResult=true) = convertedValues[toCode] 확인
/// 6. 왕복: fromCode 값이 원래 input과 같은지 확인
void main() {
  final useCase = ConvertUnitUseCase();

  /// 단위 전환 시뮬레이션 후 결과 반환
  /// Returns: {
  ///   'displayBefore': 탭 전 비활성 표시값,
  ///   'displayAfter': 탭 후 활성 표시값 (=convertedValues[toCode]),
  ///   'roundTrip': 왕복 후 원래 단위 표시값,
  ///   'originalDisplay': 원래 입력의 표시값,
  /// }
  Map<String, String> simulateTap({
    required String categoryCode,
    required String fromCode,
    required String input,
    required String toCode,
    required List<UnitDef> units,
  }) {
    final isTemp = categoryCode == 'temperature';

    // 1단계: 입력값으로 변환 계산
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

    // 비활성 상태에서 toCode의 표시값
    final displayBefore = formatted1[toCode] ?? '0';

    // 2단계: toCode 탭 → rawFromDouble로 newInput 생성
    final rawValue = rawResults1[toCode] ?? 0.0;
    final newInput = NumberFormatter.rawFromDouble(rawValue);

    // 3단계: newInput으로 재계산
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

    // 활성 상태에서 toCode의 표시값 (isResult=true → convertedValues[toCode])
    final displayAfter = formatted2[toCode] ?? '0';

    // 왕복: fromCode의 표시값
    final roundTrip = formatted2[fromCode] ?? '0';

    // 원래 입력의 표시값
    final originalDisplay = isTemp
        ? NumberFormatter.formatTemperature(inputValue)
        : NumberFormatter.formatUnitResult(inputValue);

    return {
      'displayBefore': displayBefore,
      'displayAfter': displayAfter,
      'roundTrip': roundTrip,
      'originalDisplay': originalDisplay,
    };
  }

  group('포커스 이동 시 표시값 일치 테스트', () {
    // ── 길이 ──
    group('길이', () {
      final cat = unitCategories[0]; // 길이

      test('1 cm → in → 포커스 이동 시 값 일치', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'cm', input: '1',
          toCode: 'in', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 cm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']),
            reason: '포커스 이동 시 표시값 불일치');
      });

      test('6666 km → in → 포커스 이동 시 값 일치', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'km', input: '6666',
          toCode: 'in', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 km: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('0.001 mm → mi → 매우 작은 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'mm', input: '0.001',
          toCode: 'mi', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 mm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('999999 m → mm → 큰 값 경계', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'm', input: '999999',
          toCode: 'mm', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1000000 m → mm → 백만 이상', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'm', input: '1000000',
          toCode: 'mm', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 질량 ──
    group('질량', () {
      final cat = unitCategories[1];

      test('100 kg → oz', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'kg', input: '100',
          toCode: 'oz', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 kg: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('0.5 mg → t → 매우 작은 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'mg', input: '0.5',
          toCode: 't', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 온도 ──
    group('온도', () {
      final cat = unitCategories[2];

      test('100 °C → °F', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: '°C', input: '100',
          toCode: '°F', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 °C: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('100.12345 °C → °F → 소수점', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: '°C', input: '100.12345',
          toCode: '°F', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 °C: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('0 K → °C → 절대영도', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'K', input: '0',
          toCode: '°C', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('-272.65 °C → K → 절대영도 근처 (< 1)', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: '°C', input: '-272.65',
          toCode: 'K', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 넓이 ──
    group('넓이', () {
      final cat = unitCategories[3];

      test('10 평 → m²', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: '평', input: '10',
          toCode: 'm²', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 평: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1 m² → ac → 에이커', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'm²', input: '1',
          toCode: 'ac', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 시간 ──
    group('시간', () {
      final cat = unitCategories[4];

      test('1 h → ms → 큰 차이', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'h', input: '1',
          toCode: 'ms', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1 ms → year → 매우 작은 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'ms', input: '1',
          toCode: 'year', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 부피 ──
    group('부피', () {
      final cat = unitCategories[5];

      test('10.5 L → gal', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'L', input: '10.5',
          toCode: 'gal', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 L: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1 mL → m³ → 매우 작은 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'mL', input: '1',
          toCode: 'm³', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 속도 ──
    group('속도', () {
      final cat = unitCategories[6];

      test('360 km/h → m/s → 반복소수', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'km/h', input: '360',
          toCode: 'm/s', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 km/h: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('100 m/s → km/h', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'm/s', input: '100',
          toCode: 'km/h', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 m/s: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 연비 ──
    group('연비', () {
      final cat = unitCategories[7];

      test('33.33 km/L → L/100km → 나눗셈', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'km/L', input: '33.33',
          toCode: 'L/100km', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 km/L: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('10 km/L → mpg(US)', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'km/L', input: '10',
          toCode: 'mpg(US)', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 km/L: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('25 km/L → L/100km → 정수 나눗셈', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'km/L', input: '25',
          toCode: 'L/100km', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 km/L: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 데이터 ──
    group('데이터', () {
      final cat = unitCategories[8];

      test('1 TB → bit → 큰 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'TB', input: '1',
          toCode: 'bit', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 TB: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1 GB → MB', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'GB', input: '1',
          toCode: 'MB', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1 bit → PB → 매우 작은 값', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'bit', input: '1',
          toCode: 'PB', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });

    // ── 압력 ──
    group('압력', () {
      final cat = unitCategories[9];

      test('1 atm → Pa', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'atm', input: '1',
          toCode: 'Pa', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        print('  왕복 atm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });

      test('1.23456 atm → psi', () {
        final r = simulateTap(
          categoryCode: cat.code, fromCode: 'atm', input: '1.23456',
          toCode: 'psi', units: cat.units,
        );
        print('  비활성: ${r['displayBefore']}, 활성: ${r['displayAfter']}');
        expect(r['displayBefore'], equals(r['displayAfter']));
      });
    });
  });

  // ── 왕복 변환 정밀도 테스트 ──
  group('왕복 변환 정밀도', () {
    test('1 cm → in → cm 왕복 시 원래 값 유지', () {
      final cat = unitCategories[0];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'cm', input: '1',
        toCode: 'in', units: cat.units,
      );
      print('  왕복 cm: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['roundTrip'], equals(r['originalDisplay']));
    });

    test('100 °C → °F → °C 왕복', () {
      final cat = unitCategories[2];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: '°C', input: '100',
        toCode: '°F', units: cat.units,
      );
      print('  왕복 °C: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['roundTrip'], equals(r['originalDisplay']));
    });

    test('360 km/h → m/s → km/h 왕복', () {
      final cat = unitCategories[6];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'km/h', input: '360',
        toCode: 'm/s', units: cat.units,
      );
      print('  왕복 km/h: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['roundTrip'], equals(r['originalDisplay']));
    });

    test('33.33 km/L → L/100km → km/L 왕복', () {
      final cat = unitCategories[7];
      final r = simulateTap(
        categoryCode: cat.code, fromCode: 'km/L', input: '33.33',
        toCode: 'L/100km', units: cat.units,
      );
      print('  왕복 km/L: ${r['roundTrip']}, 원래: ${r['originalDisplay']}');
      expect(r['roundTrip'], equals(r['originalDisplay']));
    });
  });
}
