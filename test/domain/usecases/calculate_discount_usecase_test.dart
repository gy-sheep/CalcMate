import 'package:flutter_test/flutter_test.dart';
import 'package:calcmate/domain/usecases/calculate_discount_usecase.dart';

void main() {
  late CalculateDiscountUseCase useCase;

  setUp(() => useCase = CalculateDiscountUseCase());

  // ── hasResult ────────────────────────────────────────────────────────────

  group('hasResult', () {
    test('원가와 할인율이 모두 있으면 true', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.hasResult, true);
    });

    test('원가가 없으면 false', () {
      final r = useCase.calculate(
        originalPrice: '',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.hasResult, false);
    });

    test('원가가 0이면 false', () {
      final r = useCase.calculate(
        originalPrice: '0',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.hasResult, false);
    });

    test('할인율이 없으면 false', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '',
        extraRate: '',
        showExtra: false,
      );
      expect(r.hasResult, false);
    });

    test('할인율이 0이면 false', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '0',
        extraRate: '',
        showExtra: false,
      );
      expect(r.hasResult, false);
    });
  });

  // ── 기본 할인 ──────────────────────────────────────────────────────────────

  group('기본 할인 계산', () {
    test('50,000원 30% 할인 → 최종가 35,000원', () {
      final r = useCase.calculate(
        originalPrice: '50,000',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.finalPrice, 35000.0);
    });

    test('50,000원 30% 할인 → 할인 금액 15,000원', () {
      final r = useCase.calculate(
        originalPrice: '50,000',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.savedAmount, 15000.0);
    });

    test('30% 단일 할인 → 실질 할인율 30%', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '30',
        extraRate: '',
        showExtra: false,
      );
      expect(r.effectiveRate, closeTo(30.0, 0.01));
    });

    test('소수점 할인율 12.5% — 10,000원 → 8,750원', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '12.5',
        extraRate: '',
        showExtra: false,
      );
      expect(r.finalPrice, 8750.0);
    });
  });

  // ── 중첩 할인 ──────────────────────────────────────────────────────────────

  group('중첩 할인 계산 (복리 방식)', () {
    test('50,000원 30% + 10% → 최종가 31,500원', () {
      final r = useCase.calculate(
        originalPrice: '50,000',
        discountRate: '30',
        extraRate: '10',
        showExtra: true,
      );
      expect(r.finalPrice, 31500.0);
    });

    test('50,000원 30% + 10% → 할인 금액 18,500원', () {
      final r = useCase.calculate(
        originalPrice: '50,000',
        discountRate: '30',
        extraRate: '10',
        showExtra: true,
      );
      expect(r.savedAmount, 18500.0);
    });

    test('30% + 10% 중첩 → 실질 할인율 37%', () {
      final r = useCase.calculate(
        originalPrice: '50,000',
        discountRate: '30',
        extraRate: '10',
        showExtra: true,
      );
      expect(r.effectiveRate, closeTo(37.0, 0.01));
    });

    test('showExtra=false이면 추가 할인 무시', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '20',
        extraRate: '50',
        showExtra: false,
      );
      expect(r.finalPrice, 8000.0);
    });

    test('extraRate가 빈 문자열이면 추가 할인 적용 안 함', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '20',
        extraRate: '',
        showExtra: true,
      );
      expect(r.finalPrice, 8000.0);
    });
  });

  // ── 엣지 케이스 ────────────────────────────────────────────────────────────

  group('엣지 케이스', () {
    test('원가에 쉼표 포함 — 정상 파싱', () {
      final r = useCase.calculate(
        originalPrice: '1,000,000',
        discountRate: '50',
        extraRate: '',
        showExtra: false,
      );
      expect(r.finalPrice, 500000.0);
    });

    test('10억 이상 — 정상 계산', () {
      final r = useCase.calculate(
        originalPrice: '1000000000',
        discountRate: '10',
        extraRate: '',
        showExtra: false,
      );
      expect(r.finalPrice, 900000000.0);
    });

    test('소수점 할인율 중첩 — 20% + 12.5%', () {
      final r = useCase.calculate(
        originalPrice: '10000',
        discountRate: '20',
        extraRate: '12.5',
        showExtra: true,
      );
      // 10000 × 0.8 × 0.875 = 7000
      expect(r.finalPrice, 7000.0);
    });
  });

  // ── formatPrice ──────────────────────────────────────────────────────────

  group('formatPrice', () {
    test('1000 → "1,000"', () {
      expect(CalculateDiscountUseCase.formatPrice(1000), '1,000');
    });

    test('1000000 → "1,000,000"', () {
      expect(CalculateDiscountUseCase.formatPrice(1000000), '1,000,000');
    });

    test('0 → "0"', () {
      expect(CalculateDiscountUseCase.formatPrice(0), '0');
    });

    test('31500 → "31,500"', () {
      expect(CalculateDiscountUseCase.formatPrice(31500), '31,500');
    });
  });
}
