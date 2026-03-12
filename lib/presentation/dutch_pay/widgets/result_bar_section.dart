import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/currency_formatter.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/currency_unit.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../../../domain/usecases/dutch_pay_individual_split_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../dutch_pay_colors.dart';
import 'dutch_card.dart';
import 'share_sheet.dart';

// ── 결과 바 차트 섹션 ────────────────────────────────────────

class ResultBarSection extends StatelessWidget {
  const ResultBarSection({super.key, required this.s, required this.result, required this.currencyUnit});
  final IndividualSplitState s;
  final IndividualSplitResult result;
  final CurrencyUnit currencyUnit;

  String _fmt(int n) {
    if (n == 0) return '0';
    final str = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final maxAmt = result.personAmounts.isEmpty
        ? 1
        : result.personAmounts.reduce(math.max);

    return DutchCard(
      color: kDutchCardBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dutchPay_label_result,
                    style: CmInputCard.titleText
                        .copyWith(color: kDutchTextSecondary)),
                Text('${l10n.dutchPay_label_total} ${CurrencyFormatter.format(_fmt(result.totalAmount), currencyUnit, locale)}',
                    style: textStyleCaption.copyWith(
                        color: kDutchTextTertiary)),
              ],
            ),
            const SizedBox(height: 14),
            ...s.participants.asMap().entries.map((e) {
              final i = e.key;
              final amt = result.personAmounts.length > i
                  ? result.personAmounts[i]
                  : 0;
              final ratio = maxAmt > 0 ? amt / maxAmt : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        e.value.name,
                        overflow: TextOverflow.ellipsis,
                        style: textStyleCaption.copyWith(
                            color: kDutchTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 22,
                                decoration: BoxDecoration(
                                  color: kDutchDivider.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              AnimatedContainer(
                                duration: durationPageTransition,
                                curve: Curves.easeOut,
                                height: 22,
                                width: constraints.maxWidth * ratio,
                                decoration: BoxDecoration(
                                  color: kDutchChipBg[i % kDutchChipBg.length],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 96,
                      child: Text(
                        CurrencyFormatter.format(_fmt(amt), currencyUnit, locale),
                        textAlign: TextAlign.right,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: textStyleCaption.copyWith(
                            color: kDutchTextPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            ShareResultBtn(s: s, result: result, currencyUnit: currencyUnit),
          ],
        ),
      ),
    );
  }
}

// ── 공유 버튼 ────────────────────────────────────────────────

class ShareResultBtn extends StatelessWidget {
  const ShareResultBtn({super.key, required this.s, required this.result, required this.currencyUnit});
  final IndividualSplitState s;
  final IndividualSplitResult result;
  final CurrencyUnit currencyUnit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _share(context),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFF48FB1), kDutchAccent]),
          borderRadius: BorderRadius.circular(radiusCard),
          boxShadow: [
            BoxShadow(
              color: kDutchAccent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, color: Colors.white, size: CmIcon.small),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).dutchPay_button_shareResult,
                style: textStyle16.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        final personMenus = List.generate(
          s.participants.length,
          (i) => s.items
              .where((item) => item.assignees.contains(i))
              .map((item) => item.name)
              .toList(),
        );
        return ShareSheet(
          shareData: IndividualShareData(
            totalAmount: result.totalAmount,
            participants: s.participants.map((p) => p.name).toList(),
            personAmounts: result.personAmounts,
            personMenus: personMenus,
          ),
          currencyUnit: currencyUnit,
        );
      },
    );
  }
}
