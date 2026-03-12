import 'package:flutter/material.dart';
import '../../../core/l10n/data_strings.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/usecases/bmi_calculate_usecase.dart';
import '../../../l10n/app_localizations.dart';

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
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final use2Row = categories.length > 4;
    if (use2Row) {
      final row1 = categories.sublist(0, 3);
      final row2 = categories.sublist(3);
      return Column(
        children: [
          _buildRow(row1, locale, l10n),
          const SizedBox(height: 8),
          _buildRow(row2, locale, l10n),
        ],
      );
    }
    return _buildRow(categories, locale, l10n);
  }

  Widget _buildRow(List<BmiCategoryDef> cats, Locale locale, AppLocalizations l10n) {
    return Row(
      children: cats.map((cat) {
        final isActive = cat.code == currentCategory.code;
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
                  DataStrings.bmiCategory(cat.code.name, locale),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleCaption.copyWith(
                    color: isActive ? cat.color : _kTextSecondary,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _bmiRangeLabel(cat, l10n),
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

String _bmiRangeLabel(BmiCategoryDef cat, AppLocalizations l10n) {
  if (cat.max == double.infinity) {
    return l10n.bmi_range_above(cat.min.toStringAsFixed(1));
  }
  return '${cat.min.toStringAsFixed(1)} – ${(cat.max - 0.1).toStringAsFixed(1)}';
}
