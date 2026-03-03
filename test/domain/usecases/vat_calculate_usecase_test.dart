import 'package:calcmate/domain/usecases/vat_calculate_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late VatCalculateUseCase useCase;

  setUp(() {
    useCase = VatCalculateUseCase();
  });

  // ── 부가세 별도 (exclusive) ──

  group('부가세 별도 (exclusive)', () {
    test('기본 10% — 공급가액 1,000,000', () {
      final result = useCase.execute(
        inputValue: 1000000,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 1000000);
      expect(result.vatAmount, 100000);
      expect(result.totalAmount, 1100000);
    });

    test('세율 0% — 부가세 0', () {
      final result = useCase.execute(
        inputValue: 500000,
        taxRate: 0,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 500000);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 500000);
    });

    test('세율 22% — 이탈리아 표준', () {
      final result = useCase.execute(
        inputValue: 10000,
        taxRate: 22,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 10000);
      expect(result.vatAmount, 2200);
      expect(result.totalAmount, 12200);
    });

    test('입력값 0 — 모두 0', () {
      final result = useCase.execute(
        inputValue: 0,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 0);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 0);
    });

    test('음수 입력 — 음수 기준으로 정상 계산', () {
      final result = useCase.execute(
        inputValue: -100000,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, -100000);
      expect(result.vatAmount, -10000);
      expect(result.totalAmount, -110000);
    });

    test('소수 입력 — 1000.5 × 10%', () {
      final result = useCase.execute(
        inputValue: 1000.5,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 1000.5);
      expect(result.vatAmount, closeTo(100.05, 1e-9));
      expect(result.totalAmount, closeTo(1100.55, 1e-9));
    });
  });

  // ── 부가세 포함 (inclusive) ──

  group('부가세 포함 (inclusive)', () {
    test('기본 10% — 합계 1,100,000', () {
      final result = useCase.execute(
        inputValue: 1100000,
        taxRate: 10,
        mode: VatMode.inclusive,
      );
      expect(result.totalAmount, 1100000);
      expect(result.supplyAmount, 1000000);
      expect(result.vatAmount, 100000);
    });

    test('원 미만 절사 (floor) — 합계 1000, 세율 10%', () {
      // 1000 / 1.1 = 909.0909... → floor → 909
      final result = useCase.execute(
        inputValue: 1000,
        taxRate: 10,
        mode: VatMode.inclusive,
      );
      expect(result.supplyAmount, 909);
      expect(result.vatAmount, 91); // 1000 - 909
      expect(result.totalAmount, 1000);
    });

    test('세율 0% — 부가세 0', () {
      final result = useCase.execute(
        inputValue: 500000,
        taxRate: 0,
        mode: VatMode.inclusive,
      );
      expect(result.supplyAmount, 500000);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 500000);
    });

    test('입력값 0 — 모두 0', () {
      final result = useCase.execute(
        inputValue: 0,
        taxRate: 0,
        mode: VatMode.inclusive,
      );
      expect(result.supplyAmount, 0);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 0);
    });

    test('음수 입력 — 음수 기준으로 정상 계산', () {
      // -1100 / 1.1 = -1000 → floor → -1000
      final result = useCase.execute(
        inputValue: -1100,
        taxRate: 10,
        mode: VatMode.inclusive,
      );
      expect(result.supplyAmount, -1000);
      expect(result.vatAmount, -100);
      expect(result.totalAmount, -1100);
    });
  });

  // ── 엣지 케이스 ──

  group('엣지 케이스', () {
    test('NaN 입력 — 모두 0', () {
      final result = useCase.execute(
        inputValue: double.nan,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 0);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 0);
    });

    test('Infinity 입력 — 모두 0', () {
      final result = useCase.execute(
        inputValue: double.infinity,
        taxRate: 10,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 0);
      expect(result.vatAmount, 0);
      expect(result.totalAmount, 0);
    });

    test('세율 99% — exclusive', () {
      final result = useCase.execute(
        inputValue: 10000,
        taxRate: 99,
        mode: VatMode.exclusive,
      );
      expect(result.supplyAmount, 10000);
      expect(result.vatAmount, 9900);
      expect(result.totalAmount, 19900);
    });
  });
}
