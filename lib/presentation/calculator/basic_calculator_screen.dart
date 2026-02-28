import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasicCalculatorScreen extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Color color;

  const BasicCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicCalculatorViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF888888),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'calc_icon_$title',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 17),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Hero(
              tag: 'calc_title_$title',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'calc_bg_$title',
              child: Container(),
            ),
          ),
          _CalculatorBody(state: state),
        ],
      ),
    );
  }
}

class _CalculatorBody extends StatelessWidget {
  final CalculatorState state;

  const _CalculatorBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _DisplayPanel(state: state)),
        const SizedBox(height: 16),
        const _ButtonPad(),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 디스플레이
// ---------------------------------------------------------------------------

class _DisplayPanel extends StatelessWidget {
  final CalculatorState state;

  const _DisplayPanel({required this.state});

  // 음수를 괄호로 감싸기: -3 → (-3), 100+-3 → 100+(-3)
  static String _wrapNegatives(String raw) {
    return raw.replaceAllMapped(
      RegExp(r'(^|[+×÷*/])-(\d+(?:\.\d*)?)'),
      (match) => '${match.group(1)}(-${match.group(2)})',
    );
  }

  // 천 단위 콤마 삽입
  static String _formatWithCommas(String raw) {
    return raw.replaceAllMapped(RegExp(r'\d+'), (match) {
      final str = match.group(0)!;
      if (str.length <= 3) return str;
      final buf = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
        buf.write(str[i]);
      }
      return buf.toString();
    });
  }

  static String _formatDisplay(String raw) {
    // 음수 대기 상태(-0): 숫자 입력 전까지 0으로 표시
    if (raw == '-0') return '0';
    return _formatWithCommas(_wrapNegatives(raw));
  }

  static const _baseStyle = TextStyle(
    fontSize: 56,
    color: Color(0xFF333333),
    fontWeight: FontWeight.w300,
    height: 1.1,
  );

  // 실제 텍스트를 직접 측정해 꽉 차는 최대 폰트 반환
  // minSize: '12,345,678,323'이 화면에 꽉 차는 크기 (하한선)
  static double _adaptiveFontSize(String text, double maxWidth) {
    double _maxFittingSize(String ref) {
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

    final maxSize = _maxFittingSize('123,456,789');
    final minSize = _maxFittingSize('12,345,678,323');

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _NeumorphicContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 수식 — 계산 완료 후에만 표시
              Visibility(
                visible: state.isResult && state.expression.isNotEmpty,
                child: Text(
                  displayExpression,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              // 입력값 / 결과 — 56→54→52→50 단계 축소, 이후 50 고정
              // reverse: true → 오른쪽(최신 입력) 고정, 넘치면 왼쪽이 밀려남
              LayoutBuilder(
                builder: (context, constraints) {
                  final fontSize =
                      _adaptiveFontSize(displayInput, constraints.maxWidth);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Text(
                      displayInput,
                      maxLines: 1,
                      softWrap: false,
                      style: _baseStyle.copyWith(fontSize: fontSize),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 버튼 패드
// ---------------------------------------------------------------------------

class _ButtonPad extends ConsumerWidget {
  const _ButtonPad();

  static const _gap = 14.0;
  static const _numCols = 4;

  static const _rows = [
    [('⌫', _BtnType.function), ('AC', _BtnType.function), ('%', _BtnType.function), ('÷', _BtnType.operator)],
    [('7', _BtnType.number), ('8', _BtnType.number), ('9', _BtnType.number), ('×', _BtnType.operator)],
    [('4', _BtnType.number), ('5', _BtnType.number), ('6', _BtnType.number), ('-', _BtnType.operator)],
    [('1', _BtnType.number), ('2', _BtnType.number), ('3', _BtnType.number), ('+', _BtnType.operator)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(basicCalculatorViewModelProvider.notifier);
    final state = ref.watch(basicCalculatorViewModelProvider);
    // AC 상태: 의미 있는 입력이 없는 초기-like 상태
    // '0', '-', '0+', '0-', '0×', '0÷' → AC / 그 외 → C
    final clearLabel = _isAcState(state.input) ? 'AC' : 'C';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellW = (constraints.maxWidth - _gap * (_numCols - 1)) / _numCols;
          final cellH = cellW;

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              for (final row in _rows) ...[
                SizedBox(
                  height: cellH,
                  child: Row(
                    children: [
                      for (int i = 0; i < row.length; i++) ...[
                        if (i > 0) const SizedBox(width: _gap),
                        SizedBox(
                          width: cellW,
                          child: _CalcButton(
                            label: row[i].$1 == 'AC' ? clearLabel : row[i].$1,
                            type: row[i].$2,
                            onTap: () => vm.handleIntent(
                              _intentFor(row[i].$1 == 'AC' ? clearLabel : row[i].$1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: _gap),
              ],
              // 마지막 행: +/-, 0, ., =
              SizedBox(
                height: cellH,
                child: Row(
                  children: [
                    SizedBox(
                      width: cellW,
                      child: _CalcButton(
                        label: '+/-',
                        type: _BtnType.function,
                        onTap: () => vm.handleIntent(const CalculatorIntent.negatePressed()),
                      ),
                    ),
                    const SizedBox(width: _gap),
                    SizedBox(
                      width: cellW,
                      child: _CalcButton(
                        label: '0',
                        type: _BtnType.number,
                        onTap: () => vm.handleIntent(const CalculatorIntent.numberPressed('0')),
                      ),
                    ),
                    const SizedBox(width: _gap),
                    SizedBox(
                      width: cellW,
                      child: _CalcButton(
                        label: '.',
                        type: _BtnType.number,
                        onTap: () => vm.handleIntent(const CalculatorIntent.decimalPressed()),
                      ),
                    ),
                    const SizedBox(width: _gap),
                    SizedBox(
                      width: cellW,
                      child: _CalcButton(
                        label: '=',
                        type: _BtnType.equals,
                        onTap: () => vm.handleIntent(const CalculatorIntent.equalsPressed()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static bool _isAcState(String input) {
    if (input == '0' || input == '-') return true;
    if (input.length == 2 && input[0] == '0') {
      return const {'+', '-', '×', '÷'}.contains(input[1]);
    }
    return false;
  }

  CalculatorIntent _intentFor(String label) {
    return switch (label) {
      '⌫' => const CalculatorIntent.backspacePressed(),
      'AC' || 'C' => const CalculatorIntent.clearPressed(),
      '%' => const CalculatorIntent.percentPressed(),
      '÷' || '×' || '-' || '+' => CalculatorIntent.operatorPressed(label),
      _ => CalculatorIntent.numberPressed(label),
    };
  }
}

// ---------------------------------------------------------------------------
// 버튼 타입
// ---------------------------------------------------------------------------

enum _BtnType { number, operator, function, equals }

// ---------------------------------------------------------------------------
// 단일 버튼
// ---------------------------------------------------------------------------

class _CalcButton extends StatelessWidget {
  final String label;
  final _BtnType type;
  final VoidCallback onTap;

  const _CalcButton({
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor {
    return switch (type) {
      _BtnType.equals => Colors.white,
      _BtnType.operator => const Color(0xFFE8735A),
      _BtnType.function => const Color(0xFF888888),
      _BtnType.number => const Color(0xFF333333),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: type == _BtnType.equals
          ? _ElevatedButton(label: label, textColor: _textColor)
          : _NeumorphicButton(label: label, textColor: _textColor),
    );
  }
}

// ---------------------------------------------------------------------------
// 뉴모피즘 버튼
// ---------------------------------------------------------------------------

class _NeumorphicButton extends StatelessWidget {
  final String label;
  final Color textColor;

  const _NeumorphicButton({
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFFFFFF),
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Color(0xFFCCCDD0),
            offset: Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: label == '⌫'
            ? Icon(Icons.backspace_outlined, color: textColor, size: 28)
            : Text(
                label,
                style: TextStyle(
                  fontSize: const ['÷', '×', '-', '+'].contains(label) ? 28 : 22,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// = 버튼
// ---------------------------------------------------------------------------

class _ElevatedButton extends StatelessWidget {
  final String label;
  final Color textColor;

  const _ElevatedButton({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8735A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8735A).withValues(alpha: 0.45),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 뉴모피즘 컨테이너 (디스플레이용)
// ---------------------------------------------------------------------------

class _NeumorphicContainer extends StatelessWidget {
  final Widget child;

  const _NeumorphicContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFFFFFFF),
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Color(0xFFCCCDD0),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
