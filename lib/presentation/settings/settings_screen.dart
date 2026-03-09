import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_tokens.dart';
import '../main/main_screen_viewmodel.dart';
import 'calculator_management_screen.dart';
import 'settings_viewmodel.dart';

// ── 설정 화면 ──

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showThemeModeSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(settingsViewModelProvider).themeMode;
    showModalBottomSheet<ThemeMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusBottomSheet),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsViewModelProvider).themeMode;
    final entries = ref.watch(mainScreenViewModelProvider).entries;
    final visibleCount = entries.where((e) => e.isVisible).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: const Text('설정'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: ListView(
        children: [
          _SectionHeader(label: '화면'),
          _SettingsTile(
            label: '다크 모드',
            value: _themeModeLabel(themeMode),
            onTap: () => _showThemeModeSheet(context, ref),
          ),
          const Divider(height: 1, indent: 16, endIndent: 0),
          _SectionHeader(label: '메인 화면'),
          _SettingsTile(
            label: '계산기 관리',
            value: '$visibleCount개',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CalculatorManagementScreen(),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 0),
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

// ── 섹션 헤더 ──

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainer,
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTokens.textStyleCaption.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 설정 항목 행 ──

class _SettingsTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTokens.textStyleBody
                      .copyWith(color: colorScheme.onSurface),
                ),
              ),
              Text(
                value,
                style: AppTokens.textStyleBody.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '다크 모드',
                style: AppTokens.textStyleValue
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
          const Divider(height: 1),
          for (final option in ThemeMode.values)
            _SheetRadioTile(
              label: _themeModeLabel(option),
              isSelected: option == selected,
              onTap: () => Navigator.pop(context, option),
            ),
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
                  style: AppTokens.textStyleBody
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
