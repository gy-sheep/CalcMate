import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/age_calculate_usecase.dart';
import '../age_calculator_colors.dart';
import 'age_info_card.dart';

class AgeCard extends StatelessWidget {
  const AgeCard({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  style: AppTokens.textStyleResult56.copyWith(
                    fontWeight: FontWeight.w800,
                    color: kAgeAccent,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '세',
                  style: AppTokens.textStyleResult22.copyWith(
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
                    borderRadius: BorderRadius.circular(AppTokens.radiusTag),
                  ),
                  child: Text(
                    '세는 나이',
                    style: AppTokens.textStyleLabelMedium.copyWith(
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
            AgeRow(label: '만 나이', value: '${result.koreanAge}세'),
            const SizedBox(height: 10),
            AgeRow(label: '연 나이', value: '${result.yearAge}세'),
            const SizedBox(height: 10),
            AgeRow(label: '태어난 요일', value: kWeekdays[result.birthWeekday]),
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
        Text(label,
            style: AppTokens.textStyleBody.copyWith(color: kAgeSubText)),
        Text(value,
            style: AppTokens.textStyleValue.copyWith(color: kAgeText)),
      ],
    );
  }
}

class BirthWeekdayRow extends StatelessWidget {
  const BirthWeekdayRow({super.key, required this.result});
  final AgeResult result;

  @override
  Widget build(BuildContext context) {
    return AgeInfoCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '태어난 요일',
              style: AppTokens.textStyleBody.copyWith(color: kAgeSubText),
            ),
            Text(
              kWeekdays[result.birthWeekday],
              style: AppTokens.textStyleValue.copyWith(color: kAgeText),
            ),
          ],
        ),
      ),
    );
  }
}
