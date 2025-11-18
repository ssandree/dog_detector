import 'dart:convert';
import '../../../models/pet_info.dart';
import '../../../data/pet_mock.dart';
import '../../../data/pet_mock_converter.dart';
import '../../exceptions.dart';
import '../../storage/local_storage_keys.dart';
import '../../storage/local_storage_repository.dart';
import 'pet_service.dart';

/// Mock 반려동물 서비스 구현체
/// API 없이도 동작하는 가짜 구현체
class MockPetService implements PetService {
  final LocalStorageRepository _storage;

  MockPetService(this._storage);

  @override
  Future<PetInfo> getPetInfo(String petId) async {
    try {
      // 로컬 저장소에서 먼저 조회
      final petInfoJson = await _storage.loadString(LocalStorageKeys.petInfo);
      if (petInfoJson != null && petInfoJson.isNotEmpty) {
        try {
          final petInfoMap = jsonDecode(petInfoJson) as Map<String, dynamic>;
          return PetInfo.fromJson(petInfoMap);
        } catch (e) {
          // JSON 파싱 실패 시 mock 데이터 사용
        }
      }
      
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 로컬에 저장된 정보가 없으면 mock 데이터 사용
      if (mockPet.isEmpty) {
        return PetMockConverter.createDefault();
      }
      
      return PetMockConverter.fromMockData(mockPet[0]);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '반려동물 정보를 불러오는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<PetInfo> createPetInfo(PetInfo petInfo) async {
    try {
      // TODO: 실제 API 호출로 변경
      // final response = await dio.post('/pets/', data: petInfo.toApiJson());
      // final createdPetInfo = PetInfo.fromJson(response.data);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: 생성된 PetInfo 반환 (실제로는 서버에서 생성된 ID 등이 포함됨)
      final createdPetInfo = petInfo.copyWith(
        petId: 1, // Mock ID
        userId: 1, // Mock User ID
      );
      
      // 로컬 저장소에 저장
      final petInfoJson = jsonEncode(createdPetInfo.toJson());
      await _storage.saveString(LocalStorageKeys.petInfo, petInfoJson);
      
      return createdPetInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '반려동물 정보를 등록하는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo) async {
    try {
      // TODO: 실제 API 호출로 변경
      // final petIdInt = int.parse(petId);
      // final response = await dio.put('/pets/$petIdInt', data: petInfo.toApiJson());
      // final updatedPetInfo = PetInfo.fromJson(response.data);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: 업데이트된 PetInfo 반환 (petId 유지)
      final updatedPetInfo = petInfo.copyWith(
        petId: petInfo.petId ?? int.tryParse(petId),
      );
      
      // 로컬 저장소에 저장
      final petInfoJson = jsonEncode(updatedPetInfo.toJson());
      await _storage.saveString(LocalStorageKeys.petInfo, petInfoJson);
      
      return updatedPetInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '반려동물 정보를 수정하는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<void> deletePetInfo(String petId) async {
    try {
      // 로컬 저장소에서 삭제
      await _storage.remove(LocalStorageKeys.petInfo);
      
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock: 삭제 완료
    } on AppException {
      rethrow;
    } catch (e) {
      throw DataException(
        '반려동물 정보를 삭제하는데 실패했습니다',
        e,
      );
    }
  }

  @override
  Future<List<PetInfo>> getPetList() async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      
      // Mock 데이터를 Model로 변환
      return PetMockConverter.fromMockDataList(mockPet);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '반려동물 목록을 불러오는데 실패했습니다',
        e,
      );
    }
  }
}

