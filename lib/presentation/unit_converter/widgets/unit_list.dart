import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../domain/models/unit_converter_state.dart';
import '../../../domain/models/unit_definition.dart';
import '../unit_converter_colors.dart';

class UnitList extends StatefulWidget {
  final UnitCategory category;
  final UnitConverterState state;
  final bool isActive;
  final String formattedInput;
  final ValueChanged<String> onUnitTapped;
  final ScrollController scrollController;
  final Map<int, GlobalKey> itemKeys;

  const UnitList({
    super.key,
    required this.category,
    required this.state,
    required this.isActive,
    required this.formattedInput,
    required this.onUnitTapped,
    required this.scrollController,
    required this.itemKeys,
  });

  @override
  State<UnitList> createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {
  bool _showBottomFade = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
  }

  @override
  void didUpdateWidget(covariant UnitList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
    if (oldWidget.category != widget.category) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkFade());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() => _checkFade();

  void _checkFade() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final canScroll = pos.maxScrollExtent > 0;
    if (_showBottomFade != (canScroll && !atBottom)) {
      setState(() => _showBottomFade = canScroll && !atBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.category.units;

    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            final isActiveUnit = unit.code == widget.state.activeUnitCode;
            final key =
                widget.itemKeys.putIfAbsent(index, () => GlobalKey());

            // 활성 행: 포맷팅된 입력값 표시, 비활성 행: 변환 결과 표시
            final displayValue = (widget.isActive && isActiveUnit)
                ? widget.formattedInput
                : (widget.state.convertedValues[unit.code] ?? '0');

            return GestureDetector(
              key: key,
              onTap: () => widget.onUnitTapped(unit.code),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: (widget.isActive && isActiveUnit)
                      ? kUnitActiveRowColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                  border: (widget.isActive && isActiveUnit)
                      ? Border.all(
                          color: kUnitChipSelectedColor.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        unit.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (widget.isActive && isActiveUnit)
                              ? kUnitChipSelectedColor
                              : Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        unit.label,
                        style: TextStyle(
                          color: (widget.isActive && isActiveUnit)
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      displayValue,
                      style: TextStyle(
                        color: (widget.isActive && isActiveUnit)
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 18,
                        fontWeight: (widget.isActive && isActiveUnit)
                            ? FontWeight.w500
                            : FontWeight.w300,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // 하단 페이드 그라디언트
        if (_showBottomFade)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      kUnitGradientBottom.withValues(alpha: 0),
                      kUnitGradientBottom.withValues(alpha: 0.7),
                      kUnitGradientBottom,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
