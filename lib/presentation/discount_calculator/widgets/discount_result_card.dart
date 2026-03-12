import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/cm_gradient_border_card.dart';
import '../../../domain/usecases/calculate_discount_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../discount_calculator_colors.dart';

// ──────────────────────────────────────────
// 결과 카드
// ──────────────────────────────────────────
class DiscountResultCard extends StatelessWidget {
  final double originalPrice;
  final double finalPrice;
  final double savedAmount;
  final double effectiveRate;
  final double discountRate;
  final double? extraRate;
  final String currencySymbol;

  const DiscountResultCard({
    super.key,
    required this.originalPrice,
    required this.finalPrice,
    required this.savedAmount,
    required this.effectiveRate,
    required this.discountRate,
    required this.extraRate,
    required this.currencySymbol,
  });

  String _fmt(double v) => CalculateDiscountUseCase.formatPrice(v);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasExtra = extraRate != null && extraRate! > 0;
    final rateLabel = hasExtra
        ? '${discountRate.toStringAsFixed(discountRate % 1 == 0 ? 0 : 1)}% + ${extraRate!.toStringAsFixed(extraRate! % 1 == 0 ? 0 : 1)}%'
        : '${discountRate.toStringAsFixed(discountRate % 1 == 0 ? 0 : 1)}%';

    return CmGradientBorderCard(
      borderColors: kDiscountBorderGradient,
      color: kDiscountCardBg,
      child: Padding(
        padding: CmResultCard.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${_fmt(originalPrice)}$currencySymbol',
                    overflow: TextOverflow.ellipsis,
                    style: CmResultCard.unitText.copyWith(
                      color: kDiscountTextSecondary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: kDiscountTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward,
                    color: kDiscountTextSecondary,
                    size: CmTab.iconSize),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${_fmt(finalPrice)}$currencySymbol',
                    overflow: TextOverflow.ellipsis,
                    style: CmResultCard.unitText.copyWith(
                      color: kDiscountTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: kDiscountCardBorder, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.discount_label_savedAmount,
                    overflow: TextOverflow.ellipsis,
                    style: CmResultCard.unitText.copyWith(
                        color: kDiscountTextSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '- ${_fmt(savedAmount)}$currencySymbol',
                  style: CmResultCard.unitText.copyWith(
                    color: kDiscountTextSavings,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    hasExtra
                        ? l10n.discount_label_effectiveRate(rateLabel)
                        : l10n.discount_label_discountRate,
                    overflow: TextOverflow.ellipsis,
                    style: CmResultCard.unitText.copyWith(
                        color: kDiscountTextSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${effectiveRate.toStringAsFixed(effectiveRate % 1 == 0 ? 0 : 1)}%',
                  style: CmResultCard.unitText.copyWith(
                    color: kDiscountTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.discount_label_finalPrice,
                  style: CmResultCard.unitText.copyWith(
                      color: kDiscountTextSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(finalPrice)}$currencySymbol',
                  style: CmResultCard.resultText.copyWith(
                    color: kDiscountTextFinalPrice,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
