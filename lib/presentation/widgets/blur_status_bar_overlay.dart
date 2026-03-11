import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

/// 스크롤 시 상태바 + AppBar 영역에 블러 + 그라디언트 오버레이를 표시하는 위젯.
///
/// [Stack] 내부에 배치하며, [isVisible]이 true일 때 250ms 페이드인된다.
/// [backgroundColor]로 오버레이 색상을 지정한다 (보통 배경색과 동일).
class BlurStatusBarOverlay extends StatelessWidget {
  final bool isVisible;
  final Color backgroundColor;

  const BlurStatusBarOverlay({
    super.key,
    required this.isVisible,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final overlayHeight = statusBarHeight + kToolbarHeight + 28.0;
    final solidFraction = (statusBarHeight + kToolbarHeight) / overlayHeight;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: overlayHeight,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: durationAnimMedium,
        child: IgnorePointer(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, solidFraction, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backgroundColor.withValues(alpha: 0.75),
                        backgroundColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
