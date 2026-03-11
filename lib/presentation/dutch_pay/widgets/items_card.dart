import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'dutch_card.dart';

// ── 항목 카드 (목록 + 추가 버튼 통합) ──────────────────────────

class ItemsCard extends StatelessWidget {
  const ItemsCard({
    super.key,
    required this.s,
    required this.vm,
    required this.filterPerson,
    required this.onAddTap,
  });
  final IndividualSplitState s;
  final DutchPayViewModel vm;
  final int? filterPerson;
  final VoidCallback onAddTap;

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
    return DutchCard(
      color: kDutchCardBg,
      clip: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 40, color: kDutchTextTertiary.withValues(alpha: 0.4)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: s.items.length,
              separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: kDutchDivider.withValues(alpha: 0.5),
                  indent: 16,
                  endIndent: 16),
              itemBuilder: (_, i) {
                final item = s.items[i];
                final editing = s.editingIndex == i;
                final dimmed = filterPerson != null &&
                    !item.assignees.contains(filterPerson);
                return AnimatedOpacity(
                  duration: durationAnimDefault,
                  opacity: dimmed ? 0.3 : 1.0,
                  child: InkWell(
                    onTap: () {
                      vm.handleIntent(DutchPayIntent.itemTapped(i));
                      onAddTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      color: editing
                          ? kDutchAccent.withValues(alpha: 0.05)
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (editing)
                            Container(
                              width: 3,
                              height: 36,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: kDutchAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.edit_outlined,
                                size: CmTab.iconSize,
                                color: kDutchTextTertiary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item.name,
                                    style: rowLabel.copyWith(
                                        color: kDutchTextPrimary,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  children: item.assignees
                                      .map((idx) => Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: kDutchChipBg[idx %
                                                  kDutchChipBg.length],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.person,
                                                    size: 10,
                                                    color: kDutchChipText[idx %
                                                        kDutchChipText
                                                            .length]),
                                                Text(
                                                  s.participants[idx].name,
                                                  style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600)
                                                      .copyWith(
                                                    color: kDutchChipText[idx %
                                                        kDutchChipText.length],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          Text('${_fmt(item.amount)}원',
                              style: textStyle16.copyWith(
                                  color: editing
                                      ? kDutchAccent
                                      : kDutchTextPrimary)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          // 추가 버튼
          const Divider(height: 1, color: kDutchDivider),
          InkWell(
            onTap: onAddTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: kDutchAccent, size: CmIcon.small),
                  const SizedBox(width: 8),
                  Text('메뉴 추가',
                      style: textStyle16.copyWith(color: kDutchAccent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
