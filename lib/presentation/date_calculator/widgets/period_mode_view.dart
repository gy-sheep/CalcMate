import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/date_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../date_calculator_colors.dart';
import '../date_format_utils.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(dateCalculatorViewModelProvider);
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.periodResult;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildPeriodResult(context, result)),
        const SizedBox(height: 16),
        DateCard(
          label: state.periodStart == today ? l10n.date_label_startDateToday : l10n.date_label_startDate,
          date: state.periodStart,
          onTap: () => pickDate(context, state.periodStart, (d) {
            vm.handleIntent(DateCalculatorIntent.periodStartChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        DateCard(
          label: state.periodEnd == today ? l10n.date_label_endDateToday : l10n.date_label_endDate,
          date: state.periodEnd,
          onTap: () => pickDate(context, state.periodEnd, (d) {
            vm.handleIntent(DateCalculatorIntent.periodEndChanged(d));
          }),
        ),
        const SizedBox(height: 12),
        _buildStartDayToggle(context, ref, state.includeStartDay, vm),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPeriodResult(BuildContext context, PeriodResult r) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.date_result_days(r.totalDays.toString()),
          style: CmInfoCard.displayText.copyWith(
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
            Flexible(child: buildSubText(l10n.date_result_weeksAndDays(r.weeks, r.remainingDaysAfterWeeks))),
            Container(width: 1, height: 16, color: kDateDivider),
            Flexible(child: buildSubText(l10n.date_result_monthsAndDays(r.months, r.remainingDaysAfterMonths))),
            Container(width: 1, height: 16, color: kDateDivider),
            Flexible(child: buildSubText(
                l10n.date_result_yearsMonthsDays(r.years, r.monthsAfterYears, r.daysAfterYearsMonths))),
          ],
        ),
      ],
    );
  }

  Widget _buildStartDayToggle(
    BuildContext context,
    WidgetRef ref,
    bool isOn,
    DateCalculatorViewModel vm,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () =>
          vm.handleIntent(const DateCalculatorIntent.includeStartDayToggled()),
      child: Row(
        children: [
          Flexible(
            child: Text(
              l10n.date_label_includeStartDay,
              overflow: TextOverflow.ellipsis,
              style: rowLabel.copyWith(color: kDateTextSecondary),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.date_hint_includeStartDay,
              overflow: TextOverflow.ellipsis,
              style: textStyleCaption.copyWith(color: kDateTextTertiary),
            ),
          ),
          const Spacer(),
          AnimatedContainer(
            duration: durationAnimDefault,
            width: 42,
            height: 24,
            decoration: BoxDecoration(
              color: isOn ? kDateAccent : kDateDivider,
              borderRadius: BorderRadius.circular(radiusInput),
            ),
            child: AnimatedAlign(
              duration: durationAnimDefault,
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
        ],
      ),
    );
  }
}
