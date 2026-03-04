import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/currency_info.dart';
import 'currency_calculator_colors.dart';
import 'currency_calculator_viewmodel.dart';
import 'widgets/amount_display.dart';
import 'widgets/currency_app_bar.dart';
import 'widgets/currency_code_button.dart';
import 'widgets/currency_number_pad.dart';
import 'widgets/currency_picker_sheet.dart';

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class CurrencyCalculatorScreen extends ConsumerWidget {
  final String title;
  final IconData icon;

  const CurrencyCalculatorScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  String _formatLastUpdated(DateTime? dt, {required bool hasRates}) {
    if (dt == null) return hasRates ? '임시 환율 사용 중' : '환율 정보 없음';
    final isPm = dt.hour >= 12;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}.$month.$day. ${isPm ? '오후' : '오전'} $hour:$minute 기준';
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1500), () => entry.remove());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exchangeRateViewModelProvider);
    final vm = ref.read(exchangeRateViewModelProvider.notifier);

    ref.listen(
      exchangeRateViewModelProvider.select((s) => s.toastMessage),
      (_, message) {
        if (message != null) {
          _showToast(context, message);
          vm.clearToast();
        }
      },
    );

    final fromDisplay = vm.formattedInput;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kCurrencyGradientTop, kCurrencyGradientBottom],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  CurrencyAppBar(title: title, icon: icon),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  // 통화 행들 — 부모 높이를 전부 사용
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // From 행
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CurrencyCodeButton(
                                code: state.fromCode,
                                onTap: () => _selectCurrency(
                                  context, ref,
                                  toIndex: -1,
                                  selectedCode: state.fromCode,
                                  rates: state.rates,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AmountDisplay(
                                  amount: fromDisplay,
                                  isActive: true,
                                ),
                              ),
                            ],
                          ),
                          // To 행 3개
                          for (int i = 0; i < state.toCodes.length; i++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CurrencyCodeButton(
                                  code: state.toCodes[i],
                                  onTap: () => _selectCurrency(
                                    context, ref,
                                    toIndex: i,
                                    selectedCode: state.toCodes[i],
                                    rates: state.rates,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AmountDisplay(
                                    amount: vm.convertedDisplayAt(i),
                                    isActive: false,
                                    hint: vm.unitRateDisplayAt(i),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 업데이트 시간 + 새로고침
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          _formatLastUpdated(
                            state.lastUpdated,
                            hasRates: state.rates.isNotEmpty,
                          ),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: state.isRefreshing
                              ? null
                              : () => vm.handleIntent(const ExchangeRateIntent.refreshRequested()),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: state.isRefreshing
                                ? const CupertinoActivityIndicator(
                                    radius: 10,
                                    color: Colors.white54,
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  const Divider(
                      color: kCurrencyDivider, thickness: 0.5, height: 1),
                  // 숫자 키패드
                  CurrencyNumberPad(
                    onKeyTap: (key) => vm.handleIntent(ExchangeRateIntent.keyTapped(key)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // 로딩 오버레이 (화면 전체 dim + 인디케이터)
            if (state.isLoading)
              Container(
                color: Colors.black45,
              ),
            if (state.isLoading)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: 14),
                          Text(
                            '환율 정보를 가져오는 중...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// [toIndex] -1이면 From, 0/1/2이면 해당 To 행
  Future<void> _selectCurrency(
    BuildContext context,
    WidgetRef ref, {
    required int toIndex,
    required String selectedCode,
    required Map<String, double> rates,
  }) async {
    // rates에 있는 통화만 필터링하여 표시
    final available = rates.isEmpty
        ? kSupportedCurrencies
        : kSupportedCurrencies
            .where((c) => rates.containsKey(c.code))
            .toList();

    final state = ref.read(exchangeRateViewModelProvider);
    // From 선택: 현재 fromCode만 제외 (To 통화 선택 시 swap)
    // To 선택: fromCode + 나머지 toCodes 전체 제외
    final usedCodes = toIndex < 0
        ? {state.fromCode}
        : {state.fromCode, ...state.toCodes};

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        currencies: available,
        selectedCode: selectedCode,
        usedCodes: usedCodes,
        fromCode: toIndex >= 0 ? state.fromCode : null,
      ),
    );
    if (result == null) return;

    final vm = ref.read(exchangeRateViewModelProvider.notifier);
    if (toIndex < 0) {
      vm.handleIntent(ExchangeRateIntent.fromCurrencyChanged(result));
    } else {
      vm.handleIntent(ExchangeRateIntent.toCurrencyChanged(toIndex, result));
    }
  }
}
