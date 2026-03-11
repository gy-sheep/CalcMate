import 'package:flutter/material.dart';
import '../../core/theme/app_design_tokens.dart';
import '../main/main_screen.dart';

const Color _kBackground = Color(0xFF0F0F19);
const Color _kTagline = Color(0xFF9090A0);

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
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    // shimmer: 무한 반복
    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _shimmer = Tween<double>(begin: -0.4, end: 1.4).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    // 슬로건 페이드 + 화면 전환
    _splashCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
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
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, anim, __, child) =>
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
      body: Center(
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
                        // Color(0xFFD0D0D0),
                        Colors.white,
                        Color(0xFFB0B0B0),
                        // Color(0xFFD0D0D0),
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
            // 앱 이름
            Text(
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
            const SizedBox(height: 6),
            // 슬로건 (페이드인)
            FadeTransition(
              opacity: _taglineFade,
              child: SlideTransition(
                position: _taglineSlide,
                child: Text(
                '생활 속 모든 계산',
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
  }
}
