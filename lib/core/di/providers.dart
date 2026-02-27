import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/error_interceptor.dart';

/// 앱 전체에서 공유하는 Dio 인스턴스
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.addAll([
    // 디버그 모드에서만 요청/응답 로그 출력
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ErrorInterceptor(),
  ]);

  return dio;
});
