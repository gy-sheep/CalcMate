import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../currency_calculator_colors.dart';

enum CurrencyBtnType { number, operator, function, equals }

class CurrencyNumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;
  final VoidCallback? onLongPressBackspace;

  const CurrencyNumberPad({super.key, required this.onKeyTap, this.onLongPressBackspace});

  static const _rows = [
    [
      ('\u{232B}', CurrencyBtnType.function),
      ('AC', CurrencyBtnType.function),
      ('%', CurrencyBtnType.function),
      ('\u{00F7}', CurrencyBtnType.operator)
    ],
    [
      ('7', CurrencyBtnType.number),
      ('8', CurrencyBtnType.number),
      ('9', CurrencyBtnType.number),
      ('\u{00D7}', CurrencyBtnType.operator)
    ],
    [
      ('4', CurrencyBtnType.number),
      ('5', CurrencyBtnType.number),
      ('6', CurrencyBtnType.number),
      ('-', CurrencyBtnType.operator)
    ],
    [
      ('1', CurrencyBtnType.number),
      ('2', CurrencyBtnType.number),
      ('3', CurrencyBtnType.number),
      ('+', CurrencyBtnType.operator)
    ],
    [
      ('00', CurrencyBtnType.number),
      ('0', CurrencyBtnType.number),
      ('.', CurrencyBtnType.number),
      ('=', CurrencyBtnType.equals)
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            final label = cell.$1;
            final isBack = label == '\u{232B}';
            return Expanded(
              child: CurrencyKeypadButton(
                label: label,
                type: cell.$2,
                onTap: () => onKeyTap(label),
                onLongPress: isBack ? (onLongPressBackspace ?? () => onKeyTap('AC')) : null,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class CurrencyKeypadButton extends StatelessWidget {
  final String label;
  final CurrencyBtnType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CurrencyKeypadButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.onLongPress,
  });

  Color get _textColor => switch (type) {
        CurrencyBtnType.number => kCurrencyKeyNumber,
        CurrencyBtnType.operator => kCurrencyKeyOperator,
        CurrencyBtnType.function => kCurrencyKeyFunction,
        CurrencyBtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == CurrencyBtnType.equals
          ? kCurrencyKeyEquals
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: keypadButtonHeightMedium,
          child: Center(
            child: label == '\u{232B}'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: keypadBackspaceSize)
                : Text(
                    label,
                    style: (const ['\u{00F7}', '\u{00D7}', '-', '+', '=']
                                .contains(label)
                            ? keypadOperatorText
                            : keypadNumberText)
                        .copyWith(color: _textColor),
                  ),
          ),
        ),
      ),
    );
  }
}
