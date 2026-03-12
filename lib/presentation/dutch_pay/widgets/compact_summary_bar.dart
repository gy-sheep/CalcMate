import 'package:flutter/material.dart';

import '../../../core/l10n/currency_formatter.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../../../domain/usecases/dutch_pay_individual_split_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../dutch_pay_colors.dart';

// ── Compact 바 슬리버 델리게이트 ─────────────────────────────

class CompactBarDelegate extends SliverPersistentHeaderDelegate {
  const CompactBarDelegate({required this.child});
  final Widget child;

  static const height = 48.0;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CompactBarDelegate old) => true;
}

// ── 컴팩트 요약 바 ───────────────────────────────────────────

class CompactSummaryBar extends StatefulWidget {
  const CompactSummaryBar({super.key, required this.s, required this.result});
  final IndividualSplitState s;
  final IndividualSplitResult result;

  @override
  State<CompactSummaryBar> createState() => _CompactSummaryBarState();
}

class _CompactSummaryBarState extends State<CompactSummaryBar> {
  final _hScroll = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _hScroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _hScroll.removeListener(_onScroll);
    _hScroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hScroll.hasClients) return;
    final pos = _hScroll.position;
    final left = pos.pixels > 4;
    final right = pos.pixels < pos.maxScrollExtent - 4;
    if (_showLeftFade != left || _showRightFade != right) {
      setState(() {
        _showLeftFade = left;
        _showRightFade = right;
      });
    }
  }

  String _compact(int n, Locale locale) {
    if (locale.languageCode == 'ko') {
      if (n >= 10000) return '${(n / 10000).toStringAsFixed(n % 10000 == 0 ? 0 : 1)}만';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}천';
      return n.toString();
    }
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return n.toString();
  }

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
    final s = widget.s;
    final result = widget.result;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kDutchBg1,
        border: Border(
          bottom: BorderSide(color: kDutchAccent.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${l10n.dutchPay_label_total} ${CurrencyFormatter.formatKrw(_fmt(result.totalAmount), locale)}',
            style: textStyleCaption.copyWith(
              color: kDutchAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 1,
            height: 12,
            color: kDutchAccent.withValues(alpha: 0.25),
          ),
          // 인원별 칩 (가로 스크롤 + 동적 좌우 페이드)
          Expanded(
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  _showLeftFade ? kDutchBg1 : Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  _showRightFade ? kDutchBg1 : Colors.transparent,
                ],
                stops: const [0.0, 0.08, 0.92, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstOut,
              child: SingleChildScrollView(
                controller: _hScroll,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: s.participants.asMap().entries.map((e) {
                    final i = e.key;
                    final amt = result.personAmounts.length > i
                        ? result.personAmounts[i]
                        : 0;
                    final bg = kDutchChipBg[i % kDutchChipBg.length];
                    final fg = kDutchChipText[i % kDutchChipText.length];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: bg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person,
                                size: 10, color: fg.withValues(alpha: 0.7)),
                            const SizedBox(width: 2),
                            Text(
                              '${e.value.name} ${_compact(amt, locale)}',
                              style: textStyleCaption.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
