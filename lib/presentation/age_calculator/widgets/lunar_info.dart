import 'package:flutter/material.dart';

import '../../../domain/models/age_calculator_state.dart';
import '../age_calculator_colors.dart';
import '../age_calculator_viewmodel.dart';

class LunarInfo extends StatelessWidget {
  const LunarInfo({super.key, required this.state, required this.vm});
  final AgeCalculatorState state;
  final AgeCalculatorViewModel vm;

  @override
  Widget build(BuildContext context) {
    final solarDate = state.convertedSolarDate;
    final hasLeap = vm.hasLeapMonth;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kAgeDivider),
      ),
      child: Row(
        children: [
          // 변환된 양력 날짜
          Text(
            '양력  ',
            style: const TextStyle(
              color: kAgeSubText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            solarDate != null
                ? '${solarDate.year}년 ${solarDate.month}월 ${solarDate.day}일'
                : '—',
            style: const TextStyle(color: kAgeText, fontSize: 12),
          ),
          const Spacer(),
          // 윤달 체크박스 (해당 연·월에 윤달이 있을 때만)
          if (hasLeap) ...[
            const Text('윤달', style: TextStyle(color: kAgeSubText, fontSize: 12)),
            const SizedBox(width: 4),
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: state.isLeapMonth,
                onChanged: (v) => vm.handleIntent(
                  AgeCalculatorIntent.leapMonthToggled(v ?? false),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
