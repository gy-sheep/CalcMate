import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/cm_gradient_border_card.dart';
import '../../../l10n/app_localizations.dart';
import '../discount_calculator_colors.dart';

// ──────────────────────────────────────────
// 추가 할인 섹션
// ──────────────────────────────────────────
class ExtraDiscountSection extends StatefulWidget {
  final bool show;
  final String rateText;
  final int? selectedChip;
  final bool isActive;
  final List<String> chips;
  final VoidCallback onToggle;
  final void Function(int) onChipTap;
  final VoidCallback onFieldTap;

  const ExtraDiscountSection({
    super.key,
    required this.show,
    required this.rateText,
    required this.selectedChip,
    required this.isActive,
    required this.chips,
    required this.onToggle,
    required this.onChipTap,
    required this.onFieldTap,
  });

  @override
  State<ExtraDiscountSection> createState() => _ExtraDiscountSectionState();
}

class _ExtraDiscountSectionState extends State<ExtraDiscountSection> {
  final _scrollCtrl = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final left = pos.pixels > 0;
    final right = pos.pixels < pos.maxScrollExtent;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onToggle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.show
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: kDiscountAccent,
                size: CmIcon.small,
              ),
              const SizedBox(width: 6),
              Text(
                widget.show
                    ? l10n.discount_label_removeExtra
                    : l10n.discount_label_addExtra,
                style: rowLabel.copyWith(color: kDiscountAccent),
              ),
            ],
          ),
        ),
        if (widget.show) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onFieldTap,
            child: _buildExtraField(),
          ),
        ],
      ],
    );
  }

  Widget _buildExtraField() {
    final l10n = AppLocalizations.of(context)!;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.discount_label_extraRate,
            style: CmInputCard.titleText.copyWith(
                color: kDiscountTextSecondary)),
        const SizedBox(height: CmInputCard.titleSpacing),
        Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.chips.length, (i) {
                  final active = widget.selectedChip == i;
                  return Padding(
                    padding: EdgeInsets.only(
                        right: i < widget.chips.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => widget.onChipTap(i),
                      child: AnimatedContainer(
                        duration: durationAnimQuick,
                        padding: CmTab.padding,
                        constraints: const BoxConstraints(minWidth: 56),
                        decoration: BoxDecoration(
                          color: active
                              ? kDiscountChipActiveBg
                              : kDiscountChipBg,
                          borderRadius:
                              BorderRadius.circular(CmTab.radius),
                          border: Border.all(
                            color: active
                                ? kDiscountChipActiveBg
                                : kDiscountFieldBorder,
                          ),
                        ),
                        child: Text(
                          widget.chips[i],
                          style: CmTab.text.copyWith(
                            color: active
                                ? kDiscountChipActiveText
                                : kDiscountChipText,
                            fontWeight:
                                active ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_canScrollLeft)
              Positioned(
                left: 0, top: 0, bottom: 0, width: 32,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          kDiscountFieldBg,
                          kDiscountFieldBg.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_canScrollRight)
              Positioned(
                right: 0, top: 0, bottom: 0, width: 32,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          kDiscountFieldBg,
                          kDiscountFieldBg.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.rateText.isEmpty ? '0' : widget.rateText,
              style: CmInputCard.inputText.copyWith(
                color: widget.rateText.isEmpty
                    ? kDiscountTextSecondary
                    : kDiscountTextPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '%',
              style: CmInputCard.unitText.copyWith(
                color: widget.isActive
                    ? kDiscountAccent
                    : kDiscountTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );

    if (widget.isActive) {
      return CmGradientBorderCard(
        borderColors: kDiscountBorderGradient,
        color: kDiscountFieldBg,
        child: Padding(
          padding: CmInputCard.padding,
          child: content,
        ),
      );
    }
    return Container(
      padding: CmInputCard.padding,
      decoration: BoxDecoration(
        color: kDiscountFieldBg,
        borderRadius: BorderRadius.circular(CmInputCard.radius),
        border: Border.all(color: kDiscountFieldBorder),
        boxShadow: const [
          BoxShadow(
            color: kDiscountCardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }
}
