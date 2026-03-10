import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_design_tokens.dart';
import '../widgets/blur_status_bar_overlay.dart';
import '../main/main_screen_viewmodel.dart';

const _kActiveColorLight = Color(0xFF5B7FCC); // 딥 블루
const _kActiveColorDark = Color(0xFF6B7B8D);  // 슬레이트

class CalculatorManagementScreen extends ConsumerStatefulWidget {
  const CalculatorManagementScreen({super.key});

  @override
  ConsumerState<CalculatorManagementScreen> createState() =>
      _CalculatorManagementScreenState();
}

class _CalculatorManagementScreenState
    extends ConsumerState<CalculatorManagementScreen> {
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

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(mainScreenViewModelProvider).entries;
    final visibleCount = entries.where((e) => e.isVisible).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
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
        title: const Text('계산기 관리'),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '메인 화면에 표시할 계산기를 선택하세요.',
                        style: textStyleCaption
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final allVisible =
                            entries.every((e) => e.isVisible);
                        ref
                            .read(mainScreenViewModelProvider.notifier)
                            .handleIntent(
                              MainScreenIntent.setAllVisibility(
                                  !allVisible),
                            );
                      },
                      child: Text(
                        entries.every((e) => e.isVisible)
                            ? '전체 해제'
                            : '전체 선택',
                        style: textStyleCaption.copyWith(
                          color: isDark
                              ? _kActiveColorDark
                              : _kActiveColorLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius:
                      BorderRadius.circular(radiusCard),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < entries.length; i++) ...[
                      _CalculatorTile(
                        icon: entries[i].icon,
                        title: entries[i].title,
                        isVisible: entries[i].isVisible,
                        onTap:
                            entries[i].isVisible && visibleCount <= 1
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(
                                            mainScreenViewModelProvider
                                                .notifier)
                                        .handleIntent(
                                          MainScreenIntent
                                              .toggleVisibility(
                                                  entries[i].id),
                                        );
                                  },
                      ),
                      if (i < entries.length - 1)
                        Divider(
                          height: 1,
                          indent: 66,
                          endIndent: 16,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          BlurStatusBarOverlay(
            isVisible: _isScrolled,
            backgroundColor:
                isDark ? Colors.black : const Color(0xFFF2F2F7),
          ),
        ],
      ),
    );
  }
}

// ── 계산기 타일 ──

class _CalculatorTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isVisible;
  final VoidCallback? onTap;

  const _CalculatorTile({
    required this.icon,
    required this.title,
    required this.isVisible,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor =
        isDark ? _kActiveColorDark : _kActiveColorLight;

    final iconBgColor = isVisible
        ? activeColor.withValues(alpha: isDark ? 0.15 : 0.1)
        : (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08));
    final iconColor = isVisible
        ? activeColor
        : colorScheme.onSurface.withValues(alpha: 0.3);
    final titleColor = isVisible
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.35);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radiusCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // 타이틀
            Expanded(
              child: Text(
                title,
                style: inputFieldInnerLabel.copyWith(
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 체크 인디케이터
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isVisible
                    ? activeColor
                    : Colors.transparent,
                border: isVisible
                    ? null
                    : Border.all(
                        color: isDark
                            ? const Color(0xFF48484A)
                            : const Color(0xFFD1D1D6),
                        width: 1.5,
                      ),
              ),
              child: isVisible
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
