import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'participant_chip.dart';

// ── 메뉴 입력 바텀시트 ──────────────────────────────────────

class MenuInputSheet extends ConsumerStatefulWidget {
  const MenuInputSheet({super.key, required this.parentRef});
  final WidgetRef parentRef;

  @override
  ConsumerState<MenuInputSheet> createState() => _MenuInputSheetState();
}

class _MenuInputSheetState extends ConsumerState<MenuInputSheet> {
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
    final l10n = AppLocalizations.of(context);
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
            Text(isEditing ? l10n.dutchPay_label_editItem : l10n.dutchPay_label_addItem,
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
                        hintText: l10n.dutchPay_hint_menuName,
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
                        hintText: l10n.dutchPay_hint_amount,
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
                          child: Text(l10n.common_delete,
                              style: textStyle16.copyWith(
                                  color: kDutchAccent)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SubmitButton(
                      label: l10n.dutchPay_button_modify,
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
              SubmitButton(
                label: l10n.common_add,
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

class SubmitButton extends StatelessWidget {
  const SubmitButton(
      {super.key,
      required this.label,
      required this.enabled,
      required this.onTap});
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: durationAnimFast,
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
