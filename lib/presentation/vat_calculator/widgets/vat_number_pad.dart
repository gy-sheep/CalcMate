import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../vat_calculator_colors.dart';

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum VatBtnType { number, function, equals }

// ──────────────────────────────────────────
// 숫자 키패드 (4×4, = 버튼 2행 병합)
// ──────────────────────────────────────────
class VatNumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;
  final VoidCallback? onLongPressBackspace;

  const VatNumberPad({super.key, required this.onKeyTap, this.onLongPressBackspace});

  Widget _btn(String label, VatBtnType type) => Expanded(
        child: VatKeypadButton(
          label: label,
          type: type,
          onTap: () => onKeyTap(label),
          onLongPress: label == '\u{232B}'
              ? (onLongPressBackspace ?? () => onKeyTap('AC'))
              : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          _btn('7', VatBtnType.number),
          _btn('8', VatBtnType.number),
          _btn('9', VatBtnType.number),
          _btn('\u{232B}', VatBtnType.function),
        ]),
        Row(children: [
          _btn('4', VatBtnType.number),
          _btn('5', VatBtnType.number),
          _btn('6', VatBtnType.number),
          _btn('AC', VatBtnType.function),
        ]),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    _btn('1', VatBtnType.number),
                    _btn('2', VatBtnType.number),
                    _btn('3', VatBtnType.number),
                  ]),
                  Row(children: [
                    _btn('00', VatBtnType.number),
                    _btn('0', VatBtnType.number),
                    _btn('.', VatBtnType.number),
                  ]),
                ],
              ),
            ),
            Expanded(
              child: VatKeypadButton(
                label: '=',
                type: VatBtnType.equals,
                onTap: () => onKeyTap('='),
                height: keypadButtonHeightLarge * 2,
              ),
            ),
          ],
        ),
      ],
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
  final VoidCallback? onLongPress;
  final double? height;

  const VatKeypadButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.onLongPress,
    this.height,
  });

  Color get _textColor => switch (type) {
        VatBtnType.number => kVatColorNumber,
        VatBtnType.function => kVatColorFunction,
        VatBtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == VatBtnType.equals ? kVatColorEquals : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: height ?? keypadButtonHeightLarge,
          child: Center(
            child: switch (label) {
              '\u{232B}' => Icon(Icons.backspace_outlined,
                  color: _textColor, size: keypadBackspaceSize),
              '=' => Icon(Icons.keyboard_return,
                  color: _textColor, size: keypadBackspaceSize),
              _ => Text(
                  label,
                  style: keypadNumberText
                      .copyWith(color: _textColor),
                ),
            },
          ),
        ),
      ),
    );
  }
}
