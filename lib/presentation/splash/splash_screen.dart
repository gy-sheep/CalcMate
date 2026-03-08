import 'package:flutter/material.dart';
import '../main/main_screen.dart';

const Color _kBackground = Color(0xFF0D0D14);
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

  @override
  void initState() {
    super.initState();

    // shimmer: 무한 반복
    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    _shimmer = Tween<double>(begin: -0.4, end: 1.4).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
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
            // 앱 아이콘 (고정)
            Image.asset(
              'assets/images/app_icon.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 32),
            // 앱 이름 (shimmer)
            AnimatedBuilder(
              animation: _shimmer,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    final center = _shimmer.value;
                    return LinearGradient(
                      colors: const [
                        Color(0xFFAAAAAA),
                        Colors.white,
                        Color(0xFFAAAAAA),
                      ],
                      stops: [
                        (center - 0.35).clamp(0.0, 1.0),
                        center.clamp(0.0, 1.0),
                        (center + 0.35).clamp(0.0, 1.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  child: child,
                );
              },
              child: const Text(
                'CalcMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 슬로건 (페이드인)
            FadeTransition(
              opacity: _taglineFade,
              child: const Text(
                '생활 속 모든 계산',
                style: TextStyle(
                  color: _kTagline,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
