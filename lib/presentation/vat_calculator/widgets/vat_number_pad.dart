import 'package:flutter/material.dart';

import '../vat_calculator_colors.dart';

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum VatBtnType { number, operator, function, equals }

// ──────────────────────────────────────────
// 숫자 키패드 (5x4)
// ──────────────────────────────────────────
class VatNumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;

  const VatNumberPad({super.key, required this.onKeyTap});

  static const _rows = [
    [
      ('\u{232B}', VatBtnType.function),
      ('AC', VatBtnType.function),
      ('%', VatBtnType.function),
      ('\u{00F7}', VatBtnType.operator)
    ],
    [
      ('7', VatBtnType.number),
      ('8', VatBtnType.number),
      ('9', VatBtnType.number),
      ('\u{00D7}', VatBtnType.operator)
    ],
    [
      ('4', VatBtnType.number),
      ('5', VatBtnType.number),
      ('6', VatBtnType.number),
      ('-', VatBtnType.operator)
    ],
    [
      ('1', VatBtnType.number),
      ('2', VatBtnType.number),
      ('3', VatBtnType.number),
      ('+', VatBtnType.operator)
    ],
    [
      ('00', VatBtnType.number),
      ('0', VatBtnType.number),
      ('.', VatBtnType.number),
      ('=', VatBtnType.equals)
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
            return Expanded(
              child: VatKeypadButton(
                label: label,
                type: cell.$2,
                onTap: () => onKeyTap(label),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────
// 단일 버튼
// ──────────────────────────────────────────
class VatKeypadButton extends StatelessWidget {
  final String label;
  final VatBtnType type;
  final VoidCallback onTap;

  const VatKeypadButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor => switch (type) {
        VatBtnType.number => kVatColorNumber,
        VatBtnType.operator => kVatColorOperator,
        VatBtnType.function => kVatColorFunction,
        VatBtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == VatBtnType.equals ? kVatColorEquals : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: 68,
          child: Center(
            child: label == '\u{232B}'
                ? Icon(Icons.backspace_outlined,
                    color: _textColor, size: 26)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: const [
                        '\u{00F7}',
                        '\u{00D7}',
                        '-',
                        '+',
                        '='
                      ].contains(label)
                          ? 28
                          : 22,
                      fontWeight: FontWeight.w400,
                      color: _textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
