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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hint != null && hint!.isNotEmpty)
          Stack(
            clipBehavior: Clip.none,
            children: [
              amountWidget,
              Positioned(
                top: -16,
                right: 0,
                child: Text(
                  hint!,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          )
        else
          amountWidget,
        Container(
          height: 1.5,
          color: isActive ? Colors.white : Colors.white38,
        ),
      ],
    );
  }
}
