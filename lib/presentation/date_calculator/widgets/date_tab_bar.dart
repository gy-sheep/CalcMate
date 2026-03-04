import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../date_calculator_colors.dart';

class DateTabBar extends StatelessWidget {
  const DateTabBar({
    super.key,
    required this.pageOffset,
    required this.onTabSelected,
  });

  final double pageOffset;
  final ValueChanged<int> onTabSelected;

  static const _labels = ['기간 계산', '날짜 계산', 'D-Day'];
  static const _tabRowHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final tabWidth = constraints.maxWidth / _labels.length;
      final page = pageOffset.clamp(0.0, 2.0);
      final floor = page.floor().clamp(0, _labels.length - 2);
      final fraction = (page - floor).clamp(0.0, 1.0);

      // 왼쪽 엣지: easeIn, 오른쪽 엣지: easeOut → 탄성 스트레치 효과
      final leftFraction = Curves.easeInCubic.transform(fraction);
      final rightFraction = Curves.easeOutCubic.transform(fraction);

      const chipPad = 0.18;
      final bgLeft =
          (floor + leftFraction) * tabWidth + tabWidth * chipPad;
      final bgRight =
          (floor + rightFraction) * tabWidth + tabWidth * (1.0 - chipPad);
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
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: bgWidth,
                    decoration: BoxDecoration(
                      color: kDateAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kDateAccent.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kDateAccent.withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // 탭 레이블
                Row(
                  children: List.generate(_labels.length, (i) {
                    final distance =
                        (pageOffset - i).abs().clamp(0.0, 1.0);
                    final scale = 1.0 + (1.0 - distance) * 0.08;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTabSelected(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Text(
                              _labels[i],
                              style: TextStyle(
                                color: Color.lerp(
                                    kDateAccent, kDateTextTertiary, distance)!,
                                fontSize: AppTokens.fontSizeBody,
                                fontWeight: distance < 0.5
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
              Container(height: 1, color: kDateDivider),
              Positioned(
                left: bgLeft,
                child: Container(
                  width: bgWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: kDateAccent,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: kDateAccent.withValues(alpha: 0.6),
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
