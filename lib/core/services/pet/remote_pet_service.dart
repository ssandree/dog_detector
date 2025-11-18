import '../../../models/pet_info.dart';
import 'pet_service.dart';

/// Remote 반려동물 서비스 구현체
/// 실제 API 호출하는 구현체
class RemotePetService implements PetService {
  @override
  Future<PetInfo> getPetInfo(String petId) {
    throw UnimplementedError();
  }

  @override
  Future<PetInfo> createPetInfo(PetInfo petInfo) {
    throw UnimplementedError();
  }

  @override
  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo) {
    throw UnimplementedError();
  }

  @override
  Future<void> deletePetInfo(String petId) {
    throw UnimplementedError();
  }

  @override
  Future<List<PetInfo>> getPetList() {
    throw UnimplementedError();
  }
}

