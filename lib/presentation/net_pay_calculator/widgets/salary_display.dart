import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../net_pay_calculator_colors.dart';

class SalaryDisplay extends StatelessWidget {
  const SalaryDisplay({
    super.key,
    required this.salary,
    required this.monthSalary,
    required this.isAnnual,
    required this.onTap,
    required this.sliderValue,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderMinLabel,
    required this.sliderMaxLabel,
    required this.onSliderChanged,
  });

  final int salary;
  final int monthSalary;
  final bool isAnnual;
  final VoidCallback onTap;
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final String sliderMinLabel;
  final String sliderMaxLabel;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final title = isAnnual ? '연봉' : '월급';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: CmInputCard.padding,
        decoration: BoxDecoration(
          color: kNetPayCardBg,
          borderRadius: BorderRadius.circular(CmInputCard.radius),
          border: Border.all(color: kNetPayCardBorder),
          boxShadow: const [
            BoxShadow(
                color: kNetPayCardShadow,
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: CmInputCard.titleText
                        .copyWith(color: kNetPayTextSecondary)),
                const Icon(Icons.edit_outlined,
                    color: kNetPayTextSecondary, size: CmIcon.inputCard),
              ],
            ),
            const SizedBox(height: CmInputCard.titleSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    salary > 0
                        ? NumberFormatter.addCommas(salary.toString())
                        : '0',
                    style:
                        CmInputCard.inputText.copyWith(color: kNetPayTextPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text('원',
                    style:
                        CmInputCard.unitText.copyWith(color: kNetPayTextSecondary)),
              ],
            ),
            if (isAnnual && salary > 0) ...[
              const SizedBox(height: CmInputCard.subSpacing),
              Text(
                '월 ${NumberFormatter.addCommas(monthSalary.toString())} 원',
                style: CmInputCard.subText.copyWith(color: kNetPayTextSecondary),
              ),
            ],
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: CmSlider.trackHeight,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: CmSlider.thumbRadius),
                overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: CmSlider.overlayRadius),
                activeTrackColor: kNetPayGold,
                inactiveTrackColor: kNetPaySliderTrack,
                thumbColor: kNetPayGold,
                overlayColor: kNetPayGoldSoft,
              ),
              child: Slider(
                value: sliderValue,
                min: sliderMin,
                max: sliderMax,
                onChanged: onSliderChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sliderMinLabel,
                      style: CmSlider.rangeLabel
                          .copyWith(color: kNetPayTextSecondary)),
                  Text(sliderMaxLabel,
                      style: CmSlider.rangeLabel
                          .copyWith(color: kNetPayTextSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
