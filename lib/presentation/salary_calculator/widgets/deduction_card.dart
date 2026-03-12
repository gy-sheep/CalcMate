import 'package:flutter/material.dart';

import '../../../core/l10n/currency_formatter.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../salary_calculator_colors.dart';

class DeductionCard extends StatelessWidget {
  const DeductionCard({
    super.key,
    required this.totalDeduction,
    required this.nationalPension,
    required this.healthInsurance,
    required this.longTermCare,
    required this.employmentInsurance,
    required this.incomeTax,
    required this.localTax,
  });

  final int totalDeduction;
  final int nationalPension;
  final int healthInsurance;
  final int longTermCare;
  final int employmentInsurance;
  final int incomeTax;
  final int localTax;

  String _fmt(int v) => NumberFormatter.addCommas(v.toString());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final items = [
      (l10n.salary_label_nationalPension, nationalPension),
      (l10n.salary_label_healthInsurance, healthInsurance),
      (l10n.salary_label_longTermCare, longTermCare),
      (l10n.salary_label_employmentInsurance, employmentInsurance),
      (l10n.salary_label_incomeTax, incomeTax),
      (l10n.salary_label_localTax, localTax),
    ];

    return Container(
      decoration: BoxDecoration(
        color: kSalaryDeductionBg,
        borderRadius: BorderRadius.circular(CmListCard.radius),
        border: Border.all(color: kSalaryDeductionLine),
        boxShadow: kSalaryCardBoxShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: CmListCard.headerPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(l10n.salary_label_deductionTotal,
                      overflow: TextOverflow.ellipsis,
                      style: CmListCard.headerLabel
                          .copyWith(color: kSalaryTextSecondary)),
                ),
                const SizedBox(width: 8),
                Text(
                  totalDeduction > 0
                      ? CurrencyFormatter.formatKrw(
                          _fmt(totalDeduction), locale)
                      : '—',
                  style:
                      CmListCard.headerValue.copyWith(color: kSalaryTextPrimary),
                ),
              ],
            ),
          ),
          Container(height: CmListCard.dividerHeight, color: kSalaryDeductionLine),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            final (label, amount) = e.value;
            return Column(
              children: [
                Padding(
                  padding: CmListCard.itemPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(label,
                            overflow: TextOverflow.ellipsis,
                            style: CmListCard.itemLabel
                                .copyWith(color: kSalaryTextSecondary)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        amount > 0
                            ? CurrencyFormatter.formatKrw(
                                _fmt(amount), locale)
                            : '—',
                        style: CmListCard.itemValue
                            .copyWith(color: kSalaryTextPrimary),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    height: CmListCard.dividerHeight,
                    margin: EdgeInsets.symmetric(horizontal: CmListCard.itemPadding.horizontal / 2),
                    color: kSalaryDeductionLine,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
