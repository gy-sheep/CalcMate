import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/bmi_calculate_usecase.dart';

// ── 색상 (스크린에서 주입받지 않고, BMI 게이지 전용 상수) ──────────────────────
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB0BEC5);
const _kSliderTrack = Color(0xFF2A4060);
const _kBgBottom = Color(0xFF0D1B2A);

class BmiGauge extends StatelessWidget {
  const BmiGauge({
    super.key,
    required this.bmiAnim,
    required this.bmi,
    required this.category,
    required this.categories,
    required this.standardLabel,
  });

  final Animation<double> bmiAnim;
  final double bmi;
  final BmiCategoryDef category;
  final List<BmiCategoryDef> categories;
  final String standardLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final gaugeHeight = constraints.maxWidth / 2 + 8;
      return SizedBox(
        height: gaugeHeight,
        child: AnimatedBuilder(
          animation: bmiAnim,
          builder: (context0, _) => Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(
                    needleAngle: bmiAnim.value,
                    categories: categories,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: bmi),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context1, v, _) => Text(
                        v.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: AppTokens.textStyleResult52
                            .copyWith(color: _kTextPrimary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        category.label,
                        key: ValueKey(category.label),
                        textAlign: TextAlign.center,
                        style: AppTokens.textStyleValue
                            .copyWith(color: category.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      standardLabel,
                      textAlign: TextAlign.center,
                      style: AppTokens.textStyleLabelSmall
                          .copyWith(color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── GaugePainter ───────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.needleAngle,
    required this.categories,
  });

  final double needleAngle;
  final List<BmiCategoryDef> categories;

  static const _bmiMin = 10.0;
  static const _bmiMax = 40.0;

  double _bmiToRad(double bmi) {
    final t = ((bmi - _bmiMin) / (_bmiMax - _bmiMin)).clamp(0.0, 1.0);
    return math.pi * (1 - t);
  }

  double _bmiToArc(double bmi) {
    final t = ((bmi - _bmiMin) / (_bmiMax - _bmiMin)).clamp(0.0, 1.0);
    return math.pi * (1 + t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final outerR = size.width / 2 - 8;
    final innerR = outerR * 0.72;
    final arcR = (outerR + innerR) / 2;
    final arcW = outerR - innerR;

    // 트랙 배경
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
      math.pi, math.pi, false,
      Paint()
        ..color = _kSliderTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = arcW
        ..strokeCap = StrokeCap.butt,
    );

    // 컬러 구간
    for (final cat in categories) {
      final fromBmi = cat.min.clamp(_bmiMin, _bmiMax);
      final toBmi = cat.max == double.infinity
          ? _bmiMax
          : cat.max.clamp(_bmiMin, _bmiMax);
      final startAngle = _bmiToArc(fromBmi);
      final sweepAngle = _bmiToArc(toBmi) - startAngle;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcR),
        startAngle, sweepAngle, false,
        Paint()
          ..color = cat.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = arcW - 3
          ..strokeCap = StrokeCap.butt,
      );
    }

    // 구간 경계선
    for (final cat in categories.skip(1)) {
      final angle = _bmiToRad(cat.min);
      final ox = cx + outerR * math.cos(angle);
      final oy = cy - outerR * math.sin(angle);
      final ix = cx + innerR * math.cos(angle);
      final iy = cy - innerR * math.sin(angle);
      canvas.drawLine(
        Offset(ix, iy), Offset(ox, oy),
        Paint()
          ..color = _kBgBottom.withValues(alpha: 0.7)
          ..strokeWidth = 2,
      );
    }

    // 바늘
    final nx = cx + outerR * 0.95 * math.cos(needleAngle);
    final ny = cy - outerR * 0.95 * math.sin(needleAngle);
    final bx = cx + innerR * 0.55 * math.cos(needleAngle);
    final by = cy - innerR * 0.55 * math.sin(needleAngle);
    canvas.drawLine(
      Offset(bx, by), Offset(nx, ny),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = _kBgBottom);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.needleAngle != needleAngle || old.categories != categories;
}
