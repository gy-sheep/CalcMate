import 'package:flutter/material.dart';

import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class NextBirthdayCard extends StatelessWidget {
  const NextBirthdayCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    if (result.isBirthdayToday) {
      return AgeInfoCard(
        child: Container(
          height: 110,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎂', style: CmBirthdayMiniCard.resultText.copyWith()),
              const SizedBox(height: 6),
              Text(
                l10n.age_label_birthdayToday,
                style: CmBirthdayMiniCard.titleText.copyWith(
                  color: kAgeAccent,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dDays = result.nextBirthday.difference(todayOnly).inDays;
    final nb = result.nextBirthday;
    final nextDateStr =
        l10n.age_format_mdWeekday(nb.month, nb.day, DataStrings.weekdayShort(nb.weekday, locale));

    return AgeInfoCard(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.age_label_nextBirthday,
                style: CmBirthdayMiniCard.labelText.copyWith(
                  color: kAgeTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'D-$dDays',
                style: CmBirthdayMiniCard.resultText.copyWith(
                  color: kAgeAccent,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextDateStr,
                style: CmBirthdayMiniCard.subText.copyWith(color: kAgeTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
