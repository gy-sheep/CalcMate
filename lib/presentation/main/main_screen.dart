import 'dart:ui';

import 'package:calcmate/core/navigation/calc_page_route.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_screen.dart';
import 'package:calcmate/presentation/currency/currency_calculator_screen.dart';
import 'package:calcmate/presentation/unit_converter/unit_converter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calc_mode_card.dart';
import 'main_screen_viewmodel.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    final isScrolled = ref.read(mainScreenViewModelProvider).isScrolled;
    if (scrolled != isScrolled) {
      ref
          .read(mainScreenViewModelProvider.notifier)
          .handleIntent(MainScreenIntent.scrollChanged(scrolled));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainScreenViewModelProvider);
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: state.isScrolled
                ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: state.isScrolled
                  ? Colors.white.withValues(alpha: 0.75)
                  : Theme.of(context).colorScheme.surface,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                title: const Text('CalcMate'),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: 설정 화면으로 이동
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.only(top: topPadding + 16, bottom: 16),
          itemCount: state.entries.length,
          itemBuilder: (context, index) {
            final entry = state.entries[index];
            return CalcModeCard(
              title: entry.title,
              description: entry.description,
              icon: entry.icon,
              imagePath: entry.imagePath,
              onTap: () {
                if (entry.id == 'basic_calculator') {
                  Navigator.of(context).push(
                    CalcPageRoute(
                      builder: (_) => BasicCalculatorScreen(
                        title: entry.title,
                        icon: entry.icon,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  );
                } else if (entry.id == 'exchange_rate') {
                  Navigator.of(context).push(
                    CalcPageRoute(
                      builder: (_) => CurrencyCalculatorScreen(
                        title: entry.title,
                        icon: entry.icon,
                      ),
                    ),
                  );
                } else if (entry.id == 'unit_converter') {
                  Navigator.of(context).push(
                    CalcPageRoute(
                      builder: (_) => UnitConverterScreen(
                        title: entry.title,
                        icon: entry.icon,
                      ),
                    ),
                  );
                } else {
                  ref
                      .read(mainScreenViewModelProvider.notifier)
                      .handleIntent(MainScreenIntent.cardTapped(entry.id));
                }
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }
}
