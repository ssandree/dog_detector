// lib/core/network/api_endpoints.dart

class ApiEndpoints {
  static const baseUrl = 'http://54.206.79.248:8000';
  static const connectTimeout = Duration(milliseconds: 15000);
  static const receiveTimeout = Duration(milliseconds: 15000);

  static const login = '/token';
  static const register = '/users/register';
}
