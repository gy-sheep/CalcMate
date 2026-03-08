import 'dart:ui';

// ── BMI 판정 기준 ──────────────────────────────────────────────────────────────

enum BmiStandard { global, asian }

class BmiCategoryDef {
  const BmiCategoryDef({
    required this.label,
    required this.rangeLabel,
    required this.color,
    required this.min,
    required this.max,
  });

  final String label;
  final String rangeLabel;
  final Color color;
  final double min;
  final double max; // 마지막 범주는 double.infinity

  bool contains(double bmi) => bmi >= min && bmi < max;
}

const kGlobalCategories = [
  BmiCategoryDef(
    label: '저체중',
    rangeLabel: '18.5 미만',
    color: Color(0xFF5B9BD5),
    min: 0,
    max: 18.5,
  ),
  BmiCategoryDef(
    label: '정상 체중',
    rangeLabel: '18.5 – 24.9',
    color: Color(0xFF4CAF50),
    min: 18.5,
    max: 25.0,
  ),
  BmiCategoryDef(
    label: '과체중',
    rangeLabel: '25.0 – 29.9',
    color: Color(0xFFFF9800),
    min: 25.0,
    max: 30.0,
  ),
  BmiCategoryDef(
    label: '비만',
    rangeLabel: '30.0 이상',
    color: Color(0xFFF44336),
    min: 30.0,
    max: double.infinity,
  ),
];

const kAsianCategories = [
  BmiCategoryDef(
    label: '저체중',
    rangeLabel: '18.5 미만',
    color: Color(0xFF5B9BD5),
    min: 0,
    max: 18.5,
  ),
  BmiCategoryDef(
    label: '정상',
    rangeLabel: '18.5 – 22.9',
    color: Color(0xFF4CAF50),
    min: 18.5,
    max: 23.0,
  ),
  BmiCategoryDef(
    label: '과체중',
    rangeLabel: '23.0 – 24.9',
    color: Color(0xFFFFCC02),
    min: 23.0,
    max: 25.0,
  ),
  BmiCategoryDef(
    label: '비만 1단계',
    rangeLabel: '25.0 – 29.9',
    color: Color(0xFFFF9800),
    min: 25.0,
    max: 30.0,
  ),
  BmiCategoryDef(
    label: '비만 2단계',
    rangeLabel: '30.0 이상',
    color: Color(0xFFF44336),
    min: 30.0,
    max: double.infinity,
  ),
];

const _kAsianCountryCodes = {
  'KR', 'JP', 'CN', 'TW', 'HK', 'MO', 'SG',
  'MY', 'TH', 'VN', 'PH', 'ID', 'KH', 'MM', 'BD',
};

// ── BmiResult ──────────────────────────────────────────────────────────────────

class BmiResult {
  const BmiResult({
    required this.bmi,
    required this.category,
    required this.categories,
    required this.healthyWeightMinKg,
    required this.healthyWeightMaxKg,
    required this.isInHealthyRange,
    required this.standard,
  });

  final double bmi;
  final BmiCategoryDef category;
  final List<BmiCategoryDef> categories;
  final double healthyWeightMinKg;
  final double healthyWeightMaxKg;
  final bool isInHealthyRange;
  final BmiStandard standard;
}

// ── UseCase ────────────────────────────────────────────────────────────────────

class BmiCalculateUseCase {
  BmiResult calculate({
    required double heightCm,
    required double weightKg,
    required BmiStandard standard,
  }) {
    final hm = heightCm / 100;
    final bmi = hm <= 0 ? 0.0 : weightKg / (hm * hm);

    final categories =
        standard == BmiStandard.asian ? kAsianCategories : kGlobalCategories;
    final category =
        categories.lastWhere((c) => bmi >= c.min, orElse: () => categories.first);

    // 정상 범주 기반 건강 체중 역산
    final normal = categories.firstWhere((c) => c.label.startsWith('정상'));
    final hmSq = hm * hm;
    final healthyMin = normal.min * hmSq;
    final maxBmi = normal.max == double.infinity ? 24.9 : normal.max;
    final healthyMax = maxBmi * hmSq;
    final isInRange = weightKg >= healthyMin && weightKg <= healthyMax;

    return BmiResult(
      bmi: bmi,
      category: category,
      categories: categories,
      healthyWeightMinKg: healthyMin,
      healthyWeightMaxKg: healthyMax,
      isInHealthyRange: isInRange,
      standard: standard,
    );
  }

  /// 국가코드로 BMI 판정 기준 결정
  static BmiStandard standardForCountryCode(String? code) {
    if (code == null) return BmiStandard.global;
    return _kAsianCountryCodes.contains(code)
        ? BmiStandard.asian
        : BmiStandard.global;
  }

  /// 국가코드로 기본 단위계 결정 (US → imperial, 그 외 → metric)
  static bool defaultIsMetric(String? countryCode) {
    return countryCode != 'US';
  }

  /// cm → ft·in 표시 문자열
  static String heightToImperial(double cm) {
    final totalIn = cm / 2.54;
    final ft = totalIn ~/ 12;
    final inch = (totalIn % 12).round();
    return '$ft ft $inch in';
  }

  /// kg → lb 표시 문자열
  static String weightToImperial(double kg) {
    return '${(kg * 2.20462).toStringAsFixed(1)} lb';
  }
}
