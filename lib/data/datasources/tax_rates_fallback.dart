import '../../domain/models/tax_rates.dart';

/// 2026년 기준 오프라인 폴백 상수.
/// Firestore·캐시 모두 실패 시 사용.
const kFallbackTaxRates = TaxRates(
  nationalPensionRate: 0.0475,
  nationalPensionMin: 390000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03595,
  longTermCareRate: 0.1314,
  employmentInsuranceRate: 0.009,
  basedYear: 2026,
);
