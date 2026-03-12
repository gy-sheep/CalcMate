import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/error_messages.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/utils/app_toast.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../domain/models/currency_info.dart';
import '../../l10n/app_localizations.dart';
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
  bool _showTopFade = false;
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
    final canScroll = pos.maxScrollExtent > 0;
    final atTop = pos.pixels <= 8;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final newTop = canScroll && !atTop;
    final newBottom = canScroll && !atBottom;
    if (_showTopFade != newTop || _showBottomFade != newBottom) {
      setState(() {
        _showTopFade = newTop;
        _showBottomFade = newBottom;
      });
    }
  }

  String _formatLastUpdated(DateTime? dt, {required bool hasRates, required AppLocalizations l10n}) {
    if (dt == null) return hasRates ? l10n.currency_status_fallback : l10n.currency_status_noRates;
    final isPm = dt.hour >= 12;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final amPm = isPm ? l10n.common_pm : l10n.common_am;
    return l10n.currency_label_asOf('${dt.year}.$month.$day $amPm $hour:$minute');
  }

  String _resolveMessage(String key, AppLocalizations l10n) => switch (key) {
        ErrorMessages.exchangeRateLoadFailed => l10n.error_exchangeRateLoadFailed,
        ErrorMessages.exchangeRateUsingFallback => l10n.error_exchangeRateUsingFallback,
        'toast_integerExceeded' => l10n.common_toast_integerExceeded,
        'toast_fractionalExceeded' => l10n.common_toast_fractionalExceeded,
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(exchangeRateViewModelProvider);
    final vm = ref.read(exchangeRateViewModelProvider.notifier);

    ref.listen(
      exchangeRateViewModelProvider.select((s) => s.toastMessage),
      (_, message) {
        if (message != null) {
          final resolved = _resolveMessage(message, l10n);
          if (resolved.isNotEmpty) showAppToast(context, resolved);
          vm.clearToast();
        }
      },
    );

    final fromDisplay = vm.formattedInput;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.title,
          style: CmAppBar.titleText.copyWith(color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kCurrencyBg1, kCurrencyBg2],
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
                        _resolveMessage(state.error!, l10n),
                        style: textStyleCaption.copyWith(
                          color: Colors.redAccent,
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
                                padding: CmCurrencyRow.padding,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // From 행
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(minHeight: CmCurrencyRow.minHeight),
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
                                        constraints: const BoxConstraints(minHeight: CmCurrencyRow.minHeight),
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
                                            const SizedBox(width: CmCurrencyRow.codeSpacing),
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
                        if (_showTopFade)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            height: 48,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    stops: const [0.0, 0.6, 1.0],
                                    colors: [
                                      kCurrencyBg2.withValues(alpha: 0),
                                      kCurrencyBg2.withValues(alpha: 0.7),
                                      kCurrencyBg2,
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
                                      kCurrencyBg2.withValues(alpha: 0),
                                      kCurrencyBg2.withValues(alpha: 0.7),
                                      kCurrencyBg2,
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
                            l10n: l10n,
                          ),
                          style: textStyleCaption.copyWith(
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
                                    radius: CmIcon.activityIndicator,
                                    color: Colors.white54,
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: Colors.white54,
                                    size: CmIcon.small,
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
                  borderRadius: BorderRadius.circular(CmLoadingOverlay.radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: CmLoadingOverlay.blurSigma,
                      sigmaY: CmLoadingOverlay.blurSigma,
                    ),
                    child: Container(
                      padding: CmLoadingOverlay.padding,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(CmLoadingOverlay.radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: CmLoadingOverlay.spinnerSize,
                            height: CmLoadingOverlay.spinnerSize,
                            child: CircularProgressIndicator(
                              strokeWidth: CmLoadingOverlay.spinnerStroke,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: CmLoadingOverlay.spinnerTextSpacing),
                          Text(
                            l10n.currency_loading,
                            style: CmLoadingOverlay.text.copyWith(
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
