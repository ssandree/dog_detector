/// 앱 전체에서 사용하는 커스텀 Exception 클래스들

/// 기본 앱 Exception
/// 모든 커스텀 Exception의 기본 클래스
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

/// 네트워크 관련 Exception
/// API 호출 실패, 타임아웃, 연결 오류 등
class NetworkException extends AppException {
  NetworkException(
    String message, [
    Object? originalError,
  ]) : super(message, 'NETWORK_ERROR', originalError);
}

/// 데이터 관련 Exception
/// JSON 파싱 실패, 데이터 형식 오류 등
class DataException extends AppException {
  DataException(
    String message, [
    Object? originalError,
  ]) : super(message, 'DATA_ERROR', originalError);
}

/// 검증 관련 Exception
/// 입력값 검증 실패 등
class ValidationException extends AppException {
  ValidationException(
    String message, [
    Object? originalError,
  ]) : super(message, 'VALIDATION_ERROR', originalError);
}

/// 인증 관련 Exception
/// 로그인 실패, 토큰 만료 등
class AuthException extends AppException {
  AuthException(
    String message, [
    Object? originalError,
  ]) : super(message, 'AUTH_ERROR', originalError);
}

