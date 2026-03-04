import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:calcmate/domain/models/calc_mode_entry.dart';
import 'package:calcmate/core/navigation/edge_swipe_back.dart';
import 'package:calcmate/presentation/calculator/basic_calculator_screen.dart';
import 'package:calcmate/presentation/currency/currency_calculator_screen.dart';
import 'package:calcmate/presentation/unit_converter/unit_converter_screen.dart';
import 'package:calcmate/presentation/age_calculator/age_calculator_screen.dart';
import 'package:calcmate/presentation/vat_calculator/vat_calculator_screen.dart';
import 'package:calcmate/presentation/date_calculator/date_calculator_screen.dart';
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
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.75))
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
          padding: EdgeInsets.only(
            top: topPadding + 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: state.entries.length,
          itemBuilder: (context, index) {
            final entry = state.entries[index];

            final screen = _buildScreen(entry);
            if (screen != null) {
              return OpenContainer(
                transitionDuration: const Duration(milliseconds: 400),
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                closedElevation: 2,
                openElevation: 0,
                closedColor: Colors.transparent,
                openColor: Colors.transparent,
                closedBuilder: (context, openContainer) {
                  return CalcModeCard(
                    title: entry.title,
                    description: entry.description,
                    icon: entry.icon,
                    imagePath: entry.imagePath,
                    onTap: openContainer,
                  );
                },
                openBuilder: (context, _) {
                  return EdgeSwipeBack(child: screen);
                },
              );
            }

            return CalcModeCard(
              title: entry.title,
              description: entry.description,
              icon: entry.icon,
              imagePath: entry.imagePath,
              onTap: () {
                ref
                    .read(mainScreenViewModelProvider.notifier)
                    .handleIntent(MainScreenIntent.cardTapped(entry.id));
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
    );
  }

  Widget? _buildScreen(CalcModeEntry entry) {
    switch (entry.id) {
      case 'basic_calculator':
        return BasicCalculatorScreen(
          title: entry.title,
          icon: entry.icon,
          color: Colors.black.withValues(alpha: 0.2),
        );
      case 'exchange_rate':
        return CurrencyCalculatorScreen(
          title: entry.title,
          icon: entry.icon,
        );
      case 'unit_converter':
        return UnitConverterScreen(
          title: entry.title,
          icon: entry.icon,
        );
      case 'vat_calculator':
        return VatCalculatorScreen(
          title: entry.title,
          icon: entry.icon,
        );
      case 'age_calculator':
        return AgeCalculatorScreen(
          title: entry.title,
          icon: entry.icon,
        );
      case 'date_calculator':
        return const DateCalculatorScreen();
      default:
        return null;
    }
  }
}
