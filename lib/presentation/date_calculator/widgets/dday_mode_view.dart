import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecases/date_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../date_calculator_colors.dart';
import '../date_format_utils.dart';
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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dateCalculatorViewModelProvider);
    final vm = ref.read(dateCalculatorViewModelProvider.notifier);
    final result = vm.ddayResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultCard(child: _buildDDayResult(context, result, state.ddayTarget)),
        const SizedBox(height: 16),
        _buildReferenceDateRow(context, state.ddayReference, state.ddayRefIsToday, vm),
        const SizedBox(height: 12),
        DateCard(
          label: l10n.date_label_targetDate,
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
    final l10n = AppLocalizations.of(context);
    final label = isToday ? l10n.date_label_refDateToday : l10n.date_label_refDate;
    return DateCard(
      label: label,
      date: reference,
      onTap: () => pickDate(context, reference, (d) {
        vm.handleIntent(DateCalculatorIntent.ddayReferenceChanged(d));
      }),
    );
  }

  Widget _buildDDayResult(BuildContext context, DDayResult r, DateTime target) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
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

    final suffix = r.isPast ? l10n.date_suffix_before : l10n.date_suffix_after;

    return Column(
      children: [
        Text(
          mainText,
          style: CmInfoCard.displayText.copyWith(
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
              '${l10n.date_result_weeksAndDays(r.weeks, r.remainingDaysAfterWeeks)} $suffix  (${formatDateShort(target, locale)})'),
          const SizedBox(height: 4),
          buildSubText('${l10n.date_result_monthsAndDays(r.months, r.remainingDaysAfterMonths)} $suffix'),
        ],
      ],
    );
  }
}
