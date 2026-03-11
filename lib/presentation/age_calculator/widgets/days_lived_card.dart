import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../../../domain/utils/number_formatter.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class DaysLivedCard extends StatelessWidget {
  const DaysLivedCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    final days = result.daysLived;
    // 약 몇 년 몇 개월
    final years  = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final sub = months > 0 ? '약 $years년 $months개월' : '약 $years년';

    return AgeInfoCard(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '살아온 날',
                style: CmBirthdayMiniCard.labelText.copyWith(
                  color: kAgeTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${NumberFormatter.addCommas(days.toString())}일',
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
