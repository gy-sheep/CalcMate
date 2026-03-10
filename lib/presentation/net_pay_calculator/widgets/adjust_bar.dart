import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/net_pay_state.dart';
import '../net_pay_calculator_colors.dart';

class AdjustBar extends StatelessWidget {
  const AdjustBar({
    super.key,
    required this.unit,
    required this.onDecrease,
    required this.onIncrease,
    required this.onUnitChanged,
  });

  final AdjustUnit unit;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final ValueChanged<AdjustUnit> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AdjustButton(
          icon: Icons.remove,
          enabled: onDecrease != null,
          onTap: onDecrease,
        ),
        const SizedBox(width: 12),
        _UnitSelector(unit: unit, onChanged: onUnitChanged),
        const SizedBox(width: 12),
        _AdjustButton(
          icon: Icons.add,
          enabled: onIncrease != null,
          onTap: onIncrease,
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({
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
        width: CmRoundButton.large.size,
        height: CmRoundButton.large.size,
        decoration: BoxDecoration(
          color: enabled ? kNetPayGoldSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(CmRoundButton.large.radius),
          border: Border.all(
            color: enabled
                ? kNetPayGold.withValues(alpha: 0.4)
                : kNetPayTextDisabled,
          ),
        ),
        child: Icon(
          icon,
          size: CmRoundButton.large.iconSize,
          color: enabled ? kNetPayGold : kNetPayTextDisabled,
        ),
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({required this.unit, required this.onChanged});

  final AdjustUnit unit;
  final ValueChanged<AdjustUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AdjustUnit>(
      onSelected: onChanged,
      offset: const Offset(0, -180),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput)),
      color: kNetPayCardBg,
      itemBuilder: (_) => AdjustUnit.values.map((u) {
        final selected = u == unit;
        return PopupMenuItem(
          value: u,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Icon(Icons.check, size: 16, color: kNetPayGold)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(u.label,
                  style: AppTokens.textStyleBody.copyWith(
                    color: selected ? kNetPayGold : kNetPayTextPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kNetPayGoldSoft,
          borderRadius: BorderRadius.circular(AppTokens.radiusChip),
          border: Border.all(color: kNetPayGold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(unit.label,
                style: AppTokens.textStyleBody.copyWith(
                    color: kNetPayGold, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: AppTokens.sizeIconDropdown, color: kNetPayGold),
          ],
        ),
      ),
    );
  }
}
