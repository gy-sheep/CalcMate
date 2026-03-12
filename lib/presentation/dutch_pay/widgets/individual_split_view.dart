import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../presentation/settings/settings_viewmodel.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'compact_summary_bar.dart';
import 'items_card.dart';
import 'menu_input_sheet.dart';
import 'participants_bar.dart';
import 'result_bar_section.dart';

class IndividualSplitView extends ConsumerStatefulWidget {
  const IndividualSplitView({super.key});

  @override
  ConsumerState<IndividualSplitView> createState() =>
      _IndividualSplitViewState();
}

class _IndividualSplitViewState extends ConsumerState<IndividualSplitView> {
  int? _filterPerson;
  final _scrollCtrl = ScrollController();
  final _participantsBarKey = GlobalKey();
  bool _showTopFade = false;
  bool _showBottomFade = false;
  bool _compactIsSticky = false;
  double _participantsBarHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() => _checkFade();

  void _checkFade() {
    if (!_scrollCtrl.hasClients) return;

    // 참여인원 바 높이 측정 (최초 1회)
    if (_participantsBarHeight == 0) {
      final box = _participantsBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _participantsBarHeight = box.size.height;
      }
    }

    final pos = _scrollCtrl.position;
    final canScroll = pos.maxScrollExtent > 0;
    final atTop = pos.pixels <= 8;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final newTop = canScroll && !atTop;
    final newBottom = canScroll && !atBottom;
    final newSticky = _participantsBarHeight > 0 &&
        pos.pixels >= _participantsBarHeight;

    if (_showTopFade != newTop ||
        _showBottomFade != newBottom ||
        _compactIsSticky != newSticky) {
      setState(() {
        _showTopFade = newTop;
        _showBottomFade = newBottom;
        _compactIsSticky = newSticky;
      });
    }
  }

  Widget _buildFade({required bool isTop}) {
    final topOffset = (isTop && _compactIsSticky) ? CompactBarDelegate.height : 0.0;
    return Positioned(
      left: 0,
      right: 0,
      top: isTop ? topOffset : null,
      bottom: isTop ? null : 0,
      height: 48,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isTop ? Alignment.bottomCenter : Alignment.topCenter,
              end: isTop ? Alignment.topCenter : Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0],
              colors: [
                kDutchBg3.withValues(alpha: 0),
                kDutchBg3.withValues(alpha: 0.7),
                kDutchBg3,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kDutchBg1,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(CmSheet.radius)),
      ),
      builder: (_) => MenuInputSheet(parentRef: ref),
    ).then((_) {
      ref
          .read(dutchPayViewModelProvider.notifier)
          .handleIntent(const DutchPayIntent.inputCleared());
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(dutchPayViewModelProvider).individualSplit;
    final vm = ref.read(dutchPayViewModelProvider.notifier);
    final result = vm.individualSplitResult;
    final currencyUnit = ref.watch(displayCurrencyProvider);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // 1. 참여인원 바 (스크롤됨)
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _participantsBarKey,
                  child: ParticipantsBar(
                    s: s,
                    vm: vm,
                    filterPerson: _filterPerson,
                    onFilterChanged: (i) => setState(() => _filterPerson = i),
                  ),
                ),
              ),
              // 2. compact 요약 바 (항목 있을 때 sticky)
              if (s.items.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CompactBarDelegate(
                    child: CompactSummaryBar(s: s, result: result, currencyUnit: currencyUnit),
                  ),
                ),
              // 3. 메뉴 목록 + 결과
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.list(
                  children: [
                    ItemsCard(
                      s: s,
                      vm: vm,
                      filterPerson: _filterPerson,
                      onAddTap: () => _showInputSheet(context),
                      currencyUnit: currencyUnit,
                    ),
                    if (s.items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ResultBarSection(s: s, result: result, currencyUnit: currencyUnit),
                    ],
                  ],
                ),
              ),
            ],
          ),
              if (_showTopFade) _buildFade(isTop: true),
              if (_showBottomFade) _buildFade(isTop: false),
            ],
          ),
        ),
      ],
    );
  }
}
