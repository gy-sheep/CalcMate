import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/vat_calculator_state.dart';
import '../../domain/usecases/vat_calculate_usecase.dart';
import '../../domain/utils/number_formatter.dart';
import 'vat_calculator_viewmodel.dart';

// ──────────────────────────────────────────
// 색상 상수
// ──────────────────────────────────────────
const _gradientTop = Color(0xFF141218);
const _gradientBottom = Color(0xFF231F2E);
const _receiptBg = Color(0xFFF5F5F0);
const _receiptText = Color(0xFF2C2C2C);
const _receiptSecondary = Color(0xFF888888);
const _receiptDash = Color(0xFFCCCCCC);
const _receiptDivider = Color(0xFF444444);
const _dividerColor = Color(0x55FFFFFF);
const _colorNumber = Colors.white;
const _colorOperator = Color(0xFFA78BFA);
const _colorFunction = Color(0xCCFFFFFF);
const _colorEquals = Color(0xFF7C3AED);


// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class VatCalculatorScreen extends ConsumerStatefulWidget {
  final String title;
  final IconData icon;

  const VatCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  ConsumerState<VatCalculatorScreen> createState() =>
      _VatCalculatorScreenState();
}

class _VatCalculatorScreenState extends ConsumerState<VatCalculatorScreen> {
  void _showToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (entry.mounted) entry.remove();
    });
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vatCalculatorViewModelProvider);
    final vm = ref.read(vatCalculatorViewModelProvider.notifier);

    ref.listen(
      vatCalculatorViewModelProvider.select((s) => s.toastMessage),
      (_, next) {
        if (next != null) {
          _showToast(next);
          vm.clearToast();
        }
      },
    );

    final vatResult = vm.vatResult;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              _buildAppBar(),
              _buildSegmentControl(state, vm),
              Expanded(
                  child: _buildReceiptCard(state, vm, vatResult)),
              const Divider(
                  color: _dividerColor, thickness: 0.5, height: 1),
              _NumberPad(
                onKeyTap: (key) => vm.handleIntent(
                    VatCalculatorIntent.keyTapped(key)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'calc_icon_${widget.title}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child:
                        Icon(widget.icon, color: Colors.white, size: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Hero(
                tag: 'calc_title_${widget.title}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.title,
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

  Widget _buildSegmentControl(
      VatCalculatorState state, VatCalculatorViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: CupertinoSlidingSegmentedControl<VatMode>(
        groupValue: state.mode,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        thumbColor: _colorEquals.withValues(alpha: 0.9),
        children: const {
          VatMode.exclusive: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '부가세 별도',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          VatMode.inclusive: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '부가세 포함',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        },
        onValueChanged: (value) {
          if (value == null) return;
          vm.handleIntent(VatCalculatorIntent.modeChanged(value));
        },
      ),
    );
  }

  Widget _buildReceiptCard(VatCalculatorState state,
      VatCalculatorViewModel vm, VatResult vatResult) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipPath(
        clipper: _ReceiptClipper(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _receiptBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── 입력 디스플레이 ──
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      vm.formattedInput,
                      style: const TextStyle(
                        color: _receiptText,
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── 점선 구분선 ──
                CustomPaint(
                  painter: _DashedLinePainter(color: _receiptDash),
                  size: const Size(double.infinity, 1),
                ),
                const SizedBox(height: 16),
                // ── 세액 명세 ──
                _ReceiptRow(
                  label: '공급가액',
                  amount:
                      '${NumberFormatter.formatVatResult(vatResult.supplyAmount)}원',
                ),
                const SizedBox(height: 10),
                _buildTaxRateRow(state, vm, vatResult, vm.displayRate),
                const SizedBox(height: 16),
                // ── 실선 구분선 ──
                Container(height: 1.5, color: _receiptDivider),
                const SizedBox(height: 12),
                // ── 합계 ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '합계',
                      style: TextStyle(
                        color: _receiptText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${NumberFormatter.formatVatResult(vatResult.totalAmount)}원',
                      style: const TextStyle(
                        color: _receiptText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaxRateRow(VatCalculatorState state,
      VatCalculatorViewModel vm, VatResult vatResult, int displayRate) {
    final isEditing = state.inputTarget == InputTarget.taxRate;
    final rateText = isEditing && state.taxRateInput.isNotEmpty
        ? state.taxRateInput
        : displayRate.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              '부가세 (',
              style: TextStyle(color: _receiptSecondary, fontSize: 15),
            ),
            GestureDetector(
              onTap: () => vm.handleIntent(
                  const VatCalculatorIntent.taxRateTapped()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEditing
                      ? _colorEquals.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isEditing
                      ? Border.all(color: _colorEquals, width: 1.5)
                      : null,
                ),
                child: Text(
                  '$rateText%',
                  style: TextStyle(
                    color:
                        isEditing ? _colorEquals : _receiptSecondary,
                    fontSize: 15,
                    fontWeight:
                        isEditing ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            const Text(
              ')',
              style: TextStyle(color: _receiptSecondary, fontSize: 15),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showTaxRateInfo(context),
              child: const Icon(
                Icons.info_outline,
                color: _receiptSecondary,
                size: 18,
              ),
            ),
          ],
        ),
        Text(
          '${NumberFormatter.formatVatResult(vatResult.vatAmount)}원',
          style:
              const TextStyle(color: _receiptSecondary, fontSize: 15),
        ),
      ],
    );
  }

  void _showTaxRateInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TaxRateInfoSheet(),
    );
  }
}

// ──────────────────────────────────────────
// 영수증 결과 행
// ──────────────────────────────────────────
class _ReceiptRow extends StatelessWidget {
  final String label;
  final String amount;

  const _ReceiptRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: _receiptSecondary, fontSize: 15),
        ),
        Text(
          amount,
          style: const TextStyle(color: _receiptSecondary, fontSize: 15),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 영수증 톱니 클리퍼
// ──────────────────────────────────────────
class _ReceiptClipper extends CustomClipper<Path> {
  static const _radius = 5.0;
  static const _gap = 6.0; // 반원 사이 평평한 간격

  @override
  Path getClip(Size size) {
    final segmentWidth = _radius * 2 + _gap;
    final count = (size.width / segmentWidth).floor();
    final totalWidth = count * _radius * 2 + (count - 1) * _gap;
    final margin = (size.width - totalWidth) / 2;

    final path = Path();

    // ── 상단 스캘럽 ──
    path.moveTo(0, _radius);
    path.lineTo(margin, _radius);
    for (int i = 0; i < count; i++) {
      final x = margin + i * segmentWidth;
      path.arcToPoint(
        Offset(x + _radius * 2, _radius),
        radius: const Radius.circular(_radius),
        clockwise: false,
      );
      if (i < count - 1) {
        path.lineTo(x + _radius * 2 + _gap, _radius);
      }
    }
    path.lineTo(size.width, _radius);

    // ── 오른쪽 변 ──
    path.lineTo(size.width, size.height - _radius);

    // ── 하단 스캘럽 ──
    path.lineTo(size.width - margin, size.height - _radius);
    for (int i = count - 1; i >= 0; i--) {
      final x = margin + i * segmentWidth;
      path.arcToPoint(
        Offset(x, size.height - _radius),
        radius: const Radius.circular(_radius),
        clockwise: false,
      );
      if (i > 0) {
        path.lineTo(x - _gap, size.height - _radius);
      }
    }
    path.lineTo(0, size.height - _radius);

    // ── 왼쪽 변 ──
    path.lineTo(0, _radius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ──────────────────────────────────────────
// 점선 페인터
// ──────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
          Offset(x, 0), Offset(min(x + dashWidth, size.width), 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────
// 버튼 타입
// ──────────────────────────────────────────
enum _BtnType { number, operator, function, equals }

// ──────────────────────────────────────────
// 숫자 키패드 (5×4)
// ──────────────────────────────────────────
class _NumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;

  const _NumberPad({required this.onKeyTap});

  static const _rows = [
    [
      ('\u{232B}', _BtnType.function),
      ('AC', _BtnType.function),
      ('%', _BtnType.function),
      ('\u{00F7}', _BtnType.operator)
    ],
    [
      ('7', _BtnType.number),
      ('8', _BtnType.number),
      ('9', _BtnType.number),
      ('\u{00D7}', _BtnType.operator)
    ],
    [
      ('4', _BtnType.number),
      ('5', _BtnType.number),
      ('6', _BtnType.number),
      ('-', _BtnType.operator)
    ],
    [
      ('1', _BtnType.number),
      ('2', _BtnType.number),
      ('3', _BtnType.number),
      ('+', _BtnType.operator)
    ],
    [
      ('00', _BtnType.number),
      ('0', _BtnType.number),
      ('.', _BtnType.number),
      ('=', _BtnType.equals)
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
              child: _KeypadButton(
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
class _KeypadButton extends StatelessWidget {
  final String label;
  final _BtnType type;
  final VoidCallback onTap;

  const _KeypadButton({
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

// ──────────────────────────────────────────
// 세율 참고 Bottom Sheet
// ──────────────────────────────────────────
class _TaxRateInfoSheet extends StatelessWidget {
  const _TaxRateInfoSheet();

  static const _rates = [
    ('🇰🇷', '대한민국', '부가가치세', '10%'),
    ('🇯🇵', '일본', '소비세 (일반)', '10%'),
    ('🇯🇵', '일본', '소비세 (경감세율)', '8%'),
    ('🇬🇧', '영국', 'VAT (표준)', '20%'),
    ('🇬🇧', '영국', 'VAT (경감)', '5%'),
    ('🇩🇪', '독일', 'VAT (표준)', '19%'),
    ('🇩🇪', '독일', 'VAT (경감)', '7%'),
    ('🇫🇷', '프랑스', 'VAT (표준)', '20%'),
    ('🇮🇹', '이탈리아', 'VAT (표준)', '22%'),
    ('🇪🇸', '스페인', 'VAT (표준)', '21%'),
    ('🇦🇺', '호주', 'GST', '10%'),
    ('🇨🇦', '캐나다', 'GST', '5%'),
    ('🇳🇿', '뉴질랜드', 'GST', '15%'),
    ('🇸🇬', '싱가포르', 'GST', '9%'),
    ('🇮🇳', '인도', 'GST (표준)', '18%'),
    ('🇨🇳', '중국', 'VAT (일반)', '13%'),
    ('🇧🇷', '브라질', 'ICMS (일반)', '17%'),
    ('🇺🇸', '미국', 'Sales Tax', '주마다 상이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientTop, _gradientBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '세율 참고',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white54, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: _dividerColor, thickness: 0.5, height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _rates.length,
              separatorBuilder: (_, _) => const Divider(
                color: _dividerColor,
                thickness: 0.3,
                height: 1,
              ),
              itemBuilder: (_, index) {
                final (flag, country, taxName, rate) = _rates[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(flag,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              taxName,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        rate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
