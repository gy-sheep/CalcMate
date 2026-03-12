import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/age_calculator_state.dart';
import '../../../l10n/app_localizations.dart';
import '../age_calculator_colors.dart';
import '../age_calculator_viewmodel.dart';

class LunarInfo extends StatelessWidget {
  const LunarInfo({super.key, required this.state, required this.vm});
  final AgeCalculatorState state;
  final AgeCalculatorViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(
            '${l10n.age_label_solar}  ',
            style: CmBirthdayMiniCard.labelText.copyWith(
              color: kAgeTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            solarDate != null
                ? l10n.date_format_ymd(solarDate.year, solarDate.month, solarDate.day)
                : '—',
            style: CmBirthdayMiniCard.labelText.copyWith(color: kAgeTextPrimary),
          ),
          const Spacer(),
          if (hasLeap) ...[
            Text(l10n.age_label_leapMonth, style: CmCheckbox.labelSmall.copyWith(color: kAgeTextSecondary, fontWeight: FontWeight.w600)),
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
                side: const BorderSide(color: kAgeTextSecondary, width: 1.5),
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
