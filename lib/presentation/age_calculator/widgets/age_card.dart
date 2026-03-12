import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class AgeCard extends StatelessWidget {
  const AgeCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return AgeInfoCard(
      child: Padding(
        padding: CmInfoCard.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 세는 나이 (primary)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${result.countingAge}',
                  style: CmInfoCard.displayText.copyWith(
                    fontWeight: FontWeight.w800,
                    color: kAgeAccent,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.age_unit_years,
                  style: textMediumResult.copyWith(
                    color: kAgeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kAgeAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(CmInfoCard.tagRadius),
                  ),
                  child: Text(
                    l10n.age_label_countingAge,
                    style: CmInfoCard.tagLabel.copyWith(
                      color: kAgeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: kAgeDivider, height: 1),
            const SizedBox(height: 14),
            AgeRow(label: l10n.age_label_koreanAge, value: l10n.age_value_years(result.koreanAge)),
            const SizedBox(height: 10),
            AgeRow(label: l10n.age_label_yearAge, value: l10n.age_value_years(result.yearAge)),
            const SizedBox(height: 10),
            AgeRow(label: l10n.age_label_birthWeekday, value: DataStrings.weekdayFull(result.birthWeekday, locale)),
          ],
        ),
      ),
    );
  }
}

class AgeRow extends StatelessWidget {
  const AgeRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: inputFieldInnerLabel.copyWith(color: kAgeTextSecondary)),
        ),
        const SizedBox(width: 8),
        Text(value,
            style: textStyle16.copyWith(color: kAgeTextPrimary)),
      ],
    );
  }
}

class BirthWeekdayRow extends StatelessWidget {
  const BirthWeekdayRow({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.age_label_birthWeekday,
                overflow: TextOverflow.ellipsis,
                style: inputFieldInnerLabel.copyWith(color: kAgeTextSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DataStrings.weekdayFull(result.birthWeekday, locale),
              style: textStyle16.copyWith(color: kAgeTextPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
