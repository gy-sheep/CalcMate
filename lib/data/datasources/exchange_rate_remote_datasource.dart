import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../dto/exchange_rate_dto.dart';

class ExchangeRateRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Dio _dio;

  static const _collection = 'exchange_rates';
  static const _document = 'latest';
  static const _ttlMs = 3600000; // 1시간
  static const _functionUrl =
      'https://asia-northeast3-calcmate-353ed.cloudfunctions.net/refreshExchangeRates';

  ExchangeRateRemoteDataSource({
    required FirebaseFirestore firestore,
    required Dio dio,
  })  : _firestore = firestore,
        _dio = dio;

  /// Firestore에서 환율 데이터를 읽는다.
  /// TTL이 만료되었으면 null을 반환한다.
  Future<ExchangeRateDto?> fetchFromFirestore() async {
    final doc = await _firestore
        .collection(_collection)
        .doc(_document)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final timestamp = data['timestamp'] as int? ?? 0;
    final isExpired =
        (DateTime.now().millisecondsSinceEpoch - timestamp) >= _ttlMs;

    if (isExpired) return null;

    return ExchangeRateDto.fromJson(data);
  }

  /// Firebase Function을 호출하여 환율을 갱신하고 반환한다.
  Future<ExchangeRateDto> triggerRefresh() async {
    final response = await _dio.get(_functionUrl);
    return ExchangeRateDto.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }
}
