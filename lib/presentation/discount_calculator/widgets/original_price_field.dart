import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/cm_gradient_border_card.dart';
import '../../../l10n/app_localizations.dart';
import '../discount_calculator_colors.dart';

// ──────────────────────────────────────────
// 원가 입력 필드
// ──────────────────────────────────────────
class OriginalPriceField extends StatelessWidget {
  final String value;
  final bool isActive;
  final String currencySymbol;
  final VoidCallback onTap;

  const OriginalPriceField({
    super.key,
    required this.value,
    required this.isActive,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.discount_label_originalPrice,
            style: CmInputCard.titleText.copyWith(
                color: kDiscountTextSecondary)),
        const SizedBox(height: CmInputCard.titleSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.isEmpty ? '0' : value,
              style: CmInputCard.inputText.copyWith(
                color: value.isEmpty ? kDiscountTextSecondary : kDiscountTextPrimary,
              ),
            ),
            if (currencySymbol.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                currencySymbol,
                style: CmInputCard.unitText.copyWith(
                  color: isActive ? kDiscountAccent : kDiscountTextSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: isActive
          ? CmGradientBorderCard(
              borderColors: kDiscountBorderGradient,
              color: kDiscountFieldBg,
              child: Padding(
                padding: CmInputCard.padding,
                child: content,
              ),
            )
          : Container(
              padding: CmInputCard.padding,
              decoration: BoxDecoration(
                color: kDiscountFieldBg,
                borderRadius: BorderRadius.circular(CmInputCard.radius),
                border: Border.all(color: kDiscountFieldBorder),
                boxShadow: const [
                  BoxShadow(
                    color: kDiscountCardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: content,
            ),
    );
  }
}
