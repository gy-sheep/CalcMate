import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/dutch_pay_state.dart';
import '../../../domain/usecases/dutch_pay_equal_split_usecase.dart';
import '../dutch_pay_colors.dart';
import '../dutch_pay_viewmodel.dart';
import 'dutch_pay_keypad.dart';
import 'share_sheet.dart';

class EqualSplitView extends ConsumerWidget {
  const EqualSplitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dutchPayViewModelProvider);
    final vm = ref.read(dutchPayViewModelProvider.notifier);
    final eq = state.equalSplit;
    final result = vm.equalSplitResult;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => vm.handleIntent(
                    const DutchPayIntent.keypadToggled(false)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AmountCard(eq: eq, vm: vm),
                      const SizedBox(height: 14),
                      _PeopleRow(people: eq.people, vm: vm),
                      const SizedBox(height: 14),
                      if (state.isKorea) ...[
                        _RemainderRow(eq: eq, vm: vm, context: context),
                        const SizedBox(height: 14),
                      ] else ...[
                        _TipRow(eq: eq, vm: vm),
                        const SizedBox(height: 14),
                      ],
                      _ResultCard(result: result, isKorea: state.isKorea, vm: vm),
                    ],
                  ),
                ),
              ),
              // 스크롤 페이드
              Positioned(
                left: 0, right: 0, bottom: 0, height: 48,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.6, 1.0],
                        colors: [
                          kDutchBg2.withValues(alpha: 0),
                          kDutchBg2.withValues(alpha: 0.7),
                          kDutchBg2,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 공유 버튼 (고정)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: _ShareBtn(result: result, isKorea: state.isKorea, eq: eq, vm: vm),
        ),
        if (eq.keypadVisible)
          DutchPayKeypad(
            onKeyPressed: (key) =>
                vm.handleIntent(DutchPayIntent.keyPressed(key)),
          ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

// ── 총 금액 카드 ────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.eq, required this.vm});
  final EqualSplitState eq;
  final DutchPayViewModel vm;

  String get _displayText {
    if (eq.rawInput.isEmpty) return '0';
    final n = int.tryParse(eq.rawInput) ?? 0;
    return _fmt(n);
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.handleIntent(
          eq.rawInput.isNotEmpty
              ? const DutchPayIntent.keyPressed('C')
              : const DutchPayIntent.keypadToggled(true)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: kDutchCardBg,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(
            color: eq.keypadVisible
                ? kDutchAccent.withValues(alpha: 0.5)
                : kDutchDivider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 금액',
                style: TextStyle(
                    color: kDutchTextTertiary,
                    fontSize: AppTokens.fontSizeLabel)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _displayText,
                  style: const TextStyle(
                    color: kDutchTextPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text('원',
                    style: TextStyle(
                        color: kDutchTextTertiary,
                        fontSize: AppTokens.fontSizeBody)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 인원 행 ─────────────────────────────────────────────────

class _PeopleRow extends StatelessWidget {
  const _PeopleRow({required this.people, required this.vm});
  final int people;
  final DutchPayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('인원',
            style: TextStyle(
                color: kDutchTextPrimary,
                fontSize: AppTokens.fontSizeBody,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        _StepBtn(
          icon: Icons.remove,
          enabled: people > 2,
          onTap: () => vm.handleIntent(const DutchPayIntent.peopleChanged(-1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$people명',
              style: const TextStyle(
                  color: kDutchTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ),
        _StepBtn(
          icon: Icons.add,
          enabled: people < 30,
          onTap: () => vm.handleIntent(const DutchPayIntent.peopleChanged(1)),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? kDutchAccent.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? kDutchAccent.withValues(alpha: 0.4)
                : kDutchDivider,
          ),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? kDutchAccent : kDutchTextTertiary),
      ),
    );
  }
}

// ── 정산 단위 행 (KR) ───────────────────────────────────────

class _RemainderRow extends StatelessWidget {
  const _RemainderRow(
      {required this.eq, required this.vm, required this.context});
  final EqualSplitState eq;
  final DutchPayViewModel vm;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('정산 단위',
            style: TextStyle(
                color: kDutchTextSecondary,
                fontSize: AppTokens.fontSizeBody,
                fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () => _showPicker(ctx),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kDutchCardBg,
              borderRadius:
                  BorderRadius.circular(AppTokens.radiusChip),
              border: Border.all(color: kDutchDivider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(eq.remUnit.label,
                    style: TextStyle(
                        color: kDutchTextPrimary,
                        fontSize: AppTokens.fontSizeBody,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more,
                    size: 18, color: kDutchTextSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusBottomSheet)),
      ),
      builder: (bsCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: kDutchDivider,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('정산 단위',
                  style: TextStyle(
                      color: kDutchTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          ...RemUnit.values.map((u) => ListTile(
                title: Text(u.label,
                    style: TextStyle(color: kDutchTextPrimary)),
                trailing: eq.remUnit == u
                    ? Icon(Icons.check, color: kDutchAccent)
                    : null,
                onTap: () {
                  vm.handleIntent(DutchPayIntent.remUnitChanged(u));
                  Navigator.pop(bsCtx);
                },
              )),
          SizedBox(
              height:
                  MediaQuery.of(bsCtx).padding.bottom + 8),
        ],
      ),
    );
  }
}

// ── 팁 행 (Non-KR) ──────────────────────────────────────────

class _TipRow extends StatelessWidget {
  const _TipRow({required this.eq, required this.vm});
  final EqualSplitState eq;
  final DutchPayViewModel vm;

  static const _tipOptions = [0.0, 10.0, 15.0, 20.0];
  static const _tipLabels = ['없음', '10%', '15%', '20%'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('팁 추가',
            style: TextStyle(
                color: kDutchTextSecondary,
                fontSize: AppTokens.fontSizeBody,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ..._tipOptions.asMap().entries.map((e) {
                final selected =
                    !eq.isCustomTip && eq.tipRate == e.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => vm.handleIntent(
                        DutchPayIntent.tipRateChanged(e.value)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? kDutchAccent
                            : kDutchCardBg,
                        borderRadius: BorderRadius.circular(
                            AppTokens.radiusChip),
                        border: Border.all(
                          color: selected
                              ? kDutchAccent
                              : kDutchDivider,
                        ),
                      ),
                      child: Text(
                        _tipLabels[e.key],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : kDutchTextPrimary,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // 직접입력 칩
              GestureDetector(
                onTap: () => vm.handleIntent(
                    const DutchPayIntent.tipRateChanged(-1)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: eq.isCustomTip
                        ? kDutchAccent
                        : kDutchCardBg,
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusChip),
                    border:
                        Border.all(color: eq.isCustomTip ? kDutchAccent : kDutchDivider),
                  ),
                  child: Text(
                    eq.isCustomTip && eq.tipInput.isNotEmpty
                        ? '${eq.tipInput}%'
                        : '직접입력',
                    style: TextStyle(
                      color: eq.isCustomTip
                          ? Colors.white
                          : kDutchTextPrimary,
                      fontSize: 14,
                      fontWeight: eq.isCustomTip
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 결과 카드 ────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard(
      {required this.result, required this.isKorea, required this.vm});
  final EqualSplitResult? result;
  final bool isKorea;
  final DutchPayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kDutchAccent.withValues(alpha: 0.08),
            kDutchAccent.withValues(alpha: 0.03)
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: kDutchAccent.withValues(alpha: 0.2)),
      ),
      child: result == null
          ? Center(
              child: Text('총액을 입력하면 결과가 표시돼요',
                  style: TextStyle(
                      color: kDutchTextTertiary,
                      fontSize: AppTokens.fontSizeBody)))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (!isKorea) {
      return Column(
        children: [
          Text('1인당',
              style: TextStyle(
                  color: kDutchTextTertiary,
                  fontSize: AppTokens.fontSizeLabel)),
          const SizedBox(height: 4),
          Text(
            vm.fmt(result!.perPersonWithTip.round()),
            style: const TextStyle(
              color: kDutchAccent,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          Text('원',
              style: TextStyle(
                  color: kDutchTextTertiary,
                  fontSize: AppTokens.fontSizeLabel)),
        ],
      );
    }

    if (result!.isEven) {
      return Column(
        children: [
          Text('1인당',
              style: TextStyle(
                  color: kDutchTextTertiary,
                  fontSize: AppTokens.fontSizeLabel)),
          const SizedBox(height: 4),
          Text(
            vm.fmt(result!.rounded),
            style: const TextStyle(
              color: kDutchAccent,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          Text('원',
              style: TextStyle(
                  color: kDutchTextTertiary,
                  fontSize: AppTokens.fontSizeLabel)),
        ],
      );
    }

    return Column(
      children: [
        _ResultRow(
          label: '참여자 ${result!.people - 1}명',
          amount: vm.fmt(result!.rounded),
        ),
        Divider(
            height: 20,
            color: kDutchDivider.withValues(alpha: 0.5)),
        _ResultRow(
          label: '계산한 사람',
          amount: vm.fmt(result!.organizer),
          highlight: true,
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(
      {required this.label, required this.amount, this.highlight = false});
  final String label;
  final String amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: highlight ? kDutchTextPrimary : kDutchTextSecondary,
                fontSize: AppTokens.fontSizeBody,
                fontWeight:
                    highlight ? FontWeight.w600 : FontWeight.w400)),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: amount,
              style: TextStyle(
                color: highlight ? kDutchAccent : kDutchTextPrimary,
                fontSize: highlight ? 22 : AppTokens.fontSizeValue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '원',
              style: TextStyle(
                color: kDutchTextTertiary,
                fontSize: AppTokens.fontSizeLabel,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ── 공유 버튼 ────────────────────────────────────────────────

class _ShareBtn extends StatelessWidget {
  const _ShareBtn(
      {required this.result,
      required this.isKorea,
      required this.eq,
      required this.vm});
  final EqualSplitResult? result;
  final bool isKorea;
  final EqualSplitState eq;
  final DutchPayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final hasResult = result != null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hasResult ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: hasResult ? () => _share(context) : null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: hasResult
                ? const LinearGradient(
                    colors: [Color(0xFFF48FB1), kDutchAccent])
                : null,
            color: hasResult ? null : kDutchDivider,
            borderRadius:
                BorderRadius.circular(AppTokens.radiusCard),
            boxShadow: hasResult
                ? [
                    BoxShadow(
                      color: kDutchAccent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('결과 공유',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _share(BuildContext context) {
    final total = int.tryParse(eq.rawInput) ?? 0;
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareSheet(
        shareData: EqualShareData(
          totalAmount: total,
          people: eq.people,
          rounded: result!.rounded,
          organizer: result!.organizer,
          isEven: result!.isEven,
          isKorea: isKorea,
          tipRate: eq.tipRate,
          perPersonWithTip: result!.perPersonWithTip,
        ),
      ),
    );
  }
}
