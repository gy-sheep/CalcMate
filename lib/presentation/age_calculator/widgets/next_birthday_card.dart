import 'package:flutter/material.dart';

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
            children: const [
              Text('🎂', style: TextStyle(fontSize: 28)),
              SizedBox(height: 6),
              Text(
                '오늘이 생일이에요!',
                style: TextStyle(
                  color: kAgeAccent,
                  fontSize: 13,
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
              const Text(
                '다음 생일',
                style: TextStyle(
                  color: kAgeSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'D-$dDays',
                style: const TextStyle(
                  color: kAgeAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextDateStr,
                style: const TextStyle(color: kAgeSubText, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
