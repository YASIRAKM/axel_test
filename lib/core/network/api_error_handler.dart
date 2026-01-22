import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class ApiErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout - check your network';
        case DioExceptionType.sendTimeout:
          return 'Request timeout';
        case DioExceptionType.receiveTimeout:
          return 'Server response timeout';
        case DioExceptionType.badCertificate:
          return 'Bad certificate';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode ?? "Unknown"}';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        case DioExceptionType.connectionError:
          return 'No internet connection';
        case DioExceptionType.unknown:
          return 'Network error: ${error.error}';
      }
    } else {
      return 'Unexpected error occurred';
    }
  }

  static void handle(Object error) {
    throw ServerException(getErrorMessage(error));
  }
}
