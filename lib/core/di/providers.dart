import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/exchange_rate_local_datasource.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/usecases/get_exchange_rate_usecase.dart';
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

/// SharedPreferences 인스턴스 (main에서 override 필요)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

/// Firestore 인스턴스
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Remote DataSource
final exchangeRateRemoteDataSourceProvider =
    Provider<ExchangeRateRemoteDataSource>((ref) {
  return ExchangeRateRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

/// Local DataSource
final exchangeRateLocalDataSourceProvider =
    Provider<ExchangeRateLocalDataSource>((ref) {
  return ExchangeRateLocalDataSource(ref.read(sharedPreferencesProvider));
});

/// Repository
final exchangeRateRepositoryProvider =
    Provider<ExchangeRateRepository>((ref) {
  return ExchangeRateRepositoryImpl(
    remote: ref.read(exchangeRateRemoteDataSourceProvider),
    local: ref.read(exchangeRateLocalDataSourceProvider),
  );
});

/// UseCase
final getExchangeRateUseCaseProvider =
    Provider<GetExchangeRateUseCase>((ref) {
  return GetExchangeRateUseCase(ref.read(exchangeRateRepositoryProvider));
});
