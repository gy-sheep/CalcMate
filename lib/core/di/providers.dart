import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/exchange_rate_local_datasource.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/datasources/tax_rates_local_datasource.dart';
import '../../data/datasources/tax_rates_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/repositories/tax_rates_repository_impl.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/repositories/tax_rates_repository.dart';
import '../../domain/usecases/get_exchange_rate_usecase.dart';
import '../../domain/usecases/get_tax_rates_usecase.dart';
import '../network/error_interceptor.dart';
import '../widgets/interstitial_ad_manager.dart';

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

/// 전면 광고 매니저 (앱 전체 싱글턴)
final interstitialAdManagerProvider = Provider<InterstitialAdManager>((ref) {
  final manager = InterstitialAdManager();
  ref.onDispose(manager.dispose);
  return manager;
});

/// UseCase
final getExchangeRateUseCaseProvider =
    Provider<GetExchangeRateUseCase>((ref) {
  return GetExchangeRateUseCase(ref.read(exchangeRateRepositoryProvider));
});

// ── 세율 (TaxRates) ────────────────────────────────────────────────────────

/// Remote DataSource (세율)
final taxRatesRemoteDataSourceProvider =
    Provider<TaxRatesRemoteDataSource>((ref) {
  return TaxRatesRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

/// Local DataSource (세율)
final taxRatesLocalDataSourceProvider =
    Provider<TaxRatesLocalDataSource>((ref) {
  return TaxRatesLocalDataSource(ref.read(sharedPreferencesProvider));
});

/// Repository (세율)
final taxRatesRepositoryProvider =
    Provider<TaxRatesRepository>((ref) {
  return TaxRatesRepositoryImpl(
    remote: ref.read(taxRatesRemoteDataSourceProvider),
    local: ref.read(taxRatesLocalDataSourceProvider),
  );
});

/// UseCase (세율)
final getTaxRatesUseCaseProvider =
    Provider<GetTaxRatesUseCase>((ref) {
  return GetTaxRatesUseCase(ref.read(taxRatesRepositoryProvider));
});
