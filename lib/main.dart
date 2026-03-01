import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/providers.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
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
      // 라이트 테마 적용
      theme: AppTheme.lightTheme,
      // 다크 테마 적용
      darkTheme: AppTheme.darkTheme,
      // 시스템 테마 설정에 따라 자동 전환
      themeMode: ThemeMode.system,
      // 시작 화면을 우리가 만든 MainScreen으로 설정
      home: const MainScreen(),
      // 디버그 배너 숨기기
      debugShowCheckedModeBanner: false,
    );
  }
}
