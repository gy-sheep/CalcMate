import '../models/unit_definition.dart';

class ConvertUnitUseCase {
  /// [fromCode] 단위의 [value]를 [units] 내 모든 단위로 변환한 결과를 반환한다.
  /// 온도/연비는 특수 공식, 나머지는 비율 기반.
  Map<String, double> execute({
    required String categoryName,
    required String fromCode,
    required double value,
    required List<UnitDef> units,
  }) {
    if (categoryName == '온도') return _convertTemperature(fromCode, value, units);
    if (categoryName == '연비') return _convertFuelEfficiency(fromCode, value, units);

    if (value == 0) {
      return {for (final u in units) u.code: 0.0};
    }

    return _convertByRatio(fromCode, value, units);
  }

  Map<String, double> _convertByRatio(
    String fromCode,
    double value,
    List<UnitDef> units,
  ) {
    final fromUnit = units.firstWhere((u) => u.code == fromCode);
    final fromRatio = fromUnit.ratio!;
    final result = <String, double>{};
    for (final u in units) {
      result[u.code] = value * (fromRatio / u.ratio!);
    }
    return result;
  }

  // ── 온도 ──

  Map<String, double> _convertTemperature(
    String fromCode,
    double value,
    List<UnitDef> units,
  ) {
    // 먼저 °C 기준값으로 변환
    final celsius = switch (fromCode) {
      '°C' => value,
      '°F' => (value - 32) * 5 / 9,
      'K' => value - 273.15,
      _ => value,
    };

    final result = <String, double>{};
    for (final u in units) {
      result[u.code] = switch (u.code) {
        '°C' => celsius,
        '°F' => celsius * 9 / 5 + 32,
        'K' => celsius + 273.15,
        _ => 0.0,
      };
    }
    return result;
  }

  // ── 연비 ──

  Map<String, double> _convertFuelEfficiency(
    String fromCode,
    double value,
    List<UnitDef> units,
  ) {
    if (value == 0) {
      return {for (final u in units) u.code: 0.0};
    }

    // 먼저 km/L 기준값으로 변환
    final kmPerL = switch (fromCode) {
      'km/L' => value,
      'L/100km' => 100 / value,
      'mpg(US)' => value * 0.425144,
      'mpg(UK)' => value * 0.354006,
      _ => value,
    };

    final result = <String, double>{};
    for (final u in units) {
      result[u.code] = switch (u.code) {
        'km/L' => kmPerL,
        'L/100km' => kmPerL == 0 ? 0.0 : 100 / kmPerL,
        'mpg(US)' => kmPerL * 2.352145,
        'mpg(UK)' => kmPerL * 2.824809,
        _ => 0.0,
      };
    }
    return result;
  }
}
