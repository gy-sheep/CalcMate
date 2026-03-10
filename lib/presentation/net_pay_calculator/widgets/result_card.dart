import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../net_pay_calculator_colors.dart';

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
    final subLabel = isAnnual ? '연 실수령' : '연 환산';

    return Container(
      padding: CmResultCard.padding,
      decoration: BoxDecoration(
        color: kNetPayResultBg,
        borderRadius: BorderRadius.circular(CmResultCard.radius),
        border: Border.all(color: kNetPayResultBorder),
        boxShadow: const [
          BoxShadow(
              color: kNetPayCardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('실수령액',
                style: CmResultCard.titleText
                    .copyWith(color: kNetPayTextSecondary)),
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
                    color: kNetPayGold,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              if (netPay > 0) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('원',
                      style: CmResultCard.unitText
                          .copyWith(color: kNetPayTextSecondary)),
                ),
              ],
            ],
          ),
          if (netPay > 0) ...[
            const SizedBox(height: CmResultCard.subSpacing),
            Text(
              '$subLabel  ${NumberFormatter.addCommas(netPayAnnual.toString())} 원',
              style:
                  CmResultCard.subText.copyWith(color: kNetPayTextSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
