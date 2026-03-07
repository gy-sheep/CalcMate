import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/date_calculate_usecase.dart';
import '../date_calculator_colors.dart';
import '../date_calculator_viewmodel.dart';
import 'date_card.dart';
import 'result_card.dart';

class PeriodModeView extends ConsumerWidget {
  const PeriodModeView({
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
    final result = vm.periodResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildPeriodResult(result)),
        const SizedBox(height: 16),
        DateCard(
          label: '시작 날짜',
          date: state.periodStart,
          onTap: () => pickDate(context, state.periodStart, (d) {
            vm.handleIntent(DateCalculatorIntent.periodStartChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        DateCard(
          label: '종료 날짜',
          date: state.periodEnd,
          onTap: () => pickDate(context, state.periodEnd, (d) {
            vm.handleIntent(DateCalculatorIntent.periodEndChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildStartDayToggle(ref, state.includeStartDay, vm),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPeriodResult(PeriodResult r) {
    return Column(
      children: [
        Text(
          '${r.totalDays}일',
          style: AppTokens.textStyleResult56.copyWith(
            fontWeight: FontWeight.w700,
            color: kDateAccent,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        const Divider(color: kDateDivider),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildSubText('${r.weeks}주 ${r.remainingDaysAfterWeeks}일'),
            Container(width: 1, height: 16, color: kDateDivider),
            buildSubText('${r.months}개월 ${r.remainingDaysAfterMonths}일'),
          ],
        ),
        const SizedBox(height: 6),
        buildSubText(
            '${r.years}년 ${r.monthsAfterYears}개월 ${r.daysAfterYearsMonths}일'),
      ],
    );
  }

  Widget _buildStartDayToggle(
    WidgetRef ref,
    bool isOn,
    DateCalculatorViewModel vm,
  ) {
    return GestureDetector(
      onTap: () =>
          vm.handleIntent(const DateCalculatorIntent.includeStartDayToggled()),
      child: Row(
        children: [
          Text(
            '시작일 포함',
            style: AppTokens.textStyleBody.copyWith(color: kDateTextSecondary),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              color: isOn ? kDateAccent : kDateDivider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '기념일 계산 시 ON 권장',
            style: AppTokens.textStyleLabelSmall.copyWith(color: kDateTextTertiary),
          ),
        ],
      ),
    );
  }
}
