import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';

// ── ToastType ──

enum ToastType { info, success, error }

// ── 전역 오버레이 관리 (1개만 표시) ──

OverlayEntry? _currentEntry;

/// 화면 상단에 디자인된 토스트 메시지를 표시한다.
///
/// [type] 에 따라 아이콘·그라디언트가 달라진다.
/// 기존 토스트가 있으면 즉시 교체한다.
void showAppToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
}) {
  // 기존 토스트 즉시 제거
  _dismissCurrent();

  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _ToastOverlayWidget(
      message: message,
      type: type,
      brightness: Theme.of(context).brightness,
      onDismissed: () {
        if (entry.mounted) entry.remove();
        if (_currentEntry == entry) {
          _currentEntry = null;
        }
      },
    ),
  );

  _currentEntry = entry;
  overlay.insert(entry);
}

void _dismissCurrent() {
  // 애니메이션 없이 즉시 제거 (교체 시)
  if (_currentEntry?.mounted ?? false) {
    _currentEntry!.remove();
  }
  _currentEntry = null;
}

// ── 토스트 위젯 ──

class _ToastOverlayWidget extends StatefulWidget {
  const _ToastOverlayWidget({
    required this.message,
    required this.type,
    required this.brightness,
    required this.onDismissed,
  });

  final String message;
  final ToastType type;
  final Brightness brightness;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: durationAnimSlow, // 300ms 입장
      reverseDuration: durationAnimMedium, // 250ms 퇴장
    );

    _slideAnimation = Tween<Offset>(
      begin: CmToast.slideBeginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    // 글로벌 dismiss 콜백 등록
    _controller.forward();

    // 자동 소멸
    Future.delayed(CmToast.displayDuration, () {
      if (mounted && !_dismissed) _dismiss();
    });
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _ToastColors.of(widget.type, widget.brightness);
    final topPadding = MediaQuery.of(context).viewPadding.top + 8;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              // 위로 스와이프 시 즉시 퇴장
              if (details.velocity.pixelsPerSecond.dy < -100) {
                _dismiss();
              }
            },
            child: Padding(
              padding: CmToast.margin,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CmToast.radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: CmToast.blurSigma,
                    sigmaY: CmToast.blurSigma,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors.gradient,
                      ),
                      borderRadius: BorderRadius.circular(CmToast.radius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: CmToast.borderAlpha),
                      ),
                    ),
                    child: Padding(
                      padding: CmToast.padding,
                      child: Row(
                        children: [
                          Icon(
                            colors.icon,
                            size: CmToast.iconSize,
                            color: Colors.white,
                          ),
                          SizedBox(width: CmToast.iconTextSpacing),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: CmToast.text.copyWith(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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

// ── 타입·brightness별 색상 매핑 ──

class _ToastColors {
  const _ToastColors({required this.gradient, required this.icon});

  final List<Color> gradient;
  final IconData icon;

  static _ToastColors of(ToastType type, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (type) {
      case ToastType.info:
        return _ToastColors(
          gradient: isLight
              ? [const Color(0xBF424242), const Color(0x99616161)]
              : [const Color(0xCC303030), const Color(0xA6424242)],
          icon: Icons.info_outline_rounded,
        );
      case ToastType.success:
        return _ToastColors(
          gradient: isLight
              ? [const Color(0xBF2E7D32), const Color(0x99388E3C)]
              : [const Color(0xCC1B5E20), const Color(0xA62E7D32)],
          icon: Icons.check_circle_outline_rounded,
        );
      case ToastType.error:
        return _ToastColors(
          gradient: isLight
              ? [const Color(0xBFC62828), const Color(0x99D32F2F)]
              : [const Color(0xCCB71C1C), const Color(0xA6C62828)],
          icon: Icons.cancel_outlined,
        );
    }
  }
}
