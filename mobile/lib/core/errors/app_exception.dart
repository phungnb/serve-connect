import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  factory AppException.fromDio(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final mappedMessage = _mapMessage(statusCode, exception);
    return AppException(mappedMessage, statusCode: statusCode);
  }

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  static String _mapMessage(int? statusCode, DioException exception) {
    if (exception.type == DioExceptionType.connectionError || exception.type == DioExceptionType.connectionTimeout || exception.type == DioExceptionType.receiveTimeout || exception.type == DioExceptionType.sendTimeout) {
      return 'Unable to connect to server';
    }

    switch (statusCode) {
      case 401:
        return 'Invalid email or password';
      case 403:
        return "You don't have permission";
      case 404:
        return 'Requested resource not found';
      case 500:
        return 'Server error. Please try again later';
      default:
        return exception.response?.data is Map<String, dynamic>
            ? (exception.response?.data as Map<String, dynamic>)['error']?.toString() ?? 'Something went wrong'
            : 'Something went wrong';
    }
  }
}