import 'package:flutter/material.dart';

import '../../../core/l10n/currency_formatter.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../salary_calculator_colors.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.netPay,
    required this.netPayAnnual,
    required this.isAnnual,
  });

  final int netPay;
  final int netPayAnnual;
  final bool isAnnual;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final subLabel = isAnnual ? l10n.salary_label_annualNet : l10n.salary_label_annualEquiv;

    return Container(
      padding: CmResultCard.padding,
      decoration: BoxDecoration(
        color: kSalaryResultBg,
        borderRadius: BorderRadius.circular(CmResultCard.radius),
        border: Border.all(color: kSalaryResultBorder),
        boxShadow: kSalaryCardBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.salary_label_netPay,
                style: CmResultCard.titleText
                    .copyWith(color: kSalaryAccent)),
          ),
          const SizedBox(height: CmResultCard.titleSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  netPay > 0
                      ? NumberFormatter.addCommas(netPay.toString())
                      : '—',
                  style: CmResultCard.resultText.copyWith(
                    color: kSalaryAccent,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (netPay > 0) ...[
                const SizedBox(width: spacingUnit),
                Padding(
                  padding: const EdgeInsets.only(bottom: CmResultCard.subSpacing),
                  child: Text(CurrencyFormatter.krwUnit(Localizations.localeOf(context)),
                      style: CmResultCard.unitText
                          .copyWith(color: kSalaryTextSecondary)),
                ),
              ],
            ],
          ),
          if (netPay > 0) ...[
            const SizedBox(height: CmResultCard.subSpacing),
            Text(
              '$subLabel  ${NumberFormatter.addCommas(netPayAnnual.toString())} ${CurrencyFormatter.krwUnit(locale)}',
              overflow: TextOverflow.ellipsis,
              style:
                  CmResultCard.subText.copyWith(color: kSalaryTextSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
