import 'package:flutter/material.dart';
import '../../../core/theme/app_design_tokens.dart';

const _kTextSecondary = Color(0xFFB0BEC5);
const _kSliderTrack = Color(0xFF2A4060);
const _kCardBg = Color(0xFF1E3248);

class BmiInputSlider extends StatelessWidget {
  const BmiInputSlider({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accentColor,
    required this.onChanged,
    required this.onValueTap,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  final VoidCallback onValueTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTokens.paddingCard,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: AppTokens.textStyleLabelLarge.copyWith(
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
              GestureDetector(
                onTap: onValueTap,
                child: Container(
                  padding: AppTokens.paddingChip,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusChip),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(valueLabel,
                          style: AppTokens.textStyleValue
                              .copyWith(color: accentColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_outlined,
                          size: AppTokens.sizeIconXSmall,
                          color: accentColor.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: _kSliderTrack,
              thumbColor: Colors.white,
              overlayColor: accentColor.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: AppTokens.radiusSliderThumb),
              trackHeight: AppTokens.heightSliderTrack,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.round()}',
                  style: AppTokens.textStyleCaption
                      .copyWith(color: _kTextSecondary)),
              Text('${max.round()}',
                  style: AppTokens.textStyleCaption
                      .copyWith(color: _kTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
