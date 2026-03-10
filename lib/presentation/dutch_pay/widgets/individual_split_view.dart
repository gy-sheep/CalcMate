import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/utils/app_toast.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../../../domain/usecases/dutch_pay_individual_split_usecase.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'dutch_card.dart';
import 'participant_chip.dart';
import 'share_sheet.dart';

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
    final topOffset = (isTop && _compactIsSticky) ? _CompactBarDelegate._height : 0.0;
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
      builder: (_) => _MenuInputSheet(parentRef: ref),
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
                  child: _ParticipantsBar(
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
                  delegate: _CompactBarDelegate(
                    child: _CompactSummaryBar(s: s, result: result),
                  ),
                ),
              // 3. 메뉴 목록 + 결과
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.list(
                  children: [
                    _ItemsCard(
                      s: s,
                      vm: vm,
                      filterPerson: _filterPerson,
                      onAddTap: () => _showInputSheet(context),
                    ),
                    if (s.items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _ResultBarSection(s: s, result: result),
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

// ── Compact 바 슬리버 델리게이트 ─────────────────────────────

class _CompactBarDelegate extends SliverPersistentHeaderDelegate {
  const _CompactBarDelegate({required this.child});
  final Widget child;

  static const _height = 48.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_CompactBarDelegate old) => true;
}

// ── 광고 배너 플레이스홀더 ────────────────────────────────────

// ── 인원 컴팩트 바 ───────────────────────────────────────────

class _ParticipantsBar extends StatefulWidget {
  const _ParticipantsBar({
    required this.s,
    required this.vm,
    required this.filterPerson,
    required this.onFilterChanged,
  });
  final IndividualSplitState s;
  final DutchPayViewModel vm;
  final int? filterPerson;
  final ValueChanged<int?> onFilterChanged;

  @override
  State<_ParticipantsBar> createState() => _ParticipantsBarState();
}

class _ParticipantsBarState extends State<_ParticipantsBar>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  int _prevCount = 0;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  late AnimationController _shakeCtrl;

  IndividualSplitState get s => widget.s;
  DutchPayViewModel get vm => widget.vm;

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
    _prevCount = s.participants.length;
    _scrollCtrl.addListener(_onScroll);
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant _ParticipantsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (s.isParticipantEditMode != oldWidget.s.isParticipantEditMode) {
      if (s.isParticipantEditMode) {
        _shakeCtrl.repeat(reverse: true);
      } else {
        _shakeCtrl.stop();
        _shakeCtrl.reset();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut);
        }
      });
    } else if (s.participants.length > _prevCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
        if (s.participants.length >= 10 && mounted) {
          showAppToast(context, '최대 10명까지 추가할 수 있어요');
        }
      });
    } else if (s.participants.length < _prevCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
    _prevCount = s.participants.length;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: DutchCard(
        color: kDutchCardBg,
        child: Padding(
          padding: CmInputCard.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이틀 + 추가/편집 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('참여인원',
                      style: CmInputCard.titleText
                          .copyWith(color: kDutchTextSecondary)),
                  const Spacer(),
                  if (s.participants.length < 10)
                    GestureDetector(
                      onTap: () => vm.handleIntent(
                          const DutchPayIntent.participantAdded()),
                      child: Container(
                        padding: CmTab.padding,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: kDutchAccent.withValues(alpha: 0.4)),
                          borderRadius:
                              BorderRadius.circular(CmTab.radius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add,
                                size: CmTab.iconSize, color: kDutchAccent),
                            const SizedBox(width: 2),
                            Text('추가',
                                style:
                                    CmTab.text.copyWith(color: kDutchAccent)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => vm.handleIntent(
                        const DutchPayIntent.participantEditModeToggled()),
                    child: Container(
                      padding: CmTab.padding,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: kDutchAccent.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(CmTab.radius),
                      ),
                      child: Text(
                        s.isParticipantEditMode ? '완료' : '편집',
                        style: CmTab.text.copyWith(
                            color: kDutchAccent,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CmInputCard.titleSpacing),
              // 참여자 칩
              Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollCtrl,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: s.participants.asMap().entries.map((e) {
                        final i = e.key;
                        final isFiltered = widget.filterPerson == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: s.isParticipantEditMode
                              ? AnimatedBuilder(
                                  animation: _shakeCtrl,
                                  builder: (_, child) {
                                    final offset = math.sin(
                                            _shakeCtrl.value * math.pi * 2) *
                                        2.0;
                                    return Transform.translate(
                                      offset: Offset(offset, 0),
                                      child: child,
                                    );
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ParticipantChip(
                                        label: e.value.name,
                                        bg: kDutchChipBg[
                                            i % kDutchChipBg.length],
                                        fg: kDutchChipText[
                                            i % kDutchChipText.length],
                                        showDelete: false,
                                        onTap: () =>
                                            _confirmRemove(context, i, s),
                                      ),
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _confirmRemove(context, i, s),
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                size: 10,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    if (isFiltered) {
                                      widget.onFilterChanged(null);
                                    } else {
                                      _showRenameDialogAt(context, i);
                                    }
                                  },
                                  onLongPress: () {
                                    HapticFeedback.selectionClick();
                                    widget.onFilterChanged(
                                        widget.filterPerson == i ? null : i);
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isFiltered
                                          ? kDutchChipBg[
                                              i % kDutchChipBg.length]
                                          : kDutchChipBg[
                                                  i % kDutchChipBg.length]
                                              .withValues(alpha: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isFiltered
                                            ? kDutchChipText[
                                                i % kDutchChipText.length]
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: CmTab.iconSize,
                                          color: kDutchChipText[i % kDutchChipText.length]
                                              .withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          e.value.name,
                                          style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600)
                                              .copyWith(
                                            color: kDutchChipText[
                                                i % kDutchChipText.length],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_canScrollLeft)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 32,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                kDutchCardBg,
                                kDutchCardBg.withValues(alpha: 0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_canScrollRight)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 32,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                kDutchCardBg,
                                kDutchCardBg.withValues(alpha: 0)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // 힌트 칩 (편집 모드 아닐 때)
              if (!s.isParticipantEditMode)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.filterPerson != null
                      ? _HintChip(
                          icon: Icons.touch_app_outlined,
                          label:
                              '${s.participants[widget.filterPerson!].name} 강조 중  ·  탭하면 해제',
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _HintChip(
                              icon: Icons.touch_app_outlined,
                              label: '탭 → 이름 변경',
                            ),
                            SizedBox(width: 20),
                            _HintChip(
                              icon: Icons.touch_app,
                              label: '길게 누르기 → 항목 강조',
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialogAt(BuildContext context, int idx) {
    final participants = s.participants;
    if (idx >= participants.length) return;

    final defaultName = participants[idx].name;
    final ctrl = TextEditingController();
    final isLast = idx == participants.length - 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$defaultName 이름 변경'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: defaultName,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          if (!isLast)
            TextButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) {
                  vm.handleIntent(
                      DutchPayIntent.participantRenamed(idx, name));
                }
                Navigator.pop(ctx);
                _showRenameDialogAt(context, idx + 1);
              },
              child: const Text('다음'),
            ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                vm.handleIntent(DutchPayIntent.participantRenamed(idx, name));
              }
              Navigator.pop(ctx);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, int idx, IndividualSplitState s) {
    if (s.participants.length <= 1) {
      showAppToast(context, '최소 1명은 있어야 해요');
      return;
    }
    final hasItems = s.items.any((item) => item.assignees.contains(idx));
    if (hasItems) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('참여자 삭제'),
          content: Text('${s.participants[idx].name}의 메뉴가 함께 삭제됩니다.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소')),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                vm.handleIntent(DutchPayIntent.participantRemoved(idx));
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      vm.handleIntent(DutchPayIntent.participantRemoved(idx));
    }
  }
}

// ── 힌트 칩 ─────────────────────────────────────────────────

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: kDutchTextTertiary.withValues(alpha: 0.7)),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: kDutchTextTertiary.withValues(alpha: 0.7))),
      ],
    );
  }
}

// ── 컴팩트 요약 바 ───────────────────────────────────────────

class _CompactSummaryBar extends StatefulWidget {
  const _CompactSummaryBar({required this.s, required this.result});
  final IndividualSplitState s;
  final IndividualSplitResult result;

  @override
  State<_CompactSummaryBar> createState() => _CompactSummaryBarState();
}

class _CompactSummaryBarState extends State<_CompactSummaryBar> {
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

  String _compact(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(n % 10000 == 0 ? 0 : 1)}만';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}천';
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
            '합계 ${_fmt(result.totalAmount)}원',
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
                              '${e.value.name} ${_compact(amt)}',
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

// ── 항목 카드 (목록 + 추가 버튼 통합) ──────────────────────────

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({
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
                  duration: const Duration(milliseconds: 200),
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

// ── 결과 바 차트 섹션 ────────────────────────────────────────

class _ResultBarSection extends StatelessWidget {
  const _ResultBarSection({required this.s, required this.result});
  final IndividualSplitState s;
  final IndividualSplitResult result;

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
                Text('결과',
                    style: CmInputCard.titleText
                        .copyWith(color: kDutchTextSecondary)),
                Text('합계 ${_fmt(result.totalAmount)}원',
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
                                duration: const Duration(milliseconds: 400),
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
                        '${_fmt(amt)}원',
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
            _ShareResultBtn(s: s, result: result),
          ],
        ),
      ),
    );
  }
}

// ── 공유 버튼 ────────────────────────────────────────────────

class _ShareResultBtn extends StatelessWidget {
  const _ShareResultBtn({required this.s, required this.result});
  final IndividualSplitState s;
  final IndividualSplitResult result;

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
            Text('결과 공유',
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
        );
      },
    );
  }
}

// ── 메뉴 입력 바텀시트 ──────────────────────────────────────

class _MenuInputSheet extends ConsumerStatefulWidget {
  const _MenuInputSheet({required this.parentRef});
  final WidgetRef parentRef;

  @override
  ConsumerState<_MenuInputSheet> createState() => _MenuInputSheetState();
}

class _MenuInputSheetState extends ConsumerState<_MenuInputSheet> {
  final _nameCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _chipScroll = ScrollController();
  bool _chipLeftFade = false;
  bool _chipRightFade = false;

  DutchPayViewModel get _vm =>
      ref.read(dutchPayViewModelProvider.notifier);

  String _fmtAmt(String raw) {
    final n = int.tryParse(raw);
    if (n == null || raw.isEmpty) return raw;
    final str = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  void initState() {
    super.initState();
    final s =
        widget.parentRef.read(dutchPayViewModelProvider).individualSplit;
    _nameCtrl.text = s.nameInput;
    _amtCtrl.text = s.amtInput;
    _chipScroll.addListener(_onChipScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
      _onChipScroll();
    });
  }

  void _onChipScroll() {
    if (!_chipScroll.hasClients) return;
    final pos = _chipScroll.position;
    final left = pos.pixels > 4;
    final right = pos.pixels < pos.maxScrollExtent - 4;
    if (_chipLeftFade != left || _chipRightFade != right) {
      setState(() {
        _chipLeftFade = left;
        _chipRightFade = right;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amtCtrl.dispose();
    _nameFocus.dispose();
    _chipScroll.removeListener(_onChipScroll);
    _chipScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(dutchPayViewModelProvider).individualSplit;
    final canSubmit = _vm.canSubmitItem;
    final isEditing = s.editingIndex != null;

    // 컨트롤러 동기화
    if (_nameCtrl.text != s.nameInput) {
      _nameCtrl.text = s.nameInput;
      _nameCtrl.selection =
          TextSelection.collapsed(offset: s.nameInput.length);
    }
    final formattedAmt = _fmtAmt(s.amtInput);
    if (_amtCtrl.text != formattedAmt) {
      _amtCtrl.text = formattedAmt;
      _amtCtrl.selection =
          TextSelection.collapsed(offset: formattedAmt.length);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: kDutchAccent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(isEditing ? '메뉴 수정' : '메뉴 추가',
                style:
                    CmSheet.titleText.copyWith(color: kDutchTextPrimary)),
            const SizedBox(height: 16),
            // 입력 필드
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kDutchBg2.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(radiusInput),
                      border: Border.all(
                          color: kDutchAccent.withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      style: inputFieldInnerLabel
                          .copyWith(color: kDutchTextPrimary),
                      decoration: InputDecoration(
                        hintText: '메뉴명',
                        hintStyle:
                            TextStyle(color: kDutchTextTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => _vm.handleIntent(
                          DutchPayIntent.nameInputChanged(v)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kDutchBg2.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(radiusInput),
                      border: Border.all(
                          color: kDutchAccent.withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: _amtCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: inputFieldInnerLabel
                          .copyWith(color: kDutchTextPrimary),
                      decoration: InputDecoration(
                        hintText: '금액',
                        hintStyle:
                            TextStyle(color: kDutchTextTertiary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) => _vm.handleIntent(
                          DutchPayIntent.amtInputChanged(v.replaceAll(',', ''))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 담당자 선택 칩 (가로 스크롤 + 동적 좌우 페이드)
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [
                  _chipLeftFade ? Colors.white : Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  _chipRightFade ? Colors.white : Colors.transparent,
                ],
                stops: const [0.0, 0.08, 0.92, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstOut,
              child: SingleChildScrollView(
                controller: _chipScroll,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: s.participants.asMap().entries.map((e) {
                    final selected =
                        s.selectedParticipants.contains(e.key);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ParticipantChip(
                        label: e.value.name,
                        bg: kDutchChipBg[e.key % kDutchChipBg.length],
                        fg: kDutchChipText[e.key % kDutchChipText.length],
                        isSelected: selected,
                        showSelectIndicator: true,
                        onTap: () => _vm.handleIntent(
                            DutchPayIntent.participantToggled(e.key)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 액션 버튼
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _vm.handleIntent(
                            const DutchPayIntent.itemDeleted());
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: kDutchInputBg,
                          borderRadius:
                              BorderRadius.circular(radiusCard),
                          border: Border.all(
                              color: kDutchAccent.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text('삭제',
                              style: textStyle16.copyWith(
                                  color: kDutchAccent)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _SubmitButton(
                      label: '수정',
                      enabled: canSubmit,
                      onTap: () {
                        _vm.handleIntent(
                            const DutchPayIntent.itemSubmitted());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              )
            else
              _SubmitButton(
                label: '추가',
                enabled: canSubmit,
                onTap: () {
                  _vm.handleIntent(const DutchPayIntent.itemSubmitted());
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(
      {required this.label, required this.enabled, required this.onTap});
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFF48FB1), kDutchAccent])
              : null,
          color: enabled ? null : kDutchDivider,
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        child: Center(
          child: Text(label,
              style: textStyle16.copyWith(
                  color: enabled ? Colors.white : kDutchTextTertiary)),
        ),
      ),
    );
  }
}
