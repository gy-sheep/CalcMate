import 'package:calcmate/domain/models/unit_definition.dart';
import 'package:calcmate/domain/usecases/convert_unit_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConvertUnitUseCase useCase;

  setUp(() {
    useCase = ConvertUnitUseCase();
  });

  // ── 일반 비율 변환 ──

  group('일반 비율 변환', () {
    const lengthUnits = [
      UnitDef(code: 'mm', label: '밀리미터', ratio: 0.001),
      UnitDef(code: 'cm', label: '센티미터', ratio: 0.01),
      UnitDef(code: 'm', label: '미터', ratio: 1),
      UnitDef(code: 'km', label: '킬로미터', ratio: 1000),
    ];

    test('cm → m 변환', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'cm',
        value: 100,
        units: lengthUnits,
      );
      expect(result['m'], closeTo(1.0, 1e-9));
    });

    test('m → km 변환', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'm',
        value: 1500,
        units: lengthUnits,
      );
      expect(result['km'], closeTo(1.5, 1e-9));
    });

    test('km → mm 변환', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'km',
        value: 1,
        units: lengthUnits,
      );
      expect(result['mm'], closeTo(1000000, 1e-3));
    });

    test('같은 단위 변환은 입력값과 동일', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'm',
        value: 42,
        units: lengthUnits,
      );
      expect(result['m'], closeTo(42, 1e-9));
    });

    test('입력값 0이면 모든 결과 0', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'cm',
        value: 0,
        units: lengthUnits,
      );
      for (final entry in result.entries) {
        expect(entry.value, 0.0, reason: '${entry.key}이 0이어야 함');
      }
    });

    test('모든 단위에 대한 결과를 반환', () {
      final result = useCase.execute(
        categoryCode: 'length',
        fromCode: 'cm',
        value: 100,
        units: lengthUnits,
      );
      expect(result.length, lengthUnits.length);
      expect(result.containsKey('mm'), isTrue);
      expect(result.containsKey('cm'), isTrue);
      expect(result.containsKey('m'), isTrue);
      expect(result.containsKey('km'), isTrue);
    });
  });

  // ── 질량 변환 ──

  group('질량 변환', () {
    const massUnits = [
      UnitDef(code: 'g', label: '그램', ratio: 1),
      UnitDef(code: 'kg', label: '킬로그램', ratio: 1000),
      UnitDef(code: 'lb', label: '파운드', ratio: 453.592),
    ];

    test('kg → lb 변환', () {
      final result = useCase.execute(
        categoryCode: 'mass',
        fromCode: 'kg',
        value: 1,
        units: massUnits,
      );
      expect(result['lb'], closeTo(1000 / 453.592, 1e-4));
    });
  });

  // ── 데이터 변환 (큰 ratio) ──

  group('데이터 변환', () {
    const dataUnits = [
      UnitDef(code: 'B', label: '바이트', ratio: 1),
      UnitDef(code: 'KB', label: '킬로바이트', ratio: 1024),
      UnitDef(code: 'GB', label: '기가바이트', ratio: 1073741824),
    ];

    test('GB → KB 변환', () {
      final result = useCase.execute(
        categoryCode: 'data',
        fromCode: 'GB',
        value: 1,
        units: dataUnits,
      );
      expect(result['KB'], closeTo(1048576, 1e-3));
    });

    test('KB → GB 변환', () {
      final result = useCase.execute(
        categoryCode: 'data',
        fromCode: 'KB',
        value: 1048576,
        units: dataUnits,
      );
      expect(result['GB'], closeTo(1.0, 1e-9));
    });
  });

  // ── 온도 변환 ──

  group('온도 변환', () {
    const tempUnits = [
      UnitDef(code: '°C', label: '섭씨'),
      UnitDef(code: '°F', label: '화씨'),
      UnitDef(code: 'K', label: '켈빈'),
    ];

    test('°C 0 → °F 32', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°C',
        value: 0,
        units: tempUnits,
      );
      expect(result['°F'], closeTo(32, 1e-9));
      expect(result['K'], closeTo(273.15, 1e-9));
    });

    test('°C 100 → °F 212', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°C',
        value: 100,
        units: tempUnits,
      );
      expect(result['°F'], closeTo(212, 1e-9));
      expect(result['K'], closeTo(373.15, 1e-9));
    });

    test('°F 32 → °C 0', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°F',
        value: 32,
        units: tempUnits,
      );
      expect(result['°C'], closeTo(0, 1e-9));
      expect(result['K'], closeTo(273.15, 1e-9));
    });

    test('K 0 → °C -273.15', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: 'K',
        value: 0,
        units: tempUnits,
      );
      expect(result['°C'], closeTo(-273.15, 1e-9));
    });

    test('°C -40 → °F -40 (교차점)', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°C',
        value: -40,
        units: tempUnits,
      );
      expect(result['°F'], closeTo(-40, 1e-9));
    });

    test('같은 단위 변환은 입력값과 동일', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°C',
        value: 37,
        units: tempUnits,
      );
      expect(result['°C'], closeTo(37, 1e-9));
    });
  });

  // ── 연비 변환 ──

  group('연비 변환', () {
    const fuelUnits = [
      UnitDef(code: 'km/L', label: '킬로미터/리터'),
      UnitDef(code: 'L/100km', label: '리터/100킬로미터'),
      UnitDef(code: 'mpg(US)', label: '마일/갤런(US)'),
      UnitDef(code: 'mpg(UK)', label: '마일/갤런(UK)'),
    ];

    test('km/L 10 → L/100km 10', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'km/L',
        value: 10,
        units: fuelUnits,
      );
      expect(result['L/100km'], closeTo(10, 1e-9));
    });

    test('km/L 10 → mpg(US)', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'km/L',
        value: 10,
        units: fuelUnits,
      );
      expect(result['mpg(US)'], closeTo(23.52145, 1e-4));
    });

    test('km/L 10 → mpg(UK)', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'km/L',
        value: 10,
        units: fuelUnits,
      );
      expect(result['mpg(UK)'], closeTo(28.24809, 1e-4));
    });

    test('L/100km 10 → km/L 10', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'L/100km',
        value: 10,
        units: fuelUnits,
      );
      expect(result['km/L'], closeTo(10, 1e-9));
    });

    test('L/100km 5 → mpg(US)', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'L/100km',
        value: 5,
        units: fuelUnits,
      );
      expect(result['mpg(US)'], closeTo(235.2145 / 5, 1e-4));
    });

    test('mpg(US) → km/L', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'mpg(US)',
        value: 23.52145,
        units: fuelUnits,
      );
      expect(result['km/L'], closeTo(23.52145 * 0.425144, 1e-3));
    });

    test('연비 입력값 0이면 모든 결과 0', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'km/L',
        value: 0,
        units: fuelUnits,
      );
      for (final entry in result.entries) {
        expect(entry.value, 0.0, reason: '${entry.key}이 0이어야 함');
      }
    });

    test('같은 단위 변환은 입력값과 동일', () {
      final result = useCase.execute(
        categoryCode: 'fuelEfficiency',
        fromCode: 'km/L',
        value: 15,
        units: fuelUnits,
      );
      expect(result['km/L'], closeTo(15, 1e-9));
    });
  });

  // ── 음수 입력 ──

  group('음수 입력', () {
    const tempUnits = [
      UnitDef(code: '°C', label: '섭씨'),
      UnitDef(code: '°F', label: '화씨'),
      UnitDef(code: 'K', label: '켈빈'),
    ];

    test('음수 온도 변환', () {
      final result = useCase.execute(
        categoryCode: 'temperature',
        fromCode: '°C',
        value: -20,
        units: tempUnits,
      );
      expect(result['°F'], closeTo(-4, 1e-9));
      expect(result['K'], closeTo(253.15, 1e-9));
    });
  });
}
