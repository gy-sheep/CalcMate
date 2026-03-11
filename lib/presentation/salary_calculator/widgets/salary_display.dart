import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/utils/number_formatter.dart';
import '../salary_calculator_colors.dart';

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
    required this.sliderDivisions,
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
  final int sliderDivisions;
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
          color: kSalaryCardBg,
          borderRadius: BorderRadius.circular(CmInputCard.radius),
          border: Border.all(color: kSalaryAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kSalaryAccent.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
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
                        .copyWith(color: kSalaryAccent)),
                Icon(Icons.edit_outlined,
                    color: kSalaryTextSecondary, size: CmIcon.inputCard),
              ],
            ),
            const SizedBox(height: CmInputCard.titleSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    salary > 0
                        ? NumberFormatter.addCommas(salary.toString())
                        : '0',
                    style:
                        CmInputCard.inputText.copyWith(color: kSalaryTextPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: spacingUnit),
                Text('원',
                    style:
                        CmInputCard.unitText.copyWith(color: kSalaryTextSecondary)),
              ],
            ),
            if (isAnnual && salary > 0) ...[
              const SizedBox(height: CmInputCard.subSpacing),
              Text(
                '월 ${NumberFormatter.addCommas(monthSalary.toString())} 원',
                style: CmInputCard.subText.copyWith(color: kSalaryTextSecondary),
              ),
            ],
            const SizedBox(height: CmSlider.topSpacing),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: CmSlider.trackHeight,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: CmSlider.thumbRadius),
                overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: CmSlider.overlayRadius),
                activeTrackColor: kSalaryAccent,
                inactiveTrackColor: kSalarySliderTrack,
                thumbColor: kSalaryAccent,
                overlayColor: kSalaryAccentSoft,
              ),
              child: Slider(
                value: sliderValue,
                min: sliderMin,
                max: sliderMax,
                divisions: sliderDivisions,
                onChanged: onSliderChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CmSlider.labelPaddingH),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sliderMinLabel,
                      style: CmSlider.rangeLabel
                          .copyWith(color: kSalaryTextSecondary)),
                  Text(sliderMaxLabel,
                      style: CmSlider.rangeLabel
                          .copyWith(color: kSalaryTextSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
