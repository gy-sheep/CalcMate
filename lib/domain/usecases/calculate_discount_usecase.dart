class DiscountResult {
  const DiscountResult({
    required this.hasResult,
    required this.originalPrice,
    required this.finalPrice,
    required this.savedAmount,
    required this.effectiveRate,
  });

  final bool hasResult;
  final double originalPrice;
  final double finalPrice;
  final double savedAmount;
  final double effectiveRate;
}

class CalculateDiscountUseCase {
  DiscountResult calculate({
    required String originalPrice,
    required String discountRate,
    required String extraRate,
    required bool showExtra,
  }) {
    final price = double.tryParse(originalPrice.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(discountRate) ?? 0;
    final extra = double.tryParse(extraRate) ?? 0;

    final hasResult = price > 0 && rate > 0;
    if (!hasResult) {
      return DiscountResult(
        hasResult: false,
        originalPrice: price,
        finalPrice: price,
        savedAmount: 0,
        effectiveRate: 0,
      );
    }

    double finalPrice = price * (1 - rate / 100);
    if (showExtra && extra > 0) {
      finalPrice *= (1 - extra / 100);
    }

    final savedAmount = price - finalPrice;
    final effectiveRate = savedAmount / price * 100;

    return DiscountResult(
      hasResult: true,
      originalPrice: price,
      finalPrice: finalPrice,
      savedAmount: savedAmount,
      effectiveRate: effectiveRate,
    );
  }

  static String formatPrice(double value) {
    if (value == 0) return '0';
    final parts = value.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
      result.write(parts[i]);
    }
    return result.toString();
  }
}
