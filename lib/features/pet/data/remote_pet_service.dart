// lib/features/pet/data/remote_pet_service.dart

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/error/exceptions.dart';
import '../domain/pet_info.dart';
import 'pet_service.dart';

final remotePetServiceProvider = Provider<PetService>((ref) {
  final dio = ref.watch(apiDioProvider);
  return RemotePetService(dio);
});

class RemotePetService implements PetService {
  final Dio _dio;

  RemotePetService(this._dio);

  @override
  Future<List<PetInfo>> getPetList() async {
    try {
      final response = await _dio.get('/pets/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final pets = data.map((e) => PetInfo.fromJson(e)).toList();
        return pets;
      }
      throw NetworkException("반려동물 목록 조회 실패");
    } on DioException catch (e) {
      throw _handleDioError(e, "반려동물 목록을 불러오는데 실패했습니다");
    }
  }

  @override
  Future<PetInfo> getPetInfo(String petId) async {
    try {
      final list = await getPetList();
      if (list.isEmpty) {
        throw DataException("등록된 반려동물이 없습니다");
      }

      if (petId == "current" || int.tryParse(petId) == null) {
        return list.first;
      }

      final id = int.parse(petId);
      return list.firstWhere(
        (p) => p.petId == id,
        orElse: () => list.first,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DataException("반려동물 정보를 불러오는데 실패했습니다", e);
    }
  }

  @override
  Future<PetInfo> createPetInfo(PetInfo info) async {
    try {
      final response = await _dio.post('/pets/', data: info.toApiJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PetInfo.fromJson(response.data);
      }

      throw NetworkException("반려동물 등록 실패");
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final detail = e.response?.data["detail"] as List?;
        final message = detail != null && detail.isNotEmpty
            ? detail[0]["msg"] ?? "입력값을 확인해주세요"
            : "입력값을 확인해주세요";

        throw ValidationException(message);
      }

      throw _handleDioError(e, "반려동물 등록에 실패했습니다");
    }
  }

  @override
  Future<PetInfo> updatePetInfo(String petId, PetInfo info) async {
    try {
      final id = int.parse(petId);

      final response = await _dio.put('/pets/$id', data: info.toApiJson());

      if (response.statusCode == 200) {
        return PetInfo.fromJson(response.data);
      }

      throw NetworkException("반려동물 수정 실패");
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final detail = e.response?.data["detail"] as List?;
        final message = detail != null && detail.isNotEmpty
            ? detail[0]["msg"] ?? "입력값을 확인해주세요"
            : "입력값을 확인해주세요";

        throw ValidationException(message);
      }

      throw _handleDioError(e, "반려동물 수정에 실패했습니다");
    }
  }

  @override
  Future<void> deletePetInfo(String petId) async {
    try {
      final id = int.parse(petId);
      final response = await _dio.delete('/pets/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException("반려동물 삭제 실패");
      }
    } on DioException catch (e) {
      throw _handleDioError(e, "반려동물 삭제에 실패했습니다");
    }
  }

  AppException _handleDioError(DioException e, String defaultMsg) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException("서버 응답 지연", e);
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkException("서버에 연결할 수 없습니다", e);
    }

    if (e.response != null) {
      final code = e.response!.statusCode;

      if (code == 401) {
        return AuthException("인증이 필요합니다", e);
      }
      if (code == 404) {
        return NetworkException("리소스를 찾을 수 없습니다", e);
      }
      if (code != null && code >= 500) {
        return NetworkException("서버 오류 발생", e);
      }
    }

    return NetworkException(defaultMsg, e);
  }
}
