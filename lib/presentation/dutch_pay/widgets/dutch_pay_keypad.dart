import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../dutch_pay_colors.dart';

class DutchPayKeypad extends StatelessWidget {
  const DutchPayKeypad({super.key, required this.onKeyPressed, this.onLongPressBackspace});

  final ValueChanged<String> onKeyPressed;
  final VoidCallback? onLongPressBackspace;

  static const _buttons = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['00', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDutchBg1.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: kDutchDivider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in _buttons)
            Row(
              children: [
                for (final label in row)
                  Expanded(
                    child: _KeypadBtn(
                      label: label,
                      onTap: () => onKeyPressed(label),
                      onLongPress: label == '⌫'
                          ? (onLongPressBackspace ?? () => onKeyPressed('AC'))
                          : null,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _KeypadBtn extends StatelessWidget {
  const _KeypadBtn({required this.label, required this.onTap, this.onLongPress});

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      splashColor: kDutchAccent.withValues(alpha: 0.08),
      child: SizedBox(
        height: 58,
        child: Center(
          child: switch (label) {
            '⌫' => const Icon(Icons.backspace_outlined,
                color: kDutchTextSecondary, size: keypadBackspaceSize),
            _ => Text(
                label,
                style: keypadNumberText
                    .copyWith(color: kDutchTextPrimary),
              ),
          },
        ),
      ),
    );
  }
}
