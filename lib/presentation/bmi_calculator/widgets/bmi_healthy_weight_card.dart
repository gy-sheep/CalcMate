import 'package:flutter/material.dart';
import '../../../core/theme/app_design_tokens.dart';

const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFFB0BEC5);
const _kCardBg = Color(0xFF1E3248);
const _kGreen = Color(0xFF4CAF50);

class BmiHealthyWeightCard extends StatelessWidget {
  const BmiHealthyWeightCard({
    super.key,
    required this.minKg,
    required this.maxKg,
    required this.isInRange,
    required this.isMetric,
  });

  final double minKg;
  final double maxKg;
  final bool isInRange;
  final bool isMetric;

  String _fmt(double kg) => isMetric
      ? '${kg.toStringAsFixed(1)} kg'
      : '${(kg * 2.20462).toStringAsFixed(1)} lb';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CmInfoCard.padding,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: isInRange
              ? _kGreen.withValues(alpha: 0.4)
              : _kTextSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isInRange
                  ? Icons.check_circle_outline
                  : Icons.monitor_weight_outlined,
              color: isInRange ? _kGreen : _kTextSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('건강 체중 범위',
                    style: CmInfoCard.captionText.copyWith(color: _kTextSecondary)),
                const SizedBox(height: 2),
                Text('${_fmt(minKg)} – ${_fmt(maxKg)}',
                    style: CmInfoCard.bodyText.copyWith(color: _kTextPrimary)),
                if (isInRange) ...[
                  const SizedBox(height: 2),
                  Text('현재 체중이 건강 범위 안에 있습니다',
                      style: textStyleCaption
                          .copyWith(color: _kGreen)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
