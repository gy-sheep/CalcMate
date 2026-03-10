import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../net_pay_calculator_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kNetPayCardBg,
        border: const Border(top: BorderSide(color: kNetPayCardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('부양가족 수',
                  style: rowLabel.copyWith(color: kNetPayTextPrimary)),
              const SizedBox(width: 4),
              Tooltip(
                message: '본인 포함 기준, 소득세 계산에 반영됩니다',
                child: Icon(Icons.info_outline,
                    size: CmIcon.tooltip, color: kNetPayTextSecondary),
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
                  style: CmStepValue.text.copyWith(color: kNetPayGold),
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
          color: enabled ? kNetPayGoldSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(CmRoundButton.medium.radius),
          border: Border.all(
            color: enabled
                ? kNetPayGold.withValues(alpha: 0.4)
                : kNetPayTextDisabled,
          ),
        ),
        child: Icon(
          icon,
          size: CmRoundButton.medium.iconSize,
          color: enabled ? kNetPayGold : kNetPayTextDisabled,
        ),
      ),
    );
  }
}
