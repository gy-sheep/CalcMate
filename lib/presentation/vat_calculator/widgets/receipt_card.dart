import 'dart:math';

import 'package:calcmate/core/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/vat_calculator_state.dart';
import '../../../domain/usecases/vat_calculate_usecase.dart';
import '../../../domain/utils/number_formatter.dart';
import '../vat_calculator_colors.dart';
import '../vat_calculator_viewmodel.dart';

// ──────────────────────────────────────────
// 영수증 카드
// ──────────────────────────────────────────
class ReceiptCard extends StatelessWidget {
  final VatCalculatorState state;
  final VatCalculatorViewModel vm;
  final VatResult vatResult;
  final VoidCallback onTaxRateInfoTapped;

  const ReceiptCard({
    super.key,
    required this.state,
    required this.vm,
    required this.vatResult,
    required this.onTaxRateInfoTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipPath(
        clipper: ReceiptClipper(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: kVatReceiptBg,
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
                GestureDetector(
                  onTap: () => vm.handleIntent(
                      const VatCalculatorIntent.amountTapped()),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        vm.formattedInput,
                        style: AppTokens.textStyleResult40.copyWith(
                          color: kVatReceiptText,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // ── 점선 구분선 ──
                CustomPaint(
                  painter: DashedLinePainter(color: kVatReceiptDash),
                  size: const Size(double.infinity, 1),
                ),
                const SizedBox(height: 8),
                // ── 부가세 별도 체크박스 ──
                Transform.translate(
                  offset: const Offset(-11, 0),
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppTokens.sizeCheckboxLarge,
                      height: AppTokens.sizeCheckboxLarge,
                      child: Checkbox(
                        value: state.mode == VatMode.exclusive,
                        onChanged: (v) => vm.handleIntent(
                          VatCalculatorIntent.modeChanged(
                            v == true ? VatMode.exclusive : VatMode.inclusive,
                          ),
                        ),
                        activeColor: kVatReceiptText,
                        checkColor: kVatReceiptBg,
                        side: const BorderSide(color: kVatReceiptSecondary, width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '부가세 별도',
                      style: AppTokens.textStyleCheckboxLabelLarge
                          .copyWith(color: kVatReceiptSecondary),
                    ),
                  ],
                  ),
                ),
                const SizedBox(height: 8),
                // ── 점선 구분선 ──
                CustomPaint(
                  painter: DashedLinePainter(color: kVatReceiptDash),
                  size: const Size(double.infinity, 1),
                ),
                const SizedBox(height: 16),
                // ── 세액 명세 ──
                ReceiptRow(
                  label: '공급가액',
                  amount:
                      '${NumberFormatter.formatVatResult(vatResult.supplyAmount)}원',
                ),
                const SizedBox(height: 10),
                _buildTaxRateRow(),
                const SizedBox(height: 16),
                // ── 실선 구분선 ──
                Container(height: 1.5, color: kVatReceiptDivider),
                const SizedBox(height: 12),
                // ── 합계 ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '합계',
                      style: AppTokens.textStyleResult18.copyWith(
                        color: kVatReceiptText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${NumberFormatter.formatVatResult(vatResult.totalAmount)}원',
                      style: AppTokens.textStyleResult22.copyWith(
                        fontWeight: FontWeight.w700,
                        color: kVatReceiptText,
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

  Widget _buildTaxRateRow() {
    final displayRate = vm.displayRate;
    final isEditing = state.inputTarget == InputTarget.taxRate;
    final rateText = isEditing && state.taxRateInput.isNotEmpty
        ? state.taxRateInput
        : displayRate.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '부가세 (',
              style: AppTokens.textStyleCaption.copyWith(color: kVatReceiptSecondary),
            ),
            GestureDetector(
              onTap: () => vm.handleIntent(
                  const VatCalculatorIntent.taxRateTapped()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEditing
                      ? kVatColorEquals.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isEditing
                      ? Border.all(color: kVatColorEquals, width: 1.5)
                      : null,
                ),
                child: Text(
                  '$rateText%',
                  style: AppTokens.textStyleCaption.copyWith(
                    color: isEditing ? kVatColorEquals : kVatReceiptSecondary,
                    fontWeight: isEditing ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            Text(
              ')',
              style: AppTokens.textStyleCaption.copyWith(color: kVatReceiptSecondary),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onTaxRateInfoTapped,
              child: const Icon(
                Icons.info_outline,
                color: kVatReceiptSecondary,
                size: AppTokens.sizeIconSmall,
              ),
            ),
          ],
        ),
        Text(
          '${NumberFormatter.formatVatResult(vatResult.vatAmount)}원',
          style: AppTokens.textStyleCaption.copyWith(color: kVatReceiptSecondary),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 영수증 결과 행
// ──────────────────────────────────────────
class ReceiptRow extends StatelessWidget {
  final String label;
  final String amount;

  const ReceiptRow({super.key, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTokens.textStyleCaption.copyWith(color: kVatReceiptSecondary),
        ),
        Text(
          amount,
          style: AppTokens.textStyleCaption.copyWith(color: kVatReceiptSecondary),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// 영수증 톱니 클리퍼
// ──────────────────────────────────────────
class ReceiptClipper extends CustomClipper<Path> {
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
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

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
