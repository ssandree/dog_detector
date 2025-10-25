import '../models/pet_info.dart';

class PetService {
  // 실제 백엔드 API 연동 시 구현할 메서드들
  // 현재는 Mock 데이터를 반환하도록 구현

  Future<PetInfo> getPetInfo(String petId) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // Mock 데이터 반환
    return PetInfo(
      name: '멍멍이',
      age: 3,
      birthday: DateTime.now().subtract(const Duration(days: 365 * 3)),
      weight: 5.5,
      breed: '골든리트리버',
      gender: '수컷',
      photoUrl: null,
    );
  }

  Future<PetInfo> createPetInfo(PetInfo petInfo) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // Mock: 생성된 PetInfo 반환 (실제로는 서버에서 생성된 ID 등이 포함됨)
    return petInfo;
  }

  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // Mock: 업데이트된 PetInfo 반환
    return petInfo;
  }

  Future<void> deletePetInfo(String petId) async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // Mock: 삭제 완료
  }

  // 반려동물 목록 조회 (여러 마리 등록 시 사용)
  Future<List<PetInfo>> getPetList() async {
    // TODO: 실제 API 호출로 변경
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // Mock 데이터 반환
    return [
      PetInfo(
        name: '멍멍이',
        age: 3,
        birthday: DateTime.now().subtract(const Duration(days: 365 * 3)),
        weight: 5.5,
        breed: '골든리트리버',
        gender: '수컷',
        photoUrl: null,
      ),
      PetInfo(
        name: '야옹이',
        age: 2,
        birthday: DateTime.now().subtract(const Duration(days: 365 * 2)),
        weight: 3.2,
        breed: '페르시안',
        gender: '암컷',
        photoUrl: null,
      ),
    ];
  }
}
