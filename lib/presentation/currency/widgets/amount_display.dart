import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:calcmate/presentation/widgets/app_input_underline.dart';
import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;
  final bool isActive;
  final String? hint;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.isActive,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final amountWidget = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        amount,
        maxLines: 1,
        softWrap: false,
        style: AppTokens.textStyleResult28.copyWith(
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );

    return AppInputUnderline(
      style: InputUnderlineStyle.full,
      color: isActive ? Colors.white : Colors.white38,
      child: hint != null && hint!.isNotEmpty
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Row(children: [Expanded(child: amountWidget)]),
                Positioned(
                  top: -16,
                  right: 0,
                  child: Text(
                    hint!,
                    style: AppTokens.textStyleCaption.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                ),
              ],
            )
          : amountWidget,
    );
  }
}
