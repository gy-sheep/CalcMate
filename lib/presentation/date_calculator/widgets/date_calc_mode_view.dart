import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/date_calculator_state.dart';
import '../date_calculator_colors.dart';
import '../date_calculator_viewmodel.dart';
import 'date_card.dart';
import 'result_card.dart';

class DateCalcModeView extends ConsumerWidget {
  const DateCalcModeView({
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
    final result = vm.calcResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildDateCalcResult(ref, state, result)),
        const SizedBox(height: 16),
        DateCard(
          label: '기준 날짜',
          date: state.calcBase,
          onTap: () => pickDate(context, state.calcBase, (d) {
            vm.handleIntent(DateCalculatorIntent.calcBaseChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildNumberAndUnit(state, vm),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateCalcResult(
      WidgetRef ref, DateCalculatorState state, DateTime result) {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final isToday = state.calcBase == todayNorm;
    const unitNames = ['일', '주', '월', '년'];
    final directionStr = state.calcDirection == 0 ? '후' : '전';
    final baseStr = isToday ? '오늘' : formatDateShort(state.calcBase);
    final n = ref.read(dateCalculatorViewModelProvider.notifier).calcNumber;
    final descStr = '$baseStr부터  $n${unitNames[state.calcUnit]} $directionStr';

    return Column(
      children: [
        Text(
          '${result.year}년 ${result.month}월 ${result.day}일',
          style: AppTokens.textStyleResult28.copyWith(
            fontWeight: FontWeight.w700,
            color: kDateTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatWeekday(result),
          style: AppTokens.textStyleResult18.copyWith(
              color: kDateAccent, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        const Divider(color: kDateDivider),
        const SizedBox(height: 10),
        Text(
          descStr,
          style: AppTokens.textStyleBody.copyWith(color: kDateTextSecondary),
        ),
      ],
    );
  }

  Widget _buildNumberAndUnit(
      DateCalculatorState state, DateCalculatorViewModel vm) {
    const units = ['일', '주', '월', '년'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 부호 + 숫자 + 스텝 버튼
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              _buildStepButton(Icons.keyboard_double_arrow_left,
                  () => vm.handleIntent(const DateCalculatorIntent.numberStepped(-5))),
              const SizedBox(width: 8),
              _buildStepButton(Icons.keyboard_arrow_left,
                  () => vm.handleIntent(const DateCalculatorIntent.numberStepped(-1))),
              Expanded(
                child: Text(
                  '${state.calcDirection == 0 ? '+' : '−'} ${state.calcNumberInput}',
                  textAlign: TextAlign.center,
                  style: AppTokens.textStyleResult40.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kDateAccent,
                    height: 1.0,
                  ),
                ),
              ),
              _buildStepButton(Icons.keyboard_arrow_right,
                  () => vm.handleIntent(const DateCalculatorIntent.numberStepped(1))),
              const SizedBox(width: 8),
              _buildStepButton(Icons.keyboard_double_arrow_right,
                  () => vm.handleIntent(const DateCalculatorIntent.numberStepped(5))),
            ],
          ),
        ),
        // 단위 버튼
        Row(
          children: List.generate(units.length, (i) {
            final isSelected = state.calcUnit == i;
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    vm.handleIntent(DateCalculatorIntent.calcUnitChanged(i)),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kDateAccent.withValues(alpha: 0.15)
                        : kDateCardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? kDateAccent.withValues(alpha: 0.5)
                          : kDateCardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      units[i],
                      style: AppTokens.textStyleBody.copyWith(
                        color: isSelected ? kDateAccent : kDateTextSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: kDateCardBg,
          shape: BoxShape.circle,
          border: Border.all(color: kDateCardBorder),
        ),
        child: Icon(icon, color: kDateAccent, size: AppTokens.sizeIconStep),
      ),
    );
  }
}
