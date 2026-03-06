import 'package:flutter/material.dart';

import '../dutch_pay_colors.dart';

class DutchPayKeypad extends StatelessWidget {
  const DutchPayKeypad({super.key, required this.onKeyPressed});

  final ValueChanged<String> onKeyPressed;

  static const _buttons = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['⌫', '0', '↵'],
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
  const _KeypadBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEnter = label == '↵';
    return InkWell(
      onTap: onTap,
      splashColor: kDutchAccent.withValues(alpha: 0.08),
      child: Container(
        height: 58,
        color: isEnter ? kDutchAccent.withValues(alpha: 0.08) : null,
        child: Center(
          child: switch (label) {
            '⌫' => const Icon(Icons.backspace_outlined,
                color: kDutchTextSecondary, size: 22),
            '↵' => const Icon(Icons.keyboard_return,
                color: kDutchAccent, size: 24),
            _ => Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: kDutchTextPrimary,
                ),
              ),
          },
        ),
      ),
    );
  }
}
