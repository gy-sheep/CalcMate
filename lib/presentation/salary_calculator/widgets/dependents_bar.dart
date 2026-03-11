import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../salary_calculator_colors.dart';

class DependentsBar extends StatelessWidget {
  const DependentsBar({
    super.key,
    required this.dependents,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int dependents;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CmBottomBar.padding,
      decoration: BoxDecoration(
        color: kSalaryCardBg,
        border: const Border(top: BorderSide(color: kSalaryCardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('부양가족 수',
                  style: rowLabel.copyWith(color: kSalaryTextPrimary)),
              const SizedBox(width: CmBottomBar.labelIconSpacing),
              Tooltip(
                message: '본인 포함 기준, 소득세 계산에 반영됩니다',
                child: Icon(Icons.info_outline,
                    size: CmIcon.tooltip, color: kSalaryTextSecondary),
              ),
            ],
          ),
          Row(
            children: [
              _StepButton(
                  icon: Icons.remove,
                  enabled: onDecrease != null,
                  onTap: onDecrease),
              Container(
                width: CmStepValue.width,
                margin: EdgeInsets.symmetric(
                    horizontal: CmStepValue.horizontalMargin),
                child: Text(
                  '$dependents명',
                  textAlign: TextAlign.center,
                  style: CmStepValue.text.copyWith(color: kSalaryAccent),
                ),
              ),
              _StepButton(
                  icon: Icons.add,
                  enabled: onIncrease != null,
                  onTap: onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: CmRoundButton.medium.size,
        height: CmRoundButton.medium.size,
        decoration: BoxDecoration(
          color: enabled ? kSalaryAccentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(CmRoundButton.medium.radius),
          border: Border.all(
            color: enabled
                ? kSalaryAccent.withValues(alpha: 0.3)
                : kSalaryTextDisabled,
          ),
        ),
        child: Icon(
          icon,
          size: CmRoundButton.medium.iconSize,
          color: enabled ? kSalaryAccent : kSalaryTextDisabled,
        ),
      ),
    );
  }
}
