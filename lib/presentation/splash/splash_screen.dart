import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../main/main_screen.dart';

const Color _kBackground = Color(0xFF0F0F19);
const Color _kTagline = Color(0xFF9090A0);

/// 아이콘 아래 텍스트 영역 전체 높이 (SizedBox 14 + 앱이름 ~36 + SizedBox 6 + 슬로건 ~20)
const double _kTextBlockHeight = 76.0;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final AnimationController _splashCtrl;
  late final Animation<double> _shimmer;
  late final Animation<double> _iconShift;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _shimmer = Tween<double>(begin: -0.4, end: 1.4).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    _splashCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    // Android: 아이콘이 정중앙에서 시작 → 위로 이동 (네이티브 스플래시와 동일한 위치)
    // iOS: 네이티브 스플래시에 아이콘이 없으므로 이동 없이 시작
    _iconShift = Tween<double>(
      begin: Platform.isAndroid ? _kTextBlockHeight / 2 : 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _splashCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashCtrl,
        curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _splashCtrl,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _splashCtrl,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    _splashCtrl.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), _goToMain);
    });
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _splashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: AnimatedBuilder(
        animation: _splashCtrl,
        builder: (context, _) {
          return Center(
            child: Transform.translate(
              offset: Offset(0, _iconShift.value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 앱 아이콘 (shimmer)
                  AnimatedBuilder(
                    animation: _shimmer,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          final center = _shimmer.value;
                          return LinearGradient(
                            colors: const [
                              Color(0xFFB0B0B0),
                              Colors.white,
                              Color(0xFFB0B0B0),
                            ],
                            stops: [
                              (center - 0.4).clamp(0.0, 1.0),
                              center.clamp(0.0, 1.0),
                              (center + 0.4).clamp(0.0, 1.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // 앱 이름 (페이드인)
                  FadeTransition(
                    opacity: _titleFade,
                    child: Text(
                      'CalcMate',
                      style: CmAppBar.titleText.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 슬로건 (페이드인)
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Text(
                        AppLocalizations.of(context).splash_tagline,
                        style: CmAppBar.titleText.copyWith(
                          color: _kTagline,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
