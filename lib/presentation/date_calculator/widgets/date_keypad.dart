import 'dart:ui';

import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../date_calculator_colors.dart';

class DateKeypad extends StatelessWidget {
  const DateKeypad({super.key, required this.onKeyPressed});

  final ValueChanged<String> onKeyPressed;

  static const _buttons = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['+/-', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final row in _buttons)
                Row(
                  children: [
                    for (final label in row)
                      Expanded(child: _buildKeyButton(label)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label) {
    return GestureDetector(
      onTap: () => onKeyPressed(label),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: label == '⌫'
              ? const Icon(Icons.backspace_outlined,
                  color: kDateTextSecondary, size: AppTokens.sizeKeypadBackspace)
              : Text(
                  label,
                  style: AppTokens.textStyleKeypadNumber
                      .copyWith(color: kDateTextPrimary),
                ),
        ),
      ),
    );
  }
}
