import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 계산기 화면 전환에 사용하는 공통 라우트.
/// [transitionsBuilder]를 생략하면 기본 FadeTransition이 적용됩니다.
/// iOS 엣지 스와이프 뒤로가기를 지원합니다.
class CalcPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  final WidgetBuilder _builder;
  final RouteTransitionsBuilder? _customTransition;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool maintainState = true;

  @override
  String? get title => null;

  CalcPageRoute({
    required WidgetBuilder builder,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  })  : _builder = builder,
        _customTransition = transitionsBuilder,
        transitionDuration =
            transitionDuration ?? const Duration(milliseconds: 400),
        reverseTransitionDuration =
            reverseTransitionDuration ?? const Duration(milliseconds: 300);

  @override
  Widget buildContent(BuildContext context) => _builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // 커스텀 전환 효과 적용 (기본: Fade)
    final transition = _customTransition != null
        ? _customTransition!(context, animation, secondaryAnimation, child)
        : FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );

    // iOS 스와이프 백 제스처 래핑
    return CupertinoRouteTransitionMixin.buildPageTransitions<T>(
      this,
      context,
      animation,
      secondaryAnimation,
      transition,
    );
  }
}
