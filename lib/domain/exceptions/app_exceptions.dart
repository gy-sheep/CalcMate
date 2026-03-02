/// 앱 공통 커스텀 예외 계층
sealed class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

/// 네트워크 관련 예외 (타임아웃, 연결 실패 등)
class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

/// 로컬 캐시 관련 예외 (파싱 실패, 저장 실패 등)
class CacheException extends AppException {
  const CacheException(super.message, [super.cause]);
}

/// 요청한 데이터를 찾을 수 없을 때
class DataNotFoundException extends AppException {
  const DataNotFoundException(super.message, [super.cause]);
}
