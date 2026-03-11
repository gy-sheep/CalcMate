import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/number_keypad.dart';
import '../../../domain/models/date_calculator_state.dart';
import '../date_calculator_colors.dart';
import '../date_format_utils.dart';
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildDateCalcResult(ref, state, result)),
        const SizedBox(height: 16),
        DateCard(
          label: state.calcBase == today ? '기준 날짜 (오늘)' : '기준 날짜',
          date: state.calcBase,
          onTap: () => pickDate(context, state.calcBase, (d) {
            vm.handleIntent(DateCalculatorIntent.calcBaseChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildNumberAndUnit(context, state, vm),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateCalcResult(
      WidgetRef ref, DateCalculatorState state, DateTime result) {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final isToday = state.calcBase == todayNorm;
    const unitNames = ['일', '주', '개월', '년'];
    final directionStr = state.calcDirection == 0 ? '후' : '전';
    final baseStr = isToday ? '오늘' : formatDateShort(state.calcBase);
    final n = ref.read(dateCalculatorViewModelProvider.notifier).calcNumber;
    final descStr = '$baseStr부터  $n${unitNames[state.calcUnit]} $directionStr';

    return Column(
      children: [
        Text(
          '${result.year}년 ${result.month}월 ${result.day}일',
          style: CmInfoCard.titleText.copyWith(
            fontWeight: FontWeight.w700,
            color: kDateAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatWeekday(result),
          style: CmInfoCard.bodyText.copyWith(
              color: kDateTextPrimary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        const Divider(color: kDateDivider),
        const SizedBox(height: 10),
        Text(
          descStr,
          style: CmInfoCard.captionText.copyWith(color: kDateTextSecondary),
        ),
      ],
    );
  }

  Widget _buildNumberAndUnit(
      BuildContext context, DateCalculatorState state, DateCalculatorViewModel vm) {
    const units = ['일', '주', '개월', '년'];
    final isForward = state.calcDirection == 0;

    // '개월' 텍스트 너비 기준으로 모든 칩의 최소 너비 계산
    const chipPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final tp = TextPainter(
      text: TextSpan(text: '개월', style: CmTab.text),
      textDirection: TextDirection.ltr,
    )..layout();
    final chipMinWidth = tp.width + chipPadding.horizontal;

    return Container(
      padding: CmInputCard.padding,
      decoration: BoxDecoration(
        color: kDateCardBg,
        borderRadius: BorderRadius.circular(CmInputCard.radius),
        border: Border.all(color: kDateCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // ① 이후/이전 토글 + 단위 버튼
        Row(
          children: [
            _buildDirectionOption('이후', 0, isForward, vm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(width: 1, height: 14, color: kDateDivider),
            ),
            _buildDirectionOption('이전', 1, isForward, vm),
            const Spacer(),
            ...List.generate(units.length, (i) {
              final isSelected = state.calcUnit == i;
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: GestureDetector(
                  onTap: () =>
                      vm.handleIntent(DateCalculatorIntent.calcUnitChanged(i)),
                  child: AnimatedContainer(
                    duration: durationAnimQuick,
                    padding: chipPadding,
                    constraints: BoxConstraints(minWidth: chipMinWidth),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kDateAccent.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(CmTab.radius),
                      border: Border.all(
                        color: isSelected
                            ? kDateAccent.withValues(alpha: 0.5)
                            : kDateCardBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        units[i],
                        style: CmTab.text.copyWith(
                          color: isSelected ? kDateAccent : kDateTextSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        // ③ 숫자 + 단위 표시 (탭 시 키패드 모달)
        GestureDetector(
          onTap: () => showNumberKeypad(
            context,
            initialValue: 0,
            onConfirm: (v) =>
                vm.handleIntent(DateCalculatorIntent.calcNumberChanged(v)),
            colors: KeypadColors(
              sheetBg: kDateBg1,
              handle: kDateCardBorder,
              inputBg: kDateCardBg,
              inputBorder: kDateAccent.withValues(alpha: 0.4),
              inputText: kDateAccent,
              keyBg: kDateCardBg,
              keyBorder: kDateCardBorder,
              keyText: kDateTextPrimary,
              backKeyBg: kDateAccent.withValues(alpha: 0.08),
              backKeyBorder: kDateAccent.withValues(alpha: 0.3),
              backIcon: kDateAccent,
              confirmBg: kDateAccent,
              confirmText: Colors.white,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                state.calcNumberInput,
                style: CmInputCard.inputText.copyWith(color: kDateAccent),
              ),
              const SizedBox(width: 8),
              Text(
                '${units[state.calcUnit]} ${isForward ? '후' : '전'}',
                style: CmInputCard.unitText.copyWith(color: kDateTextSecondary),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildDirectionOption(
      String label, int direction, bool isForward, DateCalculatorViewModel vm) {
    final isSelected = (direction == 0) == isForward;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          vm.handleIntent(DateCalculatorIntent.calcDirectionChanged(direction)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: CmTextToggle.text.copyWith(
            color: isSelected ? kDateTextPrimary : kDateTextSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

}
