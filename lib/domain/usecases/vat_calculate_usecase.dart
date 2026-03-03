/// 부가세 계산 모드.
enum VatMode {
  /// 부가세 별도 — 공급가액 입력.
  exclusive,

  /// 부가세 포함 — 합계 입력.
  inclusive,
}

/// 부가세 계산 결과.
class VatResult {
  final double supplyAmount;
  final double vatAmount;
  final double totalAmount;

  const VatResult({
    required this.supplyAmount,
    required this.vatAmount,
    required this.totalAmount,
  });
}

/// 부가세를 계산하는 UseCase.
///
/// - exclusive: 공급가액 → 부가세, 합계 계산
/// - inclusive: 합계 → 공급가액(원 미만 절사), 부가세 역산
class VatCalculateUseCase {
  VatResult execute({
    required double inputValue,
    required int taxRate,
    required VatMode mode,
  }) {
    if (inputValue.isNaN || inputValue.isInfinite) {
      return const VatResult(supplyAmount: 0, vatAmount: 0, totalAmount: 0);
    }

    if (mode == VatMode.exclusive) {
      final supply = inputValue;
      final vat = supply * (taxRate / 100);
      return VatResult(
        supplyAmount: supply,
        vatAmount: vat,
        totalAmount: supply + vat,
      );
    }

    // inclusive: 공급가액 원 미만 절사 (floor)
    // total * 100 / (100 + rate) 는 total / (1 + rate/100) 보다
    // 부동소수점 정밀도가 높다 (정수 나눗셈에 가까움).
    final total = inputValue;
    final supply = (total * 100 / (100 + taxRate)).floorToDouble();
    final vat = total - supply;
    return VatResult(
      supplyAmount: supply,
      vatAmount: vat,
      totalAmount: total,
    );
  }
}
