import 'dart:ui';

// ── BMI 카테고리 코드 ──────────────────────────────────────────────────────────

enum BmiCategoryCode {
  underweight,
  normal,
  overweight,
  obese,
  obese1,
  obese2,
}

// ── BMI 판정 기준 ──────────────────────────────────────────────────────────────

enum BmiStandard { global, asian }

class BmiCategoryDef {
  const BmiCategoryDef({
    required this.code,
    required this.color,
    required this.min,
    required this.max,
  });

  final BmiCategoryCode code;
  final Color color;
  final double min;
  final double max; // 마지막 범주는 double.infinity

  bool contains(double bmi) => bmi >= min && bmi < max;

  /// 정상 범주 여부
  bool get isNormal =>
      code == BmiCategoryCode.normal;
}

const kGlobalCategories = [
  BmiCategoryDef(
    code: BmiCategoryCode.underweight,
    color: Color(0xFF5B9BD5),
    min: 0,
    max: 18.5,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.normal,
    color: Color(0xFF4CAF50),
    min: 18.5,
    max: 25.0,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.overweight,
    color: Color(0xFFFF9800),
    min: 25.0,
    max: 30.0,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.obese,
    color: Color(0xFFF44336),
    min: 30.0,
    max: double.infinity,
  ),
];

const kAsianCategories = [
  BmiCategoryDef(
    code: BmiCategoryCode.underweight,
    color: Color(0xFF5B9BD5),
    min: 0,
    max: 18.5,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.normal,
    color: Color(0xFF4CAF50),
    min: 18.5,
    max: 23.0,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.overweight,
    color: Color(0xFFFFCC02),
    min: 23.0,
    max: 25.0,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.obese1,
    color: Color(0xFFFF9800),
    min: 25.0,
    max: 30.0,
  ),
  BmiCategoryDef(
    code: BmiCategoryCode.obese2,
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
    final normal = categories.firstWhere((c) => c.isNormal);
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
