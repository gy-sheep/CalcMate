import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
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
    final items = [
      ('국민연금', nationalPension),
      ('건강보험', healthInsurance),
      ('장기요양', longTermCare),
      ('고용보험', employmentInsurance),
      ('소득세', incomeTax),
      ('지방소득세', localTax),
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
                Text('공제 합계',
                    style: CmListCard.headerLabel
                        .copyWith(color: kSalaryTextSecondary)),
                Text(
                  totalDeduction > 0 ? '${_fmt(totalDeduction)} 원' : '—',
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
                      Text(label,
                          style: CmListCard.itemLabel
                              .copyWith(color: kSalaryTextSecondary)),
                      Text(
                        amount > 0 ? '${_fmt(amount)} 원' : '—',
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
