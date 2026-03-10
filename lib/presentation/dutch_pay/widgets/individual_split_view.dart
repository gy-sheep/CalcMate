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

class _IndividualSplitViewState extends ConsumerState<IndividualSplitView>
    with SingleTickerProviderStateMixin {
  int? _filterPerson;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _showInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
        // 1. 인원 컴팩트 바
        _ParticipantsBar(s: s, vm: vm),
        // 2. 컴팩트 요약 바 (항목 있을 때만)
        if (s.items.isNotEmpty)
          _CompactSummaryBar(s: s, result: result, show: s.items.isNotEmpty),
        // 3. 스크롤 영역
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
        // 4. 광고 배너 플레이스홀더
        _AdBannerPlaceholder(),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

// ── 광고 배너 플레이스홀더 ────────────────────────────────────

class _AdBannerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: kDutchCardBg,
      child: Center(
        child: Text(
          'Ad',
          style: textStyleCaption.copyWith(color: kDutchTextTertiary),
        ),
      ),
    );
  }
}

// ── 인원 컴팩트 바 ───────────────────────────────────────────

class _ParticipantsBar extends StatefulWidget {
  const _ParticipantsBar({required this.s, required this.vm});
  final IndividualSplitState s;
  final DutchPayViewModel vm;

  @override
  State<_ParticipantsBar> createState() => _ParticipantsBarState();
}

class _ParticipantsBarState extends State<_ParticipantsBar>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  int _prevCount = 0;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  int? _filterPerson;
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
                        final isFiltered = _filterPerson == i;
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
                                        showDelete: true,
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
                                  onTap: () =>
                                      _showRenameDialogAt(context, i),
                                  onLongPress: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _filterPerson =
                                          _filterPerson == i ? null : i;
                                    });
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
                                    child: Text(
                                      e.value.name,
                                      style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)
                                          .copyWith(
                                        color: kDutchChipText[
                                            i % kDutchChipText.length],
                                      ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HintChip(
                        icon: Icons.touch_app_outlined,
                        label: _filterPerson != null
                            ? '${s.participants[_filterPerson!].name} 강조 중  ·  탭하면 해제'
                            : '탭 → 이름 변경',
                      ),
                      const SizedBox(width: 6),
                      const _HintChip(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kDutchAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDutchAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kDutchTextTertiary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 11)
                  .copyWith(color: kDutchTextTertiary)),
        ],
      ),
    );
  }
}

// ── 컴팩트 요약 바 ───────────────────────────────────────────

class _CompactSummaryBar extends StatelessWidget {
  const _CompactSummaryBar(
      {required this.s, required this.result, required this.show});
  final IndividualSplitState s;
  final IndividualSplitResult result;
  final bool show;

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
    if (!show) return const SizedBox.shrink();
    return Container(
      height: 44,
      color: kDutchCardBg.withValues(alpha: 0.8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: s.participants.asMap().entries.map((e) {
            final i = e.key;
            final amt = result.personAmounts.length > i
                ? result.personAmounts[i]
                : 0;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: kDutchChipBg[i % kDutchChipBg.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.value.name,
                    style: textStyleCaption.copyWith(
                        color: kDutchTextSecondary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmt(amt)}원',
                    style: textStyleCaption.copyWith(
                        color: kDutchTextPrimary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
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
                  const SizedBox(height: 12),
                  Text(
                    '아직 메뉴가 없어요',
                    style: textEmptyGuide.copyWith(color: kDutchTextTertiary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '아래 버튼으로 메뉴를 추가해 보세요',
                    style: textStyleCaption
                        .copyWith(color: kDutchTextTertiary),
                  ),
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
                      width: 36,
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
                      width: 72,
                      child: Text(
                        '${_fmt(amt)}원',
                        textAlign: TextAlign.right,
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

  DutchPayViewModel get _vm =>
      ref.read(dutchPayViewModelProvider.notifier);

  @override
  void initState() {
    super.initState();
    final s =
        widget.parentRef.read(dutchPayViewModelProvider).individualSplit;
    _nameCtrl.text = s.nameInput;
    _amtCtrl.text = s.amtInput;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amtCtrl.dispose();
    _nameFocus.dispose();
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
    if (_amtCtrl.text != s.amtInput) {
      _amtCtrl.text = s.amtInput;
      _amtCtrl.selection =
          TextSelection.collapsed(offset: s.amtInput.length);
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
                    color: kDutchDivider,
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
                      color: kDutchInputBg,
                      borderRadius: BorderRadius.circular(radiusInput),
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
                      color: kDutchInputBg,
                      borderRadius: BorderRadius.circular(radiusInput),
                    ),
                    child: TextField(
                      controller: _amtCtrl,
                      keyboardType: TextInputType.number,
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
                          DutchPayIntent.amtInputChanged(v)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 담당자 선택 칩
            SingleChildScrollView(
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
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(radiusCard),
                          border:
                              Border.all(color: Colors.red.shade200),
                        ),
                        child: Center(
                          child: Text('삭제',
                              style: textStyle16.copyWith(
                                  color: Colors.red.shade400)),
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
