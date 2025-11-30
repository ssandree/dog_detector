// lib/features/auth/providers/signup_controller.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class SignupState {
  final bool isLoading;
  final String? errorMessage;

  const SignupState({
    this.isLoading = false,
    this.errorMessage,
  });

  SignupState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory SignupState.initial() => const SignupState();
}

class SignupController extends AsyncNotifier<SignupState> {
  @override
  Future<SignupState> build() async {
    return SignupState.initial();
  }

  Dio get _dio => ref.read(dioProvider);

  Future<bool> signUp({
    required String username,
    required String name,
    required int age,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    state = AsyncData(
      state.value!.copyWith(isLoading: true, errorMessage: null),
    );

    try {
      final res = await _dio.post(
        ApiEndpoints.signup,
        data: {
          "username": username,
          "email": email,
          "password": password,
          "name": name,
          "age": age,
          "phone_number": phoneNumber,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        state = AsyncData(
          state.value!.copyWith(isLoading: false),
        );
        return true;
      }

      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: '회원가입에 실패했습니다. 다시 시도해 주세요.',
        ),
      );
      return false;
    } on DioException catch (e) {
      String msg = '입력 정보를 다시 확인해 주세요.';
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data['detail'] is String) {
          msg = data['detail'];
        } else if (data['detail'] is List) {
          final List errors = data['detail'];
          if (errors.isNotEmpty && errors.first is Map) {
            msg = errors.first['msg'] ?? msg;
          } else if (errors.isNotEmpty) {
            msg = errors.first.toString();
          }
        }
      } else if (data is String) {
        msg = data;
      }

      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: msg,
        ),
      );
      return false;
    } catch (_) {
      state = AsyncData(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: '네트워크 오류가 발생했습니다.',
        ),
      );
      return false;
    }
  }
}

final signupControllerProvider =
    AsyncNotifierProvider<SignupController, SignupState>(
  SignupController.new,
);
