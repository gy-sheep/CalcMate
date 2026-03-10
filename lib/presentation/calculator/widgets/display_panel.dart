import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/presentation/widgets/app_input_underline.dart';
import 'package:flutter/material.dart';

class DisplayPanel extends StatelessWidget {
  final CalculatorState state;

  const DisplayPanel({super.key, required this.state});

  static String _formatWithCommas(String raw) {
    return raw.replaceAllMapped(RegExp(r'\d+\.?\d*'), (match) {
      final str = match.group(0)!;
      final parts = str.split('.');
      if (parts[0].length <= 3) return str;
      final buf = StringBuffer();
      final digits = parts[0];
      for (int i = 0; i < digits.length; i++) {
        if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
        buf.write(digits[i]);
      }
      return parts.length > 1 ? '${buf.toString()}.${parts[1]}' : buf.toString();
    });
  }

  static String _formatDisplay(String raw) {
    if (raw == '-0') return '0';
    return _formatWithCommas(raw);
  }

  /// 텍스트가 주어진 너비 안에 한 줄로 들어가는지 확인한다.
  static bool _fitsInWidth(String text, TextStyle style, double maxWidth) {
    final p = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return p.width <= maxWidth;
  }

  /// 연산 기호 앞에 줄바꿈 문자를 삽입한다.
  static String _breakAtOperators(String raw) {
    return raw.replaceAllMapped(
      RegExp(r'(?<=[^(])([+\-×÷])'),
      (m) => '\n${m.group(1)}',
    );
  }

  static final _baseStyle = CmInfoCard.displayText.copyWith(
    color: Colors.white,
  );

  static double _adaptiveFontSize(String text, double maxWidth) {
    double maxFittingSize(String ref) {
      for (double size = 80.0; size >= 10; size -= 1) {
        final p = TextPainter(
          text: TextSpan(text: ref, style: _baseStyle.copyWith(fontSize: size)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        if (p.width <= maxWidth) return size;
      }
      return 10;
    }

    final maxSize = maxFittingSize('123,456,789');
    final minSize = maxFittingSize('12,345,678,323');

    for (double size = maxSize; size >= minSize; size -= 1) {
      final p = TextPainter(
        text: TextSpan(text: text, style: _baseStyle.copyWith(fontSize: size)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (p.width <= maxWidth) return size;
    }
    return minSize;
  }

  @override
  Widget build(BuildContext context) {
    final displayInput = _formatDisplay(state.input);
    final displayExpression = _formatDisplay(state.expression);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 수식 — 계산 완료 후에만 표시
          Visibility(
            visible: state.isResult && state.expression.isNotEmpty,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const exprStyle = TextStyle(
                  fontSize: 20,
                  color: Colors.white54,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                );
                final fitsOneLine = _fitsInWidth(
                  displayExpression, exprStyle, constraints.maxWidth,
                );
                final exprText = fitsOneLine
                    ? displayExpression
                    : _breakAtOperators(displayExpression);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    exprText,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    style: exprStyle,
                  ),
                );
              },
            ),
          ),
          // 입력값 / 결과 + 밑줄
          AppInputUnderline(
            style: InputUnderlineStyle.full,
            color: Colors.white60,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fontSize =
                    _adaptiveFontSize(displayInput, constraints.maxWidth);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    displayInput,
                    maxLines: 1,
                    softWrap: false,
                    style: _baseStyle.copyWith(fontSize: fontSize),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
