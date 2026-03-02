/// 앱 전역 에러 메시지 상수
abstract final class ErrorMessages {
  // 환율
  static const exchangeRateLoadFailed = '환율 정보를 불러올 수 없습니다';
  static const exchangeRateUsingFallback = '임시 환율을 사용 중입니다';

  // 네트워크
  static const networkTimeout = '네트워크 연결 시간이 초과되었습니다.';
  static const networkUnavailable = '네트워크에 연결할 수 없습니다.';
  static String serverError(int? statusCode) =>
      '서버 오류가 발생했습니다. ($statusCode)';
  static const unknownError = '알 수 없는 오류가 발생했습니다.';
}
