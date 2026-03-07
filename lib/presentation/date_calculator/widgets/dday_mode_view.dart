import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecases/date_calculate_usecase.dart';
import '../date_calculator_colors.dart';
import '../date_calculator_viewmodel.dart';
import 'date_card.dart';
import 'result_card.dart';

class DDayModeView extends ConsumerWidget {
  const DDayModeView({
    super.key,
    required this.pickDate,
  });

  final Future<void> Function(
    BuildContext context,
    DateTime initial,
    void Function(DateTime) onPicked,
  ) pickDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dateCalculatorViewModelProvider);
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.ddayResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildDDayResult(result, state.ddayTarget)),
        const SizedBox(height: 16),
        _buildReferenceDateRow(context, state.ddayReference, state.ddayRefIsToday, vm),
        const SizedBox(height: 12),
        DateCard(
          label: '목표 날짜',
          date: state.ddayTarget,
          onTap: () => pickDate(context, state.ddayTarget, (d) {
            vm.handleIntent(DateCalculatorIntent.ddayTargetChanged(d));
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReferenceDateRow(
    BuildContext context,
    DateTime reference,
    bool isToday,
    DateCalculatorViewModel vm,
  ) {
    final label = isToday ? '기준일 (오늘)' : '기준일';
    return DateCard(
      label: label,
      date: reference,
      onTap: () => pickDate(context, reference, (d) {
        vm.handleIntent(DateCalculatorIntent.ddayReferenceChanged(d));
      }),
    );
  }

  Widget _buildDDayResult(DDayResult r, DateTime target) {
    final String mainText;
    final Color mainColor;
    if (r.isToday) {
      mainText = 'D-DAY';
      mainColor = const Color(0xFFFFD54F);
    } else if (r.isPast) {
      mainText = 'D + ${r.totalDays.abs()}';
      mainColor = kDateAccent;
    } else {
      mainText = 'D − ${r.totalDays}';
      mainColor = kDateAccent;
    }

    final suffix = r.isPast ? '전' : '후';

    return Column(
      children: [
        Text(
          mainText,
          style: AppTokens.textStyleResult48.copyWith(
            fontWeight: FontWeight.w700,
            color: mainColor,
            height: 1.0,
          ),
        ),
        if (!r.isToday) ...[
          const SizedBox(height: 14),
          const Divider(color: kDateDivider),
          const SizedBox(height: 10),
          buildSubText(
              '${r.weeks}주 ${r.remainingDaysAfterWeeks}일 $suffix  (${formatDateShort(target)})'),
          const SizedBox(height: 4),
          buildSubText('${r.months}개월 ${r.remainingDaysAfterMonths}일 $suffix'),
        ],
      ],
    );
  }
}
