import 'package:flutter/material.dart';

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
              const Text(
                '살아온 날',
                style: TextStyle(
                  color: kAgeSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${NumberFormatter.addCommas(days.toString())}일',
                style: const TextStyle(
                  color: kAgeText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(sub,
                  style: const TextStyle(color: kAgeSubText, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
