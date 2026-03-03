/// 기본 세율 (매핑 테이블에 없는 국가용 fallback).
const int kDefaultTaxRate = 10;

/// 국가 코드별 표준 세율 (%).
const Map<String, int> kCountryTaxRates = {
  'KR': 10, // 대한민국
  'JP': 10, // 일본
  'GB': 20, // 영국
  'DE': 19, // 독일
  'FR': 20, // 프랑스
  'IT': 22, // 이탈리아
  'ES': 21, // 스페인
  'AU': 10, // 호주
  'CA': 5, // 캐나다
  'NZ': 15, // 뉴질랜드
  'SG': 9, // 싱가포르
  'IN': 18, // 인도
  'CN': 13, // 중국
  'BR': 17, // 브라질
  'US': 10, // 미국 (주마다 상이, fallback)
};

/// 국가 코드에 해당하는 기본 세율을 반환한다.
/// 매핑에 없거나 null이면 [kDefaultTaxRate]를 반환한다.
int getDefaultTaxRateForCountry(String? countryCode) {
  if (countryCode == null) return kDefaultTaxRate;
  return kCountryTaxRates[countryCode] ?? kDefaultTaxRate;
}
