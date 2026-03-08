import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/providers.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/splash/splash_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();

  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CalcmateApp(),
    ),
  );
}

class CalcmateApp extends StatelessWidget {
  const CalcmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalcMate',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko'), Locale('en')],
      localeResolutionCallback: (locale, supportedLocales) => locale,
      // 라이트 테마 적용
      theme: AppTheme.lightTheme,
      // 다크 테마 적용
      darkTheme: AppTheme.darkTheme,
      // 시스템 테마 설정에 따라 자동 전환
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      // 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,
    );
  }
}
