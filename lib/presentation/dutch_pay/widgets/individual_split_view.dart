import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/utils/app_toast.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../../../domain/usecases/dutch_pay_individual_split_usecase.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'participant_chip.dart';
import 'share_sheet.dart';

class IndividualSplitView extends ConsumerWidget {
  const IndividualSplitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dutchPayViewModelProvider).individualSplit;
    final vm = ref.read(dutchPayViewModelProvider.notifier);
    final result = vm.individualSplitResult;

    return Column(
      children: [
        // 1. 인원 컴팩트 바
        _ParticipantsBar(s: s, vm: vm),
        // 2. 항목 목록 (Expanded — 대부분 공간)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: kDutchCardBg,
                borderRadius: BorderRadius.circular(radiusCard),
                border: Border.all(color: kDutchDivider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radiusCard),
                child: _ItemList(
                  s: s,
                  vm: vm,
                  onItemTapped: () => _showInputSheet(context, ref),
                ),
              ),
            ),
          ),
        ),
        // 3. 메뉴 추가 버튼 — 항목 목록 바로 아래
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _AddMenuButton(
            isEditing: s.editingIndex != null,
            onTap: () => _showInputSheet(context, ref),
          ),
        ),
        // 4. 결과 영역 — 하단 고정
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: kDutchCardBg,
              borderRadius: BorderRadius.circular(radiusCard),
              border: Border.all(color: kDutchDivider),
            ),
            child: _ResultSection(s: s, result: result, vm: vm),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  void _showInputSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(CmSheet.radius)),
      ),
      builder: (_) => _MenuInputSheet(parentRef: ref),
    ).then((_) {
      ref
          .read(dutchPayViewModelProvider.notifier)
          .handleIntent(const DutchPayIntent.inputCleared());
    });
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

class _ParticipantsBarState extends State<_ParticipantsBar> {
  final _scrollCtrl = ScrollController();
  int _prevCount = 0;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant _ParticipantsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (s.isParticipantEditMode != oldWidget.s.isParticipantEditMode) {
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
    }
    _prevCount = s.participants.length;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: kDutchCardBg,
          borderRadius: BorderRadius.circular(radiusCard),
          border: Border.all(color: kDutchDivider),
        ),
        padding: CmInputCard.padding,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타이틀 + 추가/편집 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('참여인원',
                  style: CmInputCard.titleText.copyWith(color: kDutchTextSecondary)),
              const Spacer(),
              if (s.participants.length < 10)
                GestureDetector(
                  onTap: () =>
                      vm.handleIntent(const DutchPayIntent.participantAdded()),
                  child: Container(
                    padding: CmTab.padding,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: kDutchAccent.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(CmTab.radius),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add,
                          size: CmTab.iconSize, color: kDutchAccent),
                      const SizedBox(width: 2),
                      Text('추가',
                          style: CmTab.text.copyWith(color: kDutchAccent)),
                    ]),
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
                        color: kDutchAccent, fontWeight: FontWeight.w500),
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
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ParticipantChip(
                        label: e.value.name,
                        bg: kDutchChipBg[e.key % kDutchChipBg.length],
                        fg: kDutchChipText[e.key % kDutchChipText.length],
                        showDelete: s.isParticipantEditMode,
                        onTap: s.isParticipantEditMode
                            ? () => _confirmRemove(context, e.key, s)
                            : () => _showRenameDialogAt(context, e.key),
                      ),
                    );
                  }).toList(),
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
                          colors: [kDutchCardBg, kDutchCardBg.withValues(alpha: 0)],
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
                          colors: [kDutchCardBg, kDutchCardBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
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

// ── 메뉴 추가 버튼 ──────────────────────────────────────────

class _AddMenuButton extends StatelessWidget {
  const _AddMenuButton({required this.isEditing, required this.onTap});
  final bool isEditing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: kDutchAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(radiusCard),
          border: Border.all(color: kDutchAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: kDutchAccent, size: CmIcon.small),
            const SizedBox(width: 8),
            Text('메뉴 추가',
                style: textStyle16.copyWith(
                    color: kDutchAccent)),
          ],
        ),
      ),
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
    final s = widget.parentRef.read(dutchPayViewModelProvider).individualSplit;
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
                style: CmSheet.titleText.copyWith(
                    color: kDutchTextPrimary)),
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
                      borderRadius:
                          BorderRadius.circular(radiusInput),
                    ),
                    child: TextField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      style: inputFieldInnerLabel.copyWith(color: kDutchTextPrimary),
                      decoration: InputDecoration(
                        hintText: '메뉴명',
                        hintStyle: TextStyle(color: kDutchTextTertiary),
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
                      borderRadius:
                          BorderRadius.circular(radiusInput),
                    ),
                    child: TextField(
                      controller: _amtCtrl,
                      keyboardType: TextInputType.number,
                      style: inputFieldInnerLabel.copyWith(color: kDutchTextPrimary),
                      decoration: InputDecoration(
                        hintText: '금액',
                        hintStyle: TextStyle(color: kDutchTextTertiary),
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
                  final selected = s.selectedParticipants.contains(e.key);
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
                        _vm.handleIntent(const DutchPayIntent.itemDeleted());
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(radiusCard),
                          border: Border.all(color: Colors.red.shade200),
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
                        _vm.handleIntent(const DutchPayIntent.itemSubmitted());
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

// ── 항목 목록 ────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  const _ItemList({required this.s, required this.vm, this.onItemTapped});
  final IndividualSplitState s;
  final DutchPayViewModel vm;
  final VoidCallback? onItemTapped;

  @override
  Widget build(BuildContext context) {
    if (s.items.isEmpty) {
      return Center(
        child: Text('추가한 메뉴가 표시돼요',
            style: textEmptyGuide.copyWith(color: kDutchTextTertiary)),
      );
    }
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: s.items.length,
          separatorBuilder: (_, _) => Divider(
              height: 1,
              color: kDutchDivider.withValues(alpha: 0.5),
              indent: 16,
              endIndent: 16),
          itemBuilder: (_, i) {
            final item = s.items[i];
            final editing = s.editingIndex == i;
            return InkWell(
              onTap: () {
                vm.handleIntent(DutchPayIntent.itemTapped(i));
                onItemTapped?.call();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: kDutchTextTertiary.withValues(alpha: 0.6),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kDutchChipBg[
                                            idx % kDutchChipBg.length],
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.person,
                                              size: 10,
                                              color: kDutchChipText[
                                                  idx % kDutchChipText.length]),
                                          Text(
                                            s.participants[idx].name,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600).copyWith(
                                              color: kDutchChipText[
                                                  idx % kDutchChipText.length],
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
                            color: editing ? kDutchAccent : kDutchTextPrimary)),
                  ],
                ),
              ),
            );
          },
        ),
        if (s.items.length > 3)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kDutchReceiptBg.withValues(alpha: 0),
                      kDutchReceiptBg,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── 결과 영역 ────────────────────────────────────────────────

class _ResultSection extends StatelessWidget {
  const _ResultSection(
      {required this.s, required this.result, required this.vm});
  final IndividualSplitState s;
  final IndividualSplitResult result;
  final DutchPayViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (s.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Center(
          child: Text('메뉴를 추가하면 결과가 표시돼요',
              style: textEmptyGuide.copyWith(color: kDutchTextTertiary)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 합계',
                  style: textStyleCaption.copyWith(
                      color: kDutchTextSecondary)),
              Text('${_fmt(result.totalAmount)}원',
                  style: textStyle16.copyWith(
                      color: kDutchTextPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: kDutchDivider.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          // 참여자별 금액 — 최대 3줄, 스크롤 가능
          if (s.participants.length > 3)
            Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 88),
                  child: _participantAmountList(result),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 28,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            kDutchBg3.withValues(alpha: 0),
                            kDutchBg3,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            _participantAmountList(result),
          const SizedBox(height: 12),
          _ShareResultBtn(s: s, result: result),
        ],
      ),
    );
  }

  Widget _participantAmountList(IndividualSplitResult result) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 88),
      child: SingleChildScrollView(
        child: Column(
          children: s.participants.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.person,
                        size: CmTab.iconSize,
                        color: kDutchChipText[e.key % kDutchChipText.length]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(e.value.name,
                          overflow: TextOverflow.ellipsis,
                          style: rowLabel.copyWith(
                              color: kDutchTextPrimary,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text('${_fmt(result.personAmounts[e.key])}원',
                        style: textStyle16.copyWith(
                            color: kDutchTextPrimary)),
                  ],
                ),
              )).toList(),
        ),
      ),
    );
  }

  String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
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
          gradient:
              const LinearGradient(colors: [Color(0xFFF48FB1), kDutchAccent]),
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
                style: textStyle16.copyWith(
                    color: Colors.white)),
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
