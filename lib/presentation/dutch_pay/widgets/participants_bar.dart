import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/utils/app_toast.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'dutch_card.dart';
import 'participant_chip.dart';

// ── 인원 컴팩트 바 ───────────────────────────────────────────

class ParticipantsBar extends StatefulWidget {
  const ParticipantsBar({
    super.key,
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
  State<ParticipantsBar> createState() => _ParticipantsBarState();
}

class _ParticipantsBarState extends State<ParticipantsBar>
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
      duration: durationAnimInstant,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant ParticipantsBar oldWidget) {
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
              duration: durationAnimMedium,
              curve: Curves.easeOut);
        }
      });
    } else if (s.participants.length > _prevCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: durationAnimMedium,
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
                                        durationAnimFast,
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
                      ? HintChip(
                          icon: Icons.touch_app_outlined,
                          label:
                              '${s.participants[widget.filterPerson!].name} 강조 중  ·  탭하면 해제',
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HintChip(
                              icon: Icons.touch_app_outlined,
                              label: '탭 → 이름 변경',
                            ),
                            SizedBox(width: 20),
                            HintChip(
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

class HintChip extends StatelessWidget {
  const HintChip({super.key, required this.icon, required this.label});
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
