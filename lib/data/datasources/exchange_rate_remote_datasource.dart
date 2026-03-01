import 'package:cloud_firestore/cloud_firestore.dart';

import '../dto/exchange_rate_dto.dart';

class ExchangeRateRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const _collection = 'exchange_rates';
  static const _document = 'latest';

  ExchangeRateRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Firestore에서 최신 환율 데이터를 읽는다.
  /// Cloud Scheduler가 1시간마다 갱신을 보장하므로 클라이언트 TTL 체크 불필요.
  /// 문서가 없으면 null을 반환한다.
  Future<ExchangeRateDto?> fetchFromFirestore() async {
    final doc = await _firestore
        .collection(_collection)
        .doc(_document)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return ExchangeRateDto.fromJson(doc.data()!);
  }
}
