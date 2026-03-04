import 'package:flutter/material.dart';

/// 왼쪽 가장자리 스와이프로 뒤로가기를 지원하는 래퍼 위젯.
/// CupertinoRouteTransitionMixin을 사용하지 않는 라우트(OpenContainer 등)에서
/// iOS 스타일 엣지 스와이프 뒤로가기를 제공한다.
class EdgeSwipeBack extends StatefulWidget {
  final Widget child;

  const EdgeSwipeBack({super.key, required this.child});

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  double _dragExtent = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 20,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              _dragExtent += details.delta.dx;
            },
            onHorizontalDragEnd: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (_dragExtent > screenWidth * 0.25 ||
                  (details.primaryVelocity ?? 0) > 300) {
                Navigator.of(context).pop();
              }
              _dragExtent = 0;
            },
            onHorizontalDragCancel: () {
              _dragExtent = 0;
            },
          ),
        ),
      ],
    );
  }
}
