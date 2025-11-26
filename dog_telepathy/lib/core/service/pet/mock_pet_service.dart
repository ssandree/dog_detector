import '../../models/pet_info.dart';
import '../../exceptions.dart';
import '../../data/pet_mock.dart';
import 'pet_service.dart';

class MockPetService implements PetService {
  int _mockIdCounter = 1000; // 서버처럼 증가시키기

  MockPetService();

  @override
  Future<List<PetInfo>> getPetList() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock 데이터를 PetInfo 모델로 변환
    return mockPetList.map((json) => PetInfo.fromJson(json)).toList();
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
    await Future.delayed(const Duration(milliseconds: 300));

    final created = info.copyWith(
      petId: _mockIdCounter++,
      userId: 1,
    );

    return created;
  }

  @override
  Future<PetInfo> updatePetInfo(String petId, PetInfo info) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = info.copyWith(
      petId: int.tryParse(petId),
      userId: 1,
    );

    return updated;
  }

  @override
  Future<void> deletePetInfo(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
