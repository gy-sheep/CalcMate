import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_tokens.dart';
import '../main/main_screen_viewmodel.dart';

class CalculatorManagementScreen extends ConsumerWidget {
  const CalculatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(mainScreenViewModelProvider).entries;
    final visibleCount = entries.where((e) => e.isVisible).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: const Text('계산기 관리'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          // 안내 텍스트
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '메인 화면에 표시할 계산기를 선택하세요.',
              style: AppTokens.textStyleCaption
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final isLastVisible =
                    entry.isVisible && visibleCount <= 1;

                return SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    entry.title,
                    style: AppTokens.textStyleBody.copyWith(
                      color: isLastVisible
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : colorScheme.onSurface,
                    ),
                  ),
                  value: entry.isVisible,
                  onChanged: isLastVisible
                      ? null
                      : (_) {
                          ref
                              .read(mainScreenViewModelProvider.notifier)
                              .handleIntent(
                                MainScreenIntent.toggleVisibility(entry.id),
                              );
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
