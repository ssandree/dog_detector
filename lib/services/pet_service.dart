import '../models/pet_info.dart';
import '../data/pet_mock.dart';
import '../data/pet_mock_converter.dart';
import '../core/exceptions.dart';

/// 반려동물 정보 관련 비즈니스 로직을 처리하는 Service
/// 
/// 역할:
/// - 데이터 소스(API/Mock)와 통신
/// - Mock 데이터를 Model로 변환
/// - 에러를 적절한 Exception으로 변환
class PetService {
  /// 반려동물 정보 조회
  /// 
  /// [petId]: 반려동물 ID
  /// 반환값: PetInfo 객체
  /// 예외: NetworkException, DataException
  Future<PetInfo> getPetInfo(String petId) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      
      // Mock 데이터에서 첫 번째 항목 사용
      if (mockPet.isEmpty) {
        return PetMockConverter.createDefault();
      }
      
      return PetMockConverter.fromMockData(mockPet[0]);
    } on AppException {
      rethrow; // AppException은 그대로 전달
    } catch (e) {
      throw NetworkException(
        '반려동물 정보를 불러오는데 실패했습니다',
        e,
      );
    }
  }

  /// 반려동물 정보 등록
  /// 
  /// [petInfo]: 등록할 반려동물 정보
  /// 반환값: 생성된 PetInfo 객체 (서버에서 생성된 ID 등 포함)
  /// 예외: NetworkException, ValidationException
  Future<PetInfo> createPetInfo(PetInfo petInfo) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      
      // Mock: 생성된 PetInfo 반환 (실제로는 서버에서 생성된 ID 등이 포함됨)
      return petInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '반려동물 정보를 등록하는데 실패했습니다',
        e,
      );
    }
  }

  /// 반려동물 정보 수정
  /// 
  /// [petId]: 반려동물 ID
  /// [petInfo]: 수정할 반려동물 정보
  /// 반환값: 수정된 PetInfo 객체
  /// 예외: NetworkException, ValidationException
  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      
      // Mock: 업데이트된 PetInfo 반환
      return petInfo;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '반려동물 정보를 수정하는데 실패했습니다',
        e,
      );
    }
  }

  /// 반려동물 정보 삭제
  /// 
  /// [petId]: 반려동물 ID
  /// 예외: NetworkException
  Future<void> deletePetInfo(String petId) async {
    try {
      // TODO: 실제 API 호출로 변경
      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
      
      // Mock: 삭제 완료
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        '반려동물 정보를 삭제하는데 실패했습니다',
        e,
      );
    }
  }

  /// 반려동물 목록 조회
  /// 
  /// 반환값: PetInfo 리스트
  /// 예외: NetworkException, DataException
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
