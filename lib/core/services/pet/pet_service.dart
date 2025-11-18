import '../../../models/pet_info.dart';

/// 반려동물 정보 관련 비즈니스 로직을 처리하는 Service 인터페이스
/// 
/// 역할:
/// - 데이터 소스(API/Mock)와 통신
/// - LocalStorageRepository를 통해 로컬 저장
/// - Mock 데이터를 Model로 변환
/// - 에러를 적절한 Exception으로 변환
abstract class PetService {
  /// 반려동물 정보 조회
  /// 
  /// [petId]: 반려동물 ID (현재는 사용하지 않음, 로컬 저장소에서 가져옴)
  /// 반환값: PetInfo 객체
  /// 예외: NetworkException, DataException
  Future<PetInfo> getPetInfo(String petId);

  /// 반려동물 정보 등록
  /// 
  /// [petInfo]: 등록할 반려동물 정보
  /// 반환값: 생성된 PetInfo 객체 (서버에서 생성된 ID 등 포함)
  /// 예외: NetworkException, ValidationException
  Future<PetInfo> createPetInfo(PetInfo petInfo);

  /// 반려동물 정보 수정
  /// 
  /// [petId]: 반려동물 ID
  /// [petInfo]: 수정할 반려동물 정보
  /// 반환값: 수정된 PetInfo 객체
  /// 예외: NetworkException, ValidationException
  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo);

  /// 반려동물 정보 삭제
  /// 
  /// [petId]: 반려동물 ID (현재는 사용하지 않음)
  /// 예외: NetworkException
  Future<void> deletePetInfo(String petId);

  /// 반려동물 목록 조회
  /// 
  /// 반환값: PetInfo 리스트
  /// 예외: NetworkException, DataException
  Future<List<PetInfo>> getPetList();
}

