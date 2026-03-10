import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../unit_converter_colors.dart';

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum UnitBtnType { number, function }

// ──────────────────────────────────────────
// 숫자 키패드 (4×4)
// ──────────────────────────────────────────
class UnitNumberPad extends StatelessWidget {
  final bool isTemperature;
  final ValueChanged<String> onKey;
  final ValueChanged<int> onArrow;

  const UnitNumberPad({
    super.key,
    required this.isTemperature,
    required this.onKey,
    required this.onArrow,
  });

  List<List<(String, UnitBtnType)>> get _rows => [
    [('7', UnitBtnType.number), ('8', UnitBtnType.number), ('9', UnitBtnType.number), ('\u{232B}', UnitBtnType.function)],
    [('4', UnitBtnType.number), ('5', UnitBtnType.number), ('6', UnitBtnType.number), ('AC', UnitBtnType.function)],
    [('1', UnitBtnType.number), ('2', UnitBtnType.number), ('3', UnitBtnType.number), ('▲', UnitBtnType.function)],
    [(isTemperature ? '+/-' : '00', isTemperature ? UnitBtnType.function : UnitBtnType.number), ('0', UnitBtnType.number), ('.', UnitBtnType.number), ('▼', UnitBtnType.function)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            return Expanded(
              child: UnitKeypadButton(
                label: cell.$1,
                type: cell.$2,
                onTap: cell.$1 == '▲'
                    ? () => onArrow(-1)
                    : cell.$1 == '▼'
                        ? () => onArrow(1)
                        : cell.$1 == '\u{232B}'
                            ? () => onKey('⌫')
                            : () => onKey(cell.$1),
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
class UnitKeypadButton extends StatelessWidget {
  final String label;
  final UnitBtnType type;
  final VoidCallback onTap;

  const UnitKeypadButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor => switch (type) {
        UnitBtnType.number => kUnitColorNumber,
        UnitBtnType.function => kUnitColorFunction,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: keypadButtonHeightLarge,
          child: Center(
            child: label == '\u{232B}'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: keypadBackspaceSize)
                : label == '▲'
                    ? Icon(Icons.keyboard_arrow_up, color: _textColor, size: 28)
                    : label == '▼'
                        ? Icon(Icons.keyboard_arrow_down, color: _textColor, size: 28)
                        : label == '+/-'
                            ? _buildPlusMinusLabel(_textColor)
                            : Text(
                                label,
                                style: keypadNumberText
                                    .copyWith(color: _textColor),
                              ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPlusMinusLabel(Color color) {
    const style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -2),
          child: Text('+', style: style.copyWith(color: color)),
        ),
        Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: color)),
        Transform.translate(
          offset: const Offset(0, 2),
          child: Text('-', style: style.copyWith(color: color, fontSize: 24)),
        ),
      ],
    );
  }
}
