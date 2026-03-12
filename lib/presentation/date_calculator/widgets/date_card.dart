import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../date_calculator_colors.dart';
import '../date_format_utils.dart';

class DateCard extends StatelessWidget {
  const DateCard({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: sectionLabel.copyWith(color: kDateTextSecondary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: CmCalendarCard.padding,
            decoration: BoxDecoration(
              color: kDateCardBg,
              borderRadius: BorderRadius.circular(CmCalendarCard.radius),
              border: Border.all(color: kDateCardBorder),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatYear(date, l10n),
                      style: CmCalendarCard.yearText.copyWith(color: kDateTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMonthDay(date, l10n),
                      style: CmCalendarCard.dateText.copyWith(
                        color: kDateAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formatWeekday(date, locale),
                  style: CmCalendarCard.weekdayText.copyWith(color: kDateAccent),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right,
                    color: kDateTextTertiary, size: CmCalendarCard.chevronSize),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
