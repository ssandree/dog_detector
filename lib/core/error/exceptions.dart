// lib/core/error/exceptions.dart

class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  AppException(
    this.message, [
    this.code,
    this.originalError,
  ]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(
    String message, [
    Object? originalError,
  ]) : super(message, 'NETWORK_ERROR', originalError);
}

class DataException extends AppException {
  DataException(
    String message, [
    Object? originalError,
  ]) : super(message, 'DATA_ERROR', originalError);
}

class ValidationException extends AppException {
  ValidationException(
    String message, [
    Object? originalError,
  ]) : super(message, 'VALIDATION_ERROR', originalError);
}

class AuthException extends AppException {
  AuthException(
    String message, [
    Object? originalError,
  ]) : super(message, 'AUTH_ERROR', originalError);
}
