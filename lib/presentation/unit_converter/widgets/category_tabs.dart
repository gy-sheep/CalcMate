import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../core/constants/unit_definitions.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../unit_converter_colors.dart';

class CategoryTabs extends StatefulWidget {
  final TabController tabController;
  final Animation<double> tabAnimation;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryTabs({
    super.key,
    required this.tabController,
    required this.tabAnimation,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final _chipKeys = <int, GlobalKey>{};
  final _rowKey = GlobalKey();
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 레이아웃 이후 리빌드하여 하이라이트 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _measured = true);
    });
  }

  @override
  void didUpdateWidget(covariant CategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollToSelected(widget.selectedIndex);
    }
  }

  void _scrollToSelected(int index) {
    final key = _chipKeys[index];
    if (key == null || key.currentContext == null) return;
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: 0.3,
    );
  }

  /// 칩의 위치/크기를 Row 기준으로 측정
  Rect? _chipRect(int index) {
    final key = _chipKeys[index];
    if (key == null || key.currentContext == null) return null;
    final box = key.currentContext!.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    if (_rowKey.currentContext == null) return null;
    final rowBox = _rowKey.currentContext!.findRenderObject() as RenderBox?;
    if (rowBox == null || !rowBox.hasSize) return null;

    final offset = box.localToGlobal(Offset.zero, ancestor: rowBox);
    return offset & box.size;
  }

  /// tabAnimation.value 기준 하이라이트 Rect 보간 (탄성 스트레치)
  Rect? _interpolatedRect() {
    if (!_measured) return null;
    final animValue = widget.tabAnimation.value;
    final maxIdx = unitCategories.length - 1;
    final floor = animValue.floor().clamp(0, maxIdx);
    final ceil = animValue.ceil().clamp(0, maxIdx);

    final rectA = _chipRect(floor);
    final rectB = _chipRect(ceil);
    if (rectA == null) return rectB;
    if (rectB == null) return rectA;

    final t = (animValue - floor).clamp(0.0, 1.0);
    final leftT = Curves.easeInCubic.transform(t);
    final rightT = Curves.easeOutCubic.transform(t);

    final left = lerpDouble(rectA.left, rectB.left, leftT)!;
    final top = lerpDouble(rectA.top, rectB.top, t)!;
    final right = lerpDouble(rectA.right, rectB.right, rightT)!;
    final bottom = lerpDouble(rectA.bottom, rectB.bottom, t)!;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: AnimatedBuilder(
        animation: widget.tabAnimation,
        builder: (context, _) {
          final rect = _interpolatedRect();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.paddingScreenH),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── 슬라이딩 하이라이트 (가장 뒤) ──
                if (rect != null)
                  Positioned(
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: kUnitChipSelectedColor,
                        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
                        border: Border.all(
                          color: kUnitChipSelectedColor.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kUnitChipSelectedColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── 칩 Row (비-Positioned → Stack 크기 결정) ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    key: _rowKey,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(unitCategories.length, _buildChip),
                  ),
                ),

                // ── 하단 divider ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: Container(height: 0.5, color: kUnitDivider),
                ),

                // ── 슬라이딩 언더라인 ──
                if (rect != null)
                  Positioned(
                    left: rect.left + 4,
                    bottom: 1,
                    width: rect.width - 8,
                    height: 2.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: kUnitChipSelectedColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: kUnitChipSelectedColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(int index) {
    final category = unitCategories[index];
    final key = _chipKeys.putIfAbsent(index, () => GlobalKey());

    // 근접도 (1.0 = 선택, 0.0 = 비선택)
    final distance =
        (widget.tabAnimation.value - index).abs().clamp(0.0, 1.0);
    final proximity = 1.0 - distance;

    final color = Color.lerp(Colors.white60, Colors.white, proximity)!;
    final fontWeight =
        proximity > 0.5 ? FontWeight.w600 : FontWeight.w400;
    final scale = 1.0 + proximity * 0.08;

    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
      child: GestureDetector(
        key: key,
        onTap: () => widget.onSelected(index),
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: AppTokens.paddingChip,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusChip),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: AppTokens.sizeIconXSmall, color: color),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: AppTokens.textStyleChip.copyWith(
                    color: color,
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
