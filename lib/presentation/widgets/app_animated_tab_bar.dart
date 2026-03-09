import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

/// 스트레치 애니메이션 탭바 공통 위젯.
///
/// 탭 간 이동 시 배경 칩과 언더라인이 탄성 있게 늘어나는 효과를 제공한다.
/// [DutchPayTabBar], [DateTabBar] 등 계산기별 탭바는 이 위젯을 래핑한다.
class AppAnimatedTabBar extends StatelessWidget {
  const AppAnimatedTabBar({
    super.key,
    required this.labels,
    required this.pageOffset,
    required this.onTabSelected,
    required this.accentColor,
    required this.dividerColor,
    required this.inactiveColor,
  });

  final List<String> labels;
  final double pageOffset;
  final ValueChanged<int> onTabSelected;
  final Color accentColor;
  final Color dividerColor;
  final Color inactiveColor;

  static const _tabRowHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final tabWidth = constraints.maxWidth / labels.length;
      final maxPage = (labels.length - 1).toDouble();
      final page = pageOffset.clamp(0.0, maxPage);
      final floor = page.floor().clamp(0, labels.length - 2);
      final fraction = (page - floor).clamp(0.0, 1.0);

      final leftFraction = Curves.easeInCubic.transform(fraction);
      final rightFraction = Curves.easeOutCubic.transform(fraction);

      const chipPad = 0.18;
      final bgLeft = (floor + leftFraction) * tabWidth + tabWidth * chipPad;
      final bgRight = (floor + rightFraction) * tabWidth + tabWidth * (1.0 - chipPad);
      final bgWidth = (bgRight - bgLeft).clamp(0.0, constraints.maxWidth);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _tabRowHeight,
            child: Stack(
              children: [
                // 스트레치 배경 칩
                Positioned(
                  left: bgLeft,
                  top: 6,
                  bottom: 6,
                  child: Container(
                    width: bgWidth,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // 탭 레이블
                Row(
                  children: List.generate(labels.length * 2 - 1, (idx) {
                    // 홀수 인덱스 = 구분선
                    if (idx.isOdd) {
                      return Container(
                        width: 1,
                        height: 14,
                        color: dividerColor,
                      );
                    }
                    final i = idx ~/ 2;
                    final distance = (pageOffset - i).abs().clamp(0.0, 1.0);
                    final scale = 1.0 + (1.0 - distance) * 0.08;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTabSelected(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: 1.0 - distance * 0.45,
                              child: Text(
                                labels[i],
                                style: AppTokens.textStyleChip.copyWith(
                                  color: Color.lerp(accentColor, inactiveColor, distance),
                                  fontWeight: distance < 0.5 ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // 스트레치 언더라인
          Stack(
            children: [
              Container(height: 1, color: dividerColor),
              Positioned(
                left: bgLeft,
                child: Container(
                  width: bgWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
