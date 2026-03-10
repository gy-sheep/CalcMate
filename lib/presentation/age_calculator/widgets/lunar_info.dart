import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 변환된 양력 날짜
          Text(
            '양력  ',
            style: CmBirthdayMiniCard.labelText.copyWith(
              color: kAgeSubText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            solarDate != null
                ? '${solarDate.year}년 ${solarDate.month}월 ${solarDate.day}일'
                : '—',
            style: CmBirthdayMiniCard.labelText.copyWith(color: kAgeText),
          ),
          const Spacer(),
          // 윤달 체크박스 (해당 연·월에 윤달이 있을 때만)
          if (hasLeap) ...[
            Text('윤달', style: CmCheckbox.labelSmall.copyWith(color: kAgeSubText, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            SizedBox(
              width: CmCheckbox.sizeSmall,
              height: CmCheckbox.sizeSmall,
              child: Checkbox(
                value: state.isLeapMonth,
                onChanged: (v) => vm.handleIntent(
                  AgeCalculatorIntent.leapMonthToggled(v ?? false),
                ),
                activeColor: kAgeAccent,
                checkColor: Colors.white,
                side: const BorderSide(color: kAgeSubText, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
