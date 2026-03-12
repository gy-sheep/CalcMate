import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../domain/utils/number_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class DaysLivedCard extends StatelessWidget {
  const DaysLivedCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = result.daysLived;
    final years  = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final sub = months > 0
        ? l10n.age_result_approxYearsMonths(years, months)
        : l10n.age_result_approxYears(years);

    return AgeInfoCard(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.age_label_daysLived,
                style: CmBirthdayMiniCard.labelText.copyWith(
                  color: kAgeTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                l10n.age_result_days(NumberFormatter.addCommas(days.toString())),
                style: textMediumResult.copyWith(
                  color: kAgeTextPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(sub,
                  style: CmBirthdayMiniCard.subText.copyWith(color: kAgeTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
