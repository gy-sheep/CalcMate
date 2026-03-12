import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/utils/app_toast.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../main/main_screen_viewmodel.dart';
import 'calculator_management_screen.dart';
import 'open_source_licenses_screen.dart';
import '../../domain/models/currency_unit.dart';
import 'settings_viewmodel.dart';

// ── 환율 기준 통화 선택지 (10개) ──

const _kBaseCurrencyCodes = [
  'KRW', 'USD', 'EUR', 'JPY', 'CNY',
  'GBP', 'AUD', 'CAD', 'CHF', 'HKD',
];

// ── 설정 화면 ──

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(settingsViewModelProvider).locale;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CmSheet.radius),
        ),
      ),
      builder: (_) => _LanguageSheet(
        selectedLocale: currentLocale,
        onSelected: (locale) {
          ref
              .read(settingsViewModelProvider.notifier)
              .handleIntent(SettingsIntent.localeChanged(locale));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemeModeSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsViewModelProvider).themeMode;
    showModalBottomSheet<ThemeMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CmSheet.radius),
        ),
      ),
      builder: (_) => _ThemeModeSheet(selected: current),
    ).then((picked) {
      if (picked != null) {
        ref
            .read(settingsViewModelProvider.notifier)
            .handleIntent(SettingsIntent.themeModeChanged(picked));
      }
    });
  }

  void _showDisplayCurrencySheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsViewModelProvider).displayCurrency;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CmSheet.radius),
        ),
      ),
      builder: (_) => _DisplayCurrencySheet(
        selected: current,
        onSelected: (currency) {
          ref
              .read(settingsViewModelProvider.notifier)
              .handleIntent(
                  SettingsIntent.displayCurrencyChanged(currency));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBaseCurrencySheet(BuildContext context, WidgetRef ref) {
    final resolved = ref.read(baseCurrencyProvider);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CmSheet.radius),
        ),
      ),
      builder: (_) => _BaseCurrencySheet(
        selected: resolved,
        onSelected: (code) {
          ref
              .read(settingsViewModelProvider.notifier)
              .handleIntent(SettingsIntent.baseCurrencyChanged(code));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsViewModelProvider);
    final resolvedCurrency = ref.watch(displayCurrencyProvider);
    final resolvedBaseCurrency = ref.watch(baseCurrencyProvider);
    final entries = ref.watch(mainScreenViewModelProvider).entries;
    final visibleCount = entries.where((e) => e.isVisible).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.settings_title),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              statusBarHeight + kToolbarHeight + 8,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              _SectionCard(
                children: [
                  _SettingsTile(
                    label: l10n.settings_language,
                    value: _localeLabel(l10n, settings.locale),
                    onTap: () => _showLanguageSheet(context, ref),
                  ),
                  _SettingsTile(
                    label: l10n.settings_theme,
                    value: _themeModeLabel(l10n, settings.themeMode),
                    onTap: () => _showThemeModeSheet(context, ref),
                  ),
                  _SettingsTile(
                    label: l10n.settings_displayCurrency,
                    value: _displayCurrencyLabel(l10n, settings.displayCurrency, resolvedCurrency),
                    onTap: () => _showDisplayCurrencySheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.settings_sectionGeneral,
                children: [
                  _SettingsTile(
                    label: l10n.settings_calculatorManagement,
                    value: l10n.settings_calculatorCount(visibleCount),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CalculatorManagementScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    label: l10n.settings_baseCurrency,
                    value: resolvedBaseCurrency,
                    onTap: () => _showBaseCurrencySheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l10n.settings_sectionAppInfo,
                children: [
                  _SettingsTile(
                    label: l10n.settings_version,
                    value: _appVersion,
                    onTap: () {},
                  ),
                  _SettingsTile(
                    label: l10n.settings_openSourceLicenses,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OpenSourceLicensesScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    label: l10n.settings_privacyPolicy,
                    onTap: () {},
                  ),
                ],
              ),
              // TODO: 토스트 테스트용 — 확인 후 제거
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Toast Test',
                children: [
                  _SettingsTile(
                    label: 'Info Toast',
                    value: 'info',
                    onTap: () => showAppToast(context, '클립보드에 복사되었습니다'),
                  ),
                  _SettingsTile(
                    label: 'Success Toast',
                    value: 'success',
                    onTap: () => showAppToast(context, '저장이 완료되었습니다', type: ToastType.success),
                  ),
                  _SettingsTile(
                    label: 'Error Toast',
                    value: 'error',
                    onTap: () => showAppToast(context, '네트워크 연결을 확인해주세요', type: ToastType.error),
                  ),
                ],
              ),
            ],
          ),
          BlurStatusBarOverlay(
            isVisible: _isScrolled,
            backgroundColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }

  String _localeLabel(AppLocalizations l10n, Locale? locale) => switch (locale?.languageCode) {
        'ko' => l10n.settings_languageKo,
        'en' => l10n.settings_languageEn,
        _ => l10n.settings_languageSystem,
      };

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.settings_themeSystem,
        ThemeMode.light => l10n.settings_themeLight,
        ThemeMode.dark => l10n.settings_themeDark,
      };

  String _displayCurrencyLabel(
      AppLocalizations l10n, CurrencyUnit? selected, CurrencyUnit resolved) {
    if (selected == null) return '${l10n.settings_displayCurrencyAuto} (${resolved.code})';
    return _currencyLabel(l10n, selected);
  }

  static String _currencyLabel(AppLocalizations l10n, CurrencyUnit unit) =>
      switch (unit) {
        CurrencyUnit.krw => l10n.settings_currencyKRW,
        CurrencyUnit.usd => l10n.settings_currencyUSD,
        CurrencyUnit.eur => l10n.settings_currencyEUR,
        CurrencyUnit.jpy => l10n.settings_currencyJPY,
        CurrencyUnit.cny => l10n.settings_currencyCNY,
        CurrencyUnit.gbp => l10n.settings_currencyGBP,
      };
}

// ── 섹션 카드 ──

class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                title!,
                style: textStyle16.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── 설정 항목 행 ──

class _SettingsTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radiusCard),
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: inputFieldInnerLabel
                      .copyWith(color: colorScheme.onSurface),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: textStyleCaption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 언어 선택 바텀시트 ──

class _LanguageSheet extends StatelessWidget {
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onSelected;
  const _LanguageSheet({required this.selectedLocale, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final labels = [
      l10n.settings_languageSystem,
      l10n.settings_languageKo,
      l10n.settings_languageEn,
    ];
    final locales = [null, const Locale('ko'), const Locale('en')];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: CmSheet.handleWidth,
            height: CmSheet.handleHeight,
            margin: const EdgeInsets.only(
              top: CmSheet.handleTopSpacing,
              bottom: CmSheet.handleBottomSpacing,
            ),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(CmSheet.handleRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.settings_language,
                style: textStyle16.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0) const Divider(
              thickness: CmSheet.dividerThickness,
              height: CmSheet.dividerHeight,
              indent: 16,
              endIndent: 16,
            ),
            _SheetRadioTile(
              label: labels[i],
              isSelected: selectedLocale?.languageCode == locales[i]?.languageCode,
              onTap: () => onSelected(locales[i]),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── 표시 통화 선택 바텀시트 ──

class _DisplayCurrencySheet extends StatelessWidget {
  final CurrencyUnit? selected;
  final ValueChanged<CurrencyUnit?> onSelected;
  const _DisplayCurrencySheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final labels = [
      l10n.settings_displayCurrencyAuto,
      l10n.settings_currencyKRW,
      l10n.settings_currencyUSD,
      l10n.settings_currencyEUR,
      l10n.settings_currencyJPY,
      l10n.settings_currencyCNY,
      l10n.settings_currencyGBP,
    ];
    final units = <CurrencyUnit?>[null, ...CurrencyUnit.values];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: CmSheet.handleWidth,
            height: CmSheet.handleHeight,
            margin: const EdgeInsets.only(
              top: CmSheet.handleTopSpacing,
              bottom: CmSheet.handleBottomSpacing,
            ),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(CmSheet.handleRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.settings_displayCurrency,
                style: textStyle16.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < labels.length; i++) ...[
                    if (i > 0) const Divider(
                      thickness: CmSheet.dividerThickness,
                      height: CmSheet.dividerHeight,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SheetRadioTile(
                      label: labels[i],
                      isSelected: selected == units[i],
                      onTap: () => onSelected(units[i]),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 환율 기준 통화 선택 바텀시트 ──

class _BaseCurrencySheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _BaseCurrencySheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: CmSheet.handleWidth,
            height: CmSheet.handleHeight,
            margin: const EdgeInsets.only(
              top: CmSheet.handleTopSpacing,
              bottom: CmSheet.handleBottomSpacing,
            ),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(CmSheet.handleRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.settings_baseCurrency,
                style: textStyle16.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < _kBaseCurrencyCodes.length; i++) ...[
                    if (i > 0) const Divider(
                      thickness: CmSheet.dividerThickness,
                      height: CmSheet.dividerHeight,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SheetRadioTile(
                      label: _baseCurrencyCodeLabel(l10n, _kBaseCurrencyCodes[i]),
                      isSelected: selected == _kBaseCurrencyCodes[i],
                      onTap: () => onSelected(_kBaseCurrencyCodes[i]),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _baseCurrencyCodeLabel(AppLocalizations l10n, String code) =>
      switch (code) {
        'KRW' => l10n.settings_currencyKRW,
        'USD' => l10n.settings_currencyUSD,
        'EUR' => l10n.settings_currencyEUR,
        'JPY' => l10n.settings_currencyJPY,
        'CNY' => l10n.settings_currencyCNY,
        'GBP' => l10n.settings_currencyGBP,
        'AUD' => l10n.settings_currencyAUD,
        'CAD' => l10n.settings_currencyCAD,
        'CHF' => l10n.settings_currencyCHF,
        'HKD' => l10n.settings_currencyHKD,
        _ => code,
      };
}

// ── 다크 모드 선택 바텀시트 ──

class _ThemeModeSheet extends StatelessWidget {
  final ThemeMode selected;
  const _ThemeModeSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: CmSheet.handleWidth,
            height: CmSheet.handleHeight,
            margin: const EdgeInsets.only(
              top: CmSheet.handleTopSpacing,
              bottom: CmSheet.handleBottomSpacing,
            ),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(CmSheet.handleRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.settings_theme,
                style: textStyle16.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          for (int i = 0; i < ThemeMode.values.length; i++) ...[
            if (i > 0) const Divider(
              thickness: CmSheet.dividerThickness,
              height: CmSheet.dividerHeight,
              indent: 16,
              endIndent: 16,
            ),
            _SheetRadioTile(
              label: _themeModeLabel(l10n, ThemeMode.values[i]),
              isSelected: ThemeMode.values[i] == selected,
              onTap: () => Navigator.pop(context, ThemeMode.values[i]),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.settings_themeSystem,
        ThemeMode.light => l10n.settings_themeLight,
        ThemeMode.dark => l10n.settings_themeDark,
      };
}

// ── 바텀시트 라디오 행 ──

class _SheetRadioTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetRadioTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: inputFieldInnerLabel
                      .copyWith(color: colorScheme.onSurface),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, size: 20, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
