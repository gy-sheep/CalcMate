import 'package:dio/dio.dart';

import '../constants/error_messages.dart';

/// API 오류를 공통으로 처리하는 인터셉터
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        ErrorMessages.networkTimeout,
      DioExceptionType.connectionError => ErrorMessages.networkUnavailable,
      DioExceptionType.badResponse =>
        ErrorMessages.serverError(err.response?.statusCode),
      _ => ErrorMessages.unknownError,
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
