import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../date_calculator_colors.dart';

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
                      formatYear(date),
                      style: CmCalendarCard.yearText.copyWith(color: kDateTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMonthDay(date),
                      style: CmCalendarCard.dateText.copyWith(
                        color: kDateAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formatWeekday(date),
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
