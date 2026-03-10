import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';

/// 펄 로즈 → 라벤더 → 펄 로즈 그라데이션 테두리 카드 래퍼.
/// [clip] = true 이면 내부 콘텐츠를 같은 radius로 클리핑한다.
class DutchCard extends StatelessWidget {
  const DutchCard({
    super.key,
    required this.child,
    this.radius = radiusCard,
    this.color,
    this.innerGradient,
    this.clip = false,
  });

  final Widget child;
  final double radius;

  /// 내부 배경색 (innerGradient와 함께 쓰지 않는다)
  final Color? color;

  /// 내부 배경 그라데이션 (color와 함께 쓰지 않는다)
  final Gradient? innerGradient;

  /// ListView 등 overflow 가 발생하는 경우 true
  final bool clip;

  static const _shimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFCCE2), // 펄 로즈
      Color(0xFFCEB8F4), // 라벤더 심머
      Color(0xFFF4BCD8), // 딥 로즈 펄
    ],
  );

  @override
  Widget build(BuildContext context) {
    final innerRadius = radius - 1.5;
    Widget inner;

    if (clip) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: ColoredBox(
          color: color ?? Colors.transparent,
          child: child,
        ),
      );
    } else {
      inner = DecoratedBox(
        decoration: BoxDecoration(
          color: innerGradient == null ? color : null,
          gradient: innerGradient,
          borderRadius: BorderRadius.circular(innerRadius),
        ),
        child: child,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _shimmer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: inner,
      ),
    );
  }
}
