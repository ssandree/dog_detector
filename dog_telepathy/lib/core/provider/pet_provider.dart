import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pet_info.dart';
import '../service/pet/pet_service.dart';
import '../service/pet/mock_pet_service.dart';
import '../service/pet/remote_pet_service.dart';
import '../exceptions.dart';

/// PetService provider
/// Mock/Remote 서비스 전환을 위해 사용
final petServiceProvider = Provider<PetService>((ref) {
  const useMock = bool.fromEnvironment('USE_MOCK_PET_SERVICE', defaultValue: false);
  return useMock ? MockPetService() : RemotePetService();
});

/// Pet 목록을 관리하는 Notifier
class PetNotifier extends Notifier<AsyncValue<List<PetInfo>>> {
  @override
  AsyncValue<List<PetInfo>> build() {
    _loadPetList();
    return const AsyncValue.loading();
  }

  Future<void> _loadPetList() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(petServiceProvider);
      final pets = await service.getPetList();
      state = AsyncValue.data(pets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 반려동물 정보 조회
  Future<PetInfo> getPetInfo(String petId) async {
    try {
      final service = ref.read(petServiceProvider);
      return await service.getPetInfo(petId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 정보를 불러오는데 실패했습니다: $e');
    }
  }

  /// 반려동물 정보 생성
  Future<PetInfo> createPetInfo(PetInfo info) async {
    try {
      final service = ref.read(petServiceProvider);
      final created = await service.createPetInfo(info);
      // 목록 새로고침
      await _loadPetList();
      return created;
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 등록에 실패했습니다: $e');
    }
  }

  /// 반려동물 정보 수정
  Future<PetInfo> updatePetInfo(String petId, PetInfo info) async {
    try {
      final service = ref.read(petServiceProvider);
      final updated = await service.updatePetInfo(petId, info);
      // 목록 새로고침
      await _loadPetList();
      return updated;
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 수정에 실패했습니다: $e');
    }
  }

  /// 반려동물 정보 삭제
  Future<void> deletePetInfo(String petId) async {
    try {
      final service = ref.read(petServiceProvider);
      await service.deletePetInfo(petId);
      // 목록 새로고침
      await _loadPetList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 삭제에 실패했습니다: $e');
    }
  }

  /// 목록 새로고침
  Future<void> refresh() async {
    await _loadPetList();
  }
}

/// Pet 목록 Provider
final petProvider = NotifierProvider<PetNotifier, AsyncValue<List<PetInfo>>>(PetNotifier.new);

