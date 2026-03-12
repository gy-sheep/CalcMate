import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class ConstellationCard extends StatelessWidget {
  const ConstellationCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final name = DataStrings.constellationName(result.constellationIndex, locale);
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.age_label_constellation,
              style: CmBirthdayMiniCard.labelText.copyWith(
                color: kAgeTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset(
                  kConstellationIcons[result.constellationIndex],
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  name,
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
