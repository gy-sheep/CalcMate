import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_config.dart';
import '../../domain/models/tax_rates.dart';

/// Firestore에서 세율 데이터를 읽는다.
class TaxRatesRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaxRatesRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<TaxRates?> fetchFromFirestore() async {
    final doc = await _firestore
        .collection(FirebaseConfig.taxRatesCollection)
        .doc(FirebaseConfig.taxRatesDocument)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return TaxRates.fromJson(doc.data()!);
  }
}
