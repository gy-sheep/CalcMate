import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_colors.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum CalcBtnType { number, operator, function, equals }

// ──────────────────────────────────────────
// 버튼 패드
// ──────────────────────────────────────────
class ButtonPad extends ConsumerWidget {
  const ButtonPad({super.key});

  static const _rows = [
    [('⌫', CalcBtnType.function), ('AC', CalcBtnType.function), ('%', CalcBtnType.function), ('÷', CalcBtnType.operator)],
    [('7', CalcBtnType.number), ('8', CalcBtnType.number), ('9', CalcBtnType.number), ('×', CalcBtnType.operator)],
    [('4', CalcBtnType.number), ('5', CalcBtnType.number), ('6', CalcBtnType.number), ('-', CalcBtnType.operator)],
    [('1', CalcBtnType.number), ('2', CalcBtnType.number), ('3', CalcBtnType.number), ('+', CalcBtnType.operator)],
    [('()', CalcBtnType.function), ('0', CalcBtnType.number), ('.', CalcBtnType.number), ('=', CalcBtnType.equals)],
  ];

  CalculatorIntent _intentFor(String label) {
    return switch (label) {
      '⌫' => const CalculatorIntent.backspacePressed(),
      'AC' => const CalculatorIntent.clearPressed(),
      '%' => const CalculatorIntent.percentPressed(),
      '÷' || '×' || '-' || '+' => CalculatorIntent.operatorPressed(label),
      '=' => const CalculatorIntent.equalsPressed(),
      '()' => const CalculatorIntent.parenthesesPressed(),
      '.' => const CalculatorIntent.decimalPressed(),
      _ => CalculatorIntent.numberPressed(label),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(basicCalculatorViewModelProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            return Expanded(
              child: CalcButton(
                label: cell.$1,
                type: cell.$2,
                onTap: () => vm.handleIntent(_intentFor(cell.$1)),
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
class CalcButton extends StatelessWidget {
  final String label;
  final CalcBtnType type;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor => switch (type) {
        CalcBtnType.number => kCalcColorNumber,
        CalcBtnType.operator => kCalcColorOperator,
        CalcBtnType.function => kCalcColorFunction,
        CalcBtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == CalcBtnType.equals ? kCalcColorEquals : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: keypadButtonHeightLarge,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: keypadBackspaceSize)
                : Text(
                    label,
                    style: (const ['÷', '×', '-', '+', '='].contains(label)
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
