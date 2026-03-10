import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_tokens.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../main/main_screen_viewmodel.dart';
import 'calculator_management_screen.dart';
import 'open_source_licenses_screen.dart';
import 'settings_viewmodel.dart';

// ── 설정 화면 ──

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CmSheet.radius),
        ),
      ),
      builder: (_) => const _LanguageSheet(selected: '한국어'),
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

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsViewModelProvider).themeMode;
    final entries = ref.watch(mainScreenViewModelProvider).entries;
    final visibleCount = entries.where((e) => e.isVisible).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F7),
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('설정'),
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
                    label: '언어',
                    value: '한국어',
                    onTap: () => _showLanguageSheet(context),
                  ),
                  _SettingsTile(
                    label: '화면 테마',
                    value: _themeModeLabel(themeMode),
                    onTap: () => _showThemeModeSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: '일반',
                children: [
                  _SettingsTile(
                    label: '계산기 관리',
                    value: '$visibleCount개',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CalculatorManagementScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    label: '환율 기준 통화',
                    value: 'KRW',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    label: 'BMI 단위',
                    value: 'kg/cm',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: '앱 정보',
                children: [
                  _SettingsTile(
                    label: '버전 정보',
                    value: '1.0.0',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    label: '오픈소스 라이선스',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OpenSourceLicensesScreen(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    label: '개인정보 처리방침',
                    onTap: () {},
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

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => '시스템 기준',
        ThemeMode.light => '라이트',
        ThemeMode.dark => '다크',
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
  final String selected;
  const _LanguageSheet({required this.selected});

  static const _languages = ['한국어', 'English', '中文', '日本語'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                '언어',
                style: textStyle16
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          for (int i = 0; i < _languages.length; i++) ...[
            if (i > 0) const Divider(
              thickness: CmSheet.dividerThickness,
              height: CmSheet.dividerHeight,
              indent: 16,
              endIndent: 16,
            ),
            _SheetRadioTile(
              label: _languages[i],
              isSelected: _languages[i] == selected,
              onTap: () => Navigator.pop(context),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── 다크 모드 선택 바텀시트 ──

class _ThemeModeSheet extends StatelessWidget {
  final ThemeMode selected;
  const _ThemeModeSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                '화면 테마',
                style: textStyle16
                    .copyWith(color: colorScheme.onSurface),
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
              label: _themeModeLabel(ThemeMode.values[i]),
              isSelected: ThemeMode.values[i] == selected,
              onTap: () => Navigator.pop(context, ThemeMode.values[i]),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => '시스템 기준',
        ThemeMode.light => '라이트',
        ThemeMode.dark => '다크',
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
