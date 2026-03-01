import 'package:flutter/material.dart';

/// 계산기 화면 전환에 사용하는 공통 라우트.
/// [transitionsBuilder]를 생략하면 기본 FadeTransition이 적용됩니다.
class CalcPageRoute<T> extends PageRouteBuilder<T> {
  CalcPageRoute({
    required WidgetBuilder builder,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 400),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, _, __) => builder(context),
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          transitionsBuilder: transitionsBuilder ?? _defaultFade,
        );

  static Widget _defaultFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}
