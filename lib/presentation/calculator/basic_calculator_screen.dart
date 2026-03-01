import 'package:calcmate/domain/models/calculator_state.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────
// 색상 상수
// ──────────────────────────────────────────
const _gradientTop = Color(0xFF0D2137);
const _gradientBottom = Color(0xFF0A3D2B);
const _colorOperator = Color(0xFFFF9F7A);
const _colorFunction = Color(0xCCFFFFFF);
const _colorNumber = Colors.white;
const _colorEquals = Color(0xFFFF6B4A);

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientTop, _gradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(child: _DisplayPanel(state: state)),
              const Divider(color: Color(0x33FFFFFF), thickness: 0.5, height: 1),
              const _ButtonPad(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'calc_icon_$title',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, color: Colors.white, size: 15),
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 디스플레이 패널
// ──────────────────────────────────────────
class _DisplayPanel extends StatelessWidget {
  final CalculatorState state;

  const _DisplayPanel({required this.state});

  static String _wrapNegatives(String raw) {
    return raw.replaceAllMapped(
      RegExp(r'(^|[+×÷*/])-(\d+(?:\.\d*)?)'),
      (match) => '${match.group(1)}(-${match.group(2)})',
    );
  }

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
    if (raw == '-0') return '0';
    return _formatWithCommas(_wrapNegatives(raw));
  }

  static const _baseStyle = TextStyle(
    fontSize: 56,
    color: Colors.white,
    fontWeight: FontWeight.w300,
    height: 1.1,
  );

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
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
                fontSize: 20,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          // 입력값 / 결과
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
          // 밑줄
          Container(
            height: 1.5,
            color: Colors.white60,
            margin: const EdgeInsets.only(top: 6, bottom: 20),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// 버튼 패드
// ──────────────────────────────────────────
class _ButtonPad extends ConsumerWidget {
  const _ButtonPad();

  static const _rows = [
    [('⌫', _BtnType.function), ('AC', _BtnType.function), ('%', _BtnType.function), ('÷', _BtnType.operator)],
    [('7', _BtnType.number), ('8', _BtnType.number), ('9', _BtnType.number), ('×', _BtnType.operator)],
    [('4', _BtnType.number), ('5', _BtnType.number), ('6', _BtnType.number), ('-', _BtnType.operator)],
    [('1', _BtnType.number), ('2', _BtnType.number), ('3', _BtnType.number), ('+', _BtnType.operator)],
    [('+/-', _BtnType.function), ('0', _BtnType.number), ('.', _BtnType.number), ('=', _BtnType.equals)],
  ];

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
      '=' => const CalculatorIntent.equalsPressed(),
      '+/-' => const CalculatorIntent.negatePressed(),
      '.' => const CalculatorIntent.decimalPressed(),
      _ => CalculatorIntent.numberPressed(label),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(basicCalculatorViewModelProvider.notifier);
    final state = ref.watch(basicCalculatorViewModelProvider);
    final clearLabel = _isAcState(state.input) ? 'AC' : 'C';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Row(
          children: row.map((cell) {
            final label = cell.$1 == 'AC' ? clearLabel : cell.$1;
            return Expanded(
              child: _CalcButton(
                label: label,
                type: cell.$2,
                onTap: () => vm.handleIntent(_intentFor(label)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum _BtnType { number, operator, function, equals }

// ──────────────────────────────────────────
// 단일 버튼
// ──────────────────────────────────────────
class _CalcButton extends StatelessWidget {
  final String label;
  final _BtnType type;
  final VoidCallback onTap;

  const _CalcButton({
    required this.label,
    required this.type,
    required this.onTap,
  });

  Color get _textColor => switch (type) {
        _BtnType.number => _colorNumber,
        _BtnType.operator => _colorOperator,
        _BtnType.function => _colorFunction,
        _BtnType.equals => Colors.white,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: type == _BtnType.equals ? _colorEquals : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: SizedBox(
          height: 68,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: _textColor, size: 26)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: const ['÷', '×', '-', '+', '='].contains(label)
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
