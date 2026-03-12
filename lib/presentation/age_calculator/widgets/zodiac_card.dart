import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class ZodiacCard extends StatelessWidget {
  const ZodiacCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final name = DataStrings.zodiacName(result.zodiacIndex, locale);
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.age_label_zodiac,
              style: CmBirthdayMiniCard.labelText.copyWith(
                color: kAgeTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  kZodiacIcons[result.zodiacIndex],
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.age_label_zodiacValue(name),
                  style: textStyle16.copyWith(
                    color: kAgeTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
