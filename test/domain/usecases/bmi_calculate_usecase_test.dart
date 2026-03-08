import 'package:calcmate/domain/usecases/bmi_calculate_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BmiCalculateUseCase useCase;

  setUp(() {
    useCase = BmiCalculateUseCase();
  });

  group('BMI 계산', () {
    test('170cm, 65kg → BMI 22.49', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.global,
      );
      expect(result.bmi, closeTo(22.49, 0.01));
    });

    test('180cm, 80kg → BMI 24.69', () {
      final result = useCase.calculate(
        heightCm: 180,
        weightKg: 80,
        standard: BmiStandard.global,
      );
      expect(result.bmi, closeTo(24.69, 0.01));
    });

    test('키 0일 때 BMI 0', () {
      final result = useCase.calculate(
        heightCm: 0,
        weightKg: 65,
        standard: BmiStandard.global,
      );
      expect(result.bmi, 0.0);
    });
  });

  group('글로벌 기준 (4범주)', () {
    test('BMI 17.0 → 저체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 49,
        standard: BmiStandard.global,
      );
      expect(result.category.label, '저체중');
      expect(result.categories.length, 4);
    });

    test('BMI 22.49 → 정상 체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.global,
      );
      expect(result.category.label, '정상 체중');
    });

    test('BMI 26.0 → 과체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 75.1,
        standard: BmiStandard.global,
      );
      expect(result.bmi, greaterThanOrEqualTo(25.0));
      expect(result.bmi, lessThan(30.0));
      expect(result.category.label, '과체중');
    });

    test('BMI 30.0 이상 → 비만', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 90,
        standard: BmiStandard.global,
      );
      expect(result.bmi, greaterThanOrEqualTo(30.0));
      expect(result.category.label, '비만');
    });
  });

  group('아시아태평양 기준 (5범주)', () {
    test('BMI 22.49 → 정상', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.asian,
      );
      expect(result.category.label, '정상');
      expect(result.categories.length, 5);
    });

    test('BMI 23.5 → 과체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 68,
        standard: BmiStandard.asian,
      );
      expect(result.bmi, greaterThanOrEqualTo(23.0));
      expect(result.bmi, lessThan(25.0));
      expect(result.category.label, '과체중');
    });

    test('BMI 27.0 → 비만 1단계', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 78,
        standard: BmiStandard.asian,
      );
      expect(result.bmi, greaterThanOrEqualTo(25.0));
      expect(result.bmi, lessThan(30.0));
      expect(result.category.label, '비만 1단계');
    });

    test('BMI 30.0 이상 → 비만 2단계', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 90,
        standard: BmiStandard.asian,
      );
      expect(result.category.label, '비만 2단계');
    });
  });

  group('건강 체중 범위 역산', () {
    test('글로벌 기준 170cm → 정상 BMI 18.5~24.9 역산', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.global,
      );
      // 18.5 × 1.7² = 53.465, 25.0 × 1.7² = 72.25 (max는 exclusive이지만 역산에 사용)
      expect(result.healthyWeightMinKg, closeTo(53.47, 0.01));
      expect(result.healthyWeightMaxKg, closeTo(72.25, 0.01));
    });

    test('아시아 기준 170cm → 정상 BMI 18.5~22.9 역산', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.asian,
      );
      // 18.5 × 1.7² = 53.465, 23.0 × 1.7² = 66.47 (max는 exclusive이지만 역산에 사용)
      expect(result.healthyWeightMinKg, closeTo(53.47, 0.01));
      expect(result.healthyWeightMaxKg, closeTo(66.47, 0.01));
    });

    test('정상 범위 내 체중 → isInHealthyRange true', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 65,
        standard: BmiStandard.global,
      );
      expect(result.isInHealthyRange, true);
    });

    test('정상 범위 밖 체중 → isInHealthyRange false', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 90,
        standard: BmiStandard.global,
      );
      expect(result.isInHealthyRange, false);
    });
  });

  group('경계값 테스트', () {
    test('BMI 정확히 18.5 → 글로벌 정상 체중', () {
      // 170cm에서 BMI 18.5가 되려면: 18.5 × 1.7² = 53.465
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 53.465,
        standard: BmiStandard.global,
      );
      expect(result.bmi, closeTo(18.5, 0.01));
      expect(result.category.label, '정상 체중');
    });

    test('BMI 정확히 25.0 → 글로벌 과체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 72.25,
        standard: BmiStandard.global,
      );
      expect(result.bmi, closeTo(25.0, 0.01));
      expect(result.category.label, '과체중');
    });

    test('BMI 정확히 23.0 → 아시아 과체중', () {
      final result = useCase.calculate(
        heightCm: 170,
        weightKg: 66.47,
        standard: BmiStandard.asian,
      );
      expect(result.bmi, closeTo(23.0, 0.01));
      expect(result.category.label, '과체중');
    });
  });

  group('locale 헬퍼', () {
    test('KR → asian', () {
      expect(BmiCalculateUseCase.standardForCountryCode('KR'), BmiStandard.asian);
    });

    test('JP → asian', () {
      expect(BmiCalculateUseCase.standardForCountryCode('JP'), BmiStandard.asian);
    });

    test('US → global', () {
      expect(BmiCalculateUseCase.standardForCountryCode('US'), BmiStandard.global);
    });

    test('null → global', () {
      expect(BmiCalculateUseCase.standardForCountryCode(null), BmiStandard.global);
    });

    test('US → imperial (isMetric false)', () {
      expect(BmiCalculateUseCase.defaultIsMetric('US'), false);
    });

    test('KR → metric (isMetric true)', () {
      expect(BmiCalculateUseCase.defaultIsMetric('KR'), true);
    });

    test('null → metric', () {
      expect(BmiCalculateUseCase.defaultIsMetric(null), true);
    });
  });

  group('단위 변환 헬퍼', () {
    test('170cm → 5 ft 7 in', () {
      expect(BmiCalculateUseCase.heightToImperial(170), '5 ft 7 in');
    });

    test('65kg → 143.3 lb', () {
      expect(BmiCalculateUseCase.weightToImperial(65), '143.3 lb');
    });
  });
}
