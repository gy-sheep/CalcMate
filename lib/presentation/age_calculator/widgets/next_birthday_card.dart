import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class NextBirthdayCard extends StatelessWidget {
  const NextBirthdayCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    if (result.isBirthdayToday) {
      return AgeInfoCard(
        child: Container(
          height: 110,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎂', style: AppTokens.textStyleResult28.copyWith()),
              const SizedBox(height: 6),
              Text(
                '오늘이 생일이에요!',
                style: AppTokens.textStyleSectionTitle.copyWith(
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
        '${nb.month}월 ${nb.day}일 (${kWeekdays[nb.weekday].replaceAll('요일', '')})';

    return AgeInfoCard(
      child: SizedBox(
        height: 110,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다음 생일',
                style: AppTokens.textStyleLabelMedium.copyWith(
                  color: kAgeSubText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'D-$dDays',
                style: AppTokens.textStyleResult28.copyWith(
                  color: kAgeAccent,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextDateStr,
                style: AppTokens.textStyleLabelSmall.copyWith(color: kAgeSubText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
