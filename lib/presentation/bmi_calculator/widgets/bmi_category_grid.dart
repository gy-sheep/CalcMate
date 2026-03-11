import 'package:flutter/material.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/bmi_calculate_usecase.dart';

const _kTextSecondary = Color(0xFFB0BEC5);
const _kCardBg = Color(0xFF1E3248);

class BmiCategoryGrid extends StatelessWidget {
  const BmiCategoryGrid({
    super.key,
    required this.categories,
    required this.currentCategory,
  });

  final List<BmiCategoryDef> categories;
  final BmiCategoryDef currentCategory;

  @override
  Widget build(BuildContext context) {
    final use2Row = categories.length > 4;
    if (use2Row) {
      final row1 = categories.sublist(0, 3);
      final row2 = categories.sublist(3);
      return Column(
        children: [
          _buildRow(row1),
          const SizedBox(height: 8),
          _buildRow(row2),
        ],
      );
    }
    return _buildRow(categories);
  }

  Widget _buildRow(List<BmiCategoryDef> cats) {
    return Row(
      children: cats.map((cat) {
        final isActive = cat.label == currentCategory.label;
        return Expanded(
          child: AnimatedContainer(
            duration: durationAnimMedium,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding:
                const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? cat.color.withValues(alpha: 0.18)
                  : _kCardBg,
              borderRadius:
                  BorderRadius.circular(radiusInput),
              border: Border.all(
                color: isActive
                    ? cat.color.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  cat.label,
                  textAlign: TextAlign.center,
                  style: textStyleCaption.copyWith(
                    color: isActive ? cat.color : _kTextSecondary,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cat.rangeLabel,
                  textAlign: TextAlign.center,
                  style: CmInfoCard.captionText.copyWith(
                    color: isActive
                        ? cat.color.withValues(alpha: 0.8)
                        : _kTextSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
