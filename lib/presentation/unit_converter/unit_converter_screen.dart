import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/unit_definitions.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/utils/app_toast.dart';
import '../../core/widgets/ad_banner_placeholder.dart';
import 'unit_converter_colors.dart';
import 'unit_converter_viewmodel.dart';
import 'widgets/category_tabs.dart';
import 'widgets/unit_list.dart';
import 'widgets/unit_number_pad.dart';

// ──────────────────────────────────────────
// 메인 화면
// ──────────────────────────────────────────
class UnitConverterScreen extends ConsumerStatefulWidget {
  final String title;

  const UnitConverterScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<UnitConverterScreen> createState() =>
      _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollControllers = <int, ScrollController>{};
  final _itemKeys = <int, Map<int, GlobalKey>>{};
  int _lastReportedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: unitCategories.length,
      vsync: this,
    );
    _tabController.animation!.addListener(_onTabAnimation);
  }

  @override
  void dispose() {
    _tabController.animation!.removeListener(_onTabAnimation);
    _tabController.dispose();
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabAnimation() {
    // 칩 탭 등 프로그래밍 방식 animateTo 중에는 무시 (ViewModel이 이미 업데이트됨)
    if (_tabController.indexIsChanging) return;

    final rounded = _tabController.animation!.value.round();
    if (rounded != _lastReportedIndex) {
      _lastReportedIndex = rounded;
      final vm = ref.read(unitConverterViewModelProvider.notifier);
      vm.handleIntent(UnitConverterIntent.categorySelected(rounded));
    }
  }

  ScrollController _scrollControllerFor(int categoryIndex) {
    return _scrollControllers.putIfAbsent(
      categoryIndex,
      () => ScrollController(),
    );
  }

  Map<int, GlobalKey> _itemKeysFor(int categoryIndex) {
    return _itemKeys.putIfAbsent(categoryIndex, () => {});
  }

  void _ensureActiveVisible(int categoryIndex, int unitIndex, int direction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keys = _itemKeysFor(categoryIndex);
      final key = keys[unitIndex];
      if (key == null || key.currentContext == null) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: durationAnimDefault,
        curve: Curves.easeOut,
        alignmentPolicy: direction > 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConverterViewModelProvider);
    final vm = ref.read(unitConverterViewModelProvider.notifier);

    // 카테고리 인덱스 변경 시 탭 컨트롤러와 동기화
    ref.listen(
      unitConverterViewModelProvider.select((s) => s.selectedCategoryIndex),
      (prev, next) {
        _lastReportedIndex = next;
        if (_tabController.index != next) {
          _tabController.animateTo(next);
        }
      },
    );

    // 토스트 메시지
    ref.listen(
      unitConverterViewModelProvider.select((s) => s.toastMessage),
      (_, message) {
        if (message != null) {
          showAppToast(context, message);
          vm.clearToast();
        }
      },
    );

    return Scaffold(
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
            colors: [kUnitBg1, kUnitBg2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CategoryTabs(
                tabController: _tabController,
                tabAnimation: _tabController.animation!,
                selectedIndex: state.selectedCategoryIndex,
                onSelected: (index) => vm.handleIntent(
                  UnitConverterIntent.categorySelected(index),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(unitCategories.length, (catIndex) {
                    return UnitList(
                      category: unitCategories[catIndex],
                      state: state,
                      isActive: catIndex == state.selectedCategoryIndex,
                      formattedInput: vm.formattedInput,
                      onUnitTapped: (code) => vm.handleIntent(
                        UnitConverterIntent.unitTapped(code),
                      ),
                      scrollController: _scrollControllerFor(catIndex),
                      itemKeys: _itemKeysFor(catIndex),
                    );
                  }),
                ),
              ),
              const Divider(color: kUnitDivider, thickness: 0.5, height: 1),
              UnitNumberPad(
                isTemperature: unitCategories[state.selectedCategoryIndex].code == 'temperature',
                onKey: (key) => vm.handleIntent(
                  UnitConverterIntent.keyTapped(key),
                ),
                onArrow: (dir) {
                  vm.handleIntent(UnitConverterIntent.arrowTapped(dir));
                  // 자동 스크롤
                  final category = unitCategories[state.selectedCategoryIndex];
                  final currentIdx = category.units
                      .indexWhere((u) => u.code == state.activeUnitCode);
                  final newIdx = currentIdx + dir;
                  if (newIdx >= 0 && newIdx < category.units.length) {
                    _ensureActiveVisible(
                      state.selectedCategoryIndex,
                      newIdx,
                      dir,
                    );
                  }
                },
              ),
              const AdBannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

}
