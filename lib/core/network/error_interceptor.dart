import 'package:dio/dio.dart';

/// API 오류를 공통으로 처리하는 인터셉터
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        '네트워크 연결 시간이 초과되었습니다.',
      DioExceptionType.connectionError => '네트워크에 연결할 수 없습니다.',
      DioExceptionType.badResponse => '서버 오류가 발생했습니다. (${err.response?.statusCode})',
      _ => '알 수 없는 오류가 발생했습니다.',
    };

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: err.error,
        type: err.type,
        response: err.response,
        message: message,
      ),
    );
  }
}
