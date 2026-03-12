import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import '../../l10n/app_localizations.dart';
import 'dutch_pay_colors.dart';
import 'dutch_pay_viewmodel.dart';
import 'widgets/dutch_pay_tab_bar.dart';
import 'widgets/equal_split_view.dart';
import 'widgets/individual_split_view.dart';

class DutchPayScreen extends ConsumerStatefulWidget {
  const DutchPayScreen({super.key});

  @override
  ConsumerState<DutchPayScreen> createState() => _DutchPayScreenState();
}

class _DutchPayScreenState extends ConsumerState<DutchPayScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() => _pageOffset = _pageController.page ?? _pageOffset);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _pageController.animateToPage(
      index,
      duration: durationAnimSlow,
      curve: Curves.easeInOut,
    );
    ref
        .read(dutchPayViewModelProvider.notifier)
        .handleIntent(DutchPayIntent.tabChanged(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kDutchTextPrimary, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.dutchPay_title,
          style: CmAppBar.titleText.copyWith(
            color: kDutchTextPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kDutchBg1, kDutchBg2, kDutchBg3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: DutchPayTabBar(
                  pageOffset: _pageOffset,
                  onTabSelected: _switchTab,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => ref
                      .read(dutchPayViewModelProvider.notifier)
                      .handleIntent(DutchPayIntent.tabChanged(i)),
                  children: const [
                    EqualSplitView(),
                    IndividualSplitView(),
                  ],
                ),
              ),
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}
