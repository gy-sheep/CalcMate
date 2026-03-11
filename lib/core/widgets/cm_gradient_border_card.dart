import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';

/// 그라데이션 테두리 카드 공통 래퍼.
///
/// [borderColors] 로 테두리 그라데이션 색상을 주입한다.
/// [begin] / [end] 를 생략하면 topLeft → bottomRight 방향이 기본값이다.
/// [clip] = true 이면 내부 콘텐츠를 같은 radius로 클리핑한다.
class CmGradientBorderCard extends StatelessWidget {
  const CmGradientBorderCard({
    super.key,
    required this.child,
    required this.borderColors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.radius = radiusCard,
    this.borderWidth = 1.5,
    this.color,
    this.innerGradient,
    this.clip = false,
  });

  final Widget child;

  /// 테두리 그라데이션 색상 목록 (2개 이상)
  final List<Color> borderColors;

  /// 그라데이션 시작 방향 (기본: topLeft)
  final AlignmentGeometry begin;

  /// 그라데이션 끝 방향 (기본: bottomRight)
  final AlignmentGeometry end;

  final double radius;
  final double borderWidth;

  /// 내부 배경색 (innerGradient와 함께 쓰지 않는다)
  final Color? color;

  /// 내부 배경 그라데이션 (color와 함께 쓰지 않는다)
  final Gradient? innerGradient;

  /// ListView 등 overflow 가 발생하는 경우 true
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final innerRadius = radius - borderWidth;

    final Widget inner;
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
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: borderColors,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: inner,
      ),
    );
  }
}
