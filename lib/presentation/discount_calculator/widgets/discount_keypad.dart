import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../discount_calculator_colors.dart';

// ──────────────────────────────────────────
// 숫자 키패드
// ──────────────────────────────────────────
class DiscountKeypad extends StatelessWidget {
  final void Function(String) onKey;

  const DiscountKeypad({
    super.key,
    required this.onKey,
  });

  static const _rows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['00', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((key) {
            return Expanded(
              child: DiscountKeypadButton(
                label: key,
                isSpecial: key == '⌫',
                onTap: () => onKey(key),
                onLongPress: key == '⌫' ? () => onKey('AC') : null,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class DiscountKeypadButton extends StatelessWidget {
  final String label;
  final bool isSpecial;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DiscountKeypadButton({
    super.key,
    required this.label,
    required this.isSpecial,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSpecial ? kDiscountKeyFunction : kDiscountKeyNumber;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: Colors.black12,
        highlightColor: Colors.black12,
        child: SizedBox(
          height: keypadButtonHeightMedium,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined,
                    color: color, size: keypadBackspaceSize)
                : Text(
                    label,
                    style: keypadNumberText
                        .copyWith(color: color),
                  ),
          ),
        ),
      ),
    );
  }
}
