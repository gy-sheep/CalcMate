import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/utils/app_toast.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/models/currency_info.dart';
import 'currency_calculator_colors.dart';
import 'currency_calculator_viewmodel.dart';
import 'widgets/amount_display.dart';
import 'widgets/currency_code_button.dart';
import 'widgets/currency_number_pad.dart';
import 'widgets/currency_picker_sheet.dart';

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class CurrencyCalculatorScreen extends ConsumerStatefulWidget {
  final String title;

  const CurrencyCalculatorScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<CurrencyCalculatorScreen> createState() =>
      _CurrencyCalculatorScreenState();
}

class _CurrencyCalculatorScreenState
    extends ConsumerState<CurrencyCalculatorScreen> {
  final _scrollController = ScrollController();
  bool _showBottomFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() => _checkFade();

  void _checkFade() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final canScroll = pos.maxScrollExtent > 0;
    if (_showBottomFade != (canScroll && !atBottom)) {
      setState(() => _showBottomFade = canScroll && !atBottom);
    }
  }

  String _formatLastUpdated(DateTime? dt, {required bool hasRates}) {
    if (dt == null) return hasRates ? '임시 환율 사용 중' : '환율 정보 없음';
    final isPm = dt.hour >= 12;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '${dt.year}.$month.$day. ${isPm ? '오후' : '오전'} $hour:$minute 기준';
  }

  void _showToast(BuildContext context, String message) =>
      showAppToast(context, message);

  @override
  Widget build(BuildContext context) {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: AppTokens.sizeAppBarBackIcon),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
          style: AppTokens.textStyleAppBarTitle.copyWith(color: Colors.white),
        ),
        centerTitle: false,
      ),
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
                  // 통화 행들 — 부모 높이를 전부 사용, 넘치면 스크롤
                  Expanded(
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) => SingleChildScrollView(
                            controller: _scrollController,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight + AdBannerPlaceholder.height),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, right: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // From 행
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(minHeight: 80),
                                      child: Row(
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
                                    ),
                                    // To 행 3개
                                    for (int i = 0; i < state.toCodes.length; i++)
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 80),
                                        child: Row(
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
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_showBottomFade)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 48,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.6, 1.0],
                                    colors: [
                                      kCurrencyGradientBottom.withValues(alpha: 0),
                                      kCurrencyGradientBottom.withValues(alpha: 0.7),
                                      kCurrencyGradientBottom,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                          style: AppTokens.textStyleCaption.copyWith(
                            color: Colors.white38,
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
                                    radius: AppTokens.radiusActivityIndicator,
                                    color: Colors.white54,
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white54,
                                    size: AppTokens.sizeIconSmall,
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
                  const AdBannerPlaceholder(),
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
                      child: Row(
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
                            style: AppTokens.textStyleBody.copyWith(
                              color: Colors.white70,
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
