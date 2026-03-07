import 'package:flutter/material.dart';

/// 수직 스크롤 영역 하단에 페이드 그라디언트를 표시하는 공통 위젯.
///
/// - 스크롤이 끝에 도달하면 페이드가 사라진다 (8px 임계값).
/// - [controller]를 생략하면 내부에서 자체 컨트롤러를 생성한다.
/// - PageView 안에서 페이지 전환 시 페이드를 초기화해야 한다면
///   [GlobalKey<ScrollFadeViewState>]를 사용해 [checkFade]를 호출한다.
///
/// ```dart
/// // 일반 사용
/// ScrollFadeView(
///   fadeColor: kBgEnd,
///   padding: const EdgeInsets.all(16),
///   child: Column(...),
/// )
///
/// // PageView 내 사용
/// final _key = GlobalKey<ScrollFadeViewState>();
/// // onPageChanged:
/// WidgetsBinding.instance.addPostFrameCallback((_) => _key.currentState?.checkFade());
/// ```
class ScrollFadeView extends StatefulWidget {
  const ScrollFadeView({
    super.key,
    required this.child,
    required this.fadeColor,
    this.padding,
    this.controller,
  });

  final Widget child;

  /// 페이드 그라디언트 불투명 끝 색상 (해당 화면 배경의 끝 색상).
  final Color fadeColor;

  /// [SingleChildScrollView]에 적용할 패딩.
  final EdgeInsetsGeometry? padding;

  /// 외부에서 컨트롤해야 하는 경우 전달. null이면 내부 생성.
  final ScrollController? controller;

  @override
  State<ScrollFadeView> createState() => ScrollFadeViewState();
}

class ScrollFadeViewState extends State<ScrollFadeView> {
  ScrollController? _ownController;
  bool _showBottomFade = false;

  ScrollController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownController = ScrollController();
    }
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkFade());
  }

  @override
  void didUpdateWidget(covariant ScrollFadeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      _controller.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => checkFade());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _ownController?.dispose();
    super.dispose();
  }

  void _onScroll() => checkFade();

  /// 외부에서 페이드 상태를 강제 갱신할 때 호출 (PageView 페이지 전환 등).
  void checkFade() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 8;
    final canScroll = pos.maxScrollExtent > 0;
    if (_showBottomFade != (canScroll && !atBottom)) {
      setState(() => _showBottomFade = canScroll && !atBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _controller,
          padding: widget.padding,
          child: widget.child,
        ),
        if (_showBottomFade)
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      widget.fadeColor.withValues(alpha: 0),
                      widget.fadeColor.withValues(alpha: 0.7),
                      widget.fadeColor,
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
