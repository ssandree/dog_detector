import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/pet_info.dart';
import '../services/pet_service.dart';
import 'mode_provider.dart';

/// PetInfo 상태를 관리하는 Notifier
/// 
/// 역할:
/// - UI 상태 관리 (AsyncValue)
/// - Service를 호출하여 데이터 가져오기
/// - 상태 변경 시 UI 자동 업데이트
class PetNotifier extends Notifier<AsyncValue<PetInfo?>> {
  late final PetService _petService;

  @override
  AsyncValue<PetInfo?> build() {
    _petService = ref.watch(petServiceProvider);
    // 초기화 시 저장된 반려동물 정보 로드
    loadPetInfo();
    return const AsyncValue.data(null);
  }

  /// 반려동물 정보 로드
  /// Service를 호출하여 데이터를 가져오고 상태를 업데이트합니다.
  /// 
  /// 현재는 첫 번째 반려동물을 가져옵니다.
  /// TODO: 여러 마리 반려동물 지원 시 선택된 반려동물 ID 사용
  Future<void> loadPetInfo([String? petId]) async {
    state = const AsyncValue.loading();
    try {
      // petId가 없으면 첫 번째 반려동물 사용 (현재는 단일 반려동물만 지원)
      final targetPetId = petId ?? 'current';
      final petInfo = await _petService.getPetInfo(targetPetId);
      state = AsyncValue.data(petInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 반려동물 정보 등록
  /// Service를 호출하여 데이터를 생성하고 상태를 업데이트합니다.
  Future<void> createPetInfo(PetInfo petInfo) async {
    state = const AsyncValue.loading();
    try {
      final createdPetInfo = await _petService.createPetInfo(petInfo);
      state = AsyncValue.data(createdPetInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 반려동물 정보 업데이트
  /// Service를 호출하여 데이터를 수정하고 상태를 업데이트합니다.
  Future<void> updatePetInfo(String petId, PetInfo petInfo) async {
    state = const AsyncValue.loading();
    try {
      final updatedPetInfo = await _petService.updatePetInfo(petId, petInfo);
      state = AsyncValue.data(updatedPetInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 반려동물 정보 삭제
  /// Service를 호출하여 데이터를 삭제하고 상태를 업데이트합니다.
  Future<void> deletePetInfo(String petId) async {
    state = const AsyncValue.loading();
    try {
      await _petService.deletePetInfo(petId);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 반려동물 정보 초기화
  /// 상태를 null로 초기화합니다.
  void clearPetInfo() {
    state = const AsyncValue.data(null);
  }
}

/// 반려동물 목록 상태를 관리하는 Notifier
/// 
/// 역할:
/// - 반려동물 목록 상태 관리
/// - Service를 호출하여 목록 가져오기
class PetListNotifier extends Notifier<AsyncValue<List<PetInfo>>> {
  late final PetService _petService;

  @override
  AsyncValue<List<PetInfo>> build() {
    _petService = ref.watch(petServiceProvider);
    // 초기화 시 목록 로드
    loadPetList();
    return const AsyncValue.loading();
  }

  /// 반려동물 목록 조회
  /// Service를 호출하여 목록을 가져오고 상태를 업데이트합니다.
  Future<void> loadPetList() async {
    state = const AsyncValue.loading();
    try {
      final petList = await _petService.getPetList();
      state = AsyncValue.data(petList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 반려동물 목록 새로고침
  /// 목록을 다시 로드합니다.
  Future<void> refreshPetList() async {
    await loadPetList();
  }
}

/// PetService Provider (싱글톤)
/// Service 인스턴스를 생성하여 재사용합니다.
final petServiceProvider = Provider<PetService>((ref) {
  final storage = ref.watch(localStorageRepositoryProvider);
  return PetService(storage);
});

/// PetInfo 상태를 관리하는 Provider
/// PetService를 주입받아 사용합니다.
final petProvider = NotifierProvider<PetNotifier, AsyncValue<PetInfo?>>(PetNotifier.new);

/// 반려동물 목록 상태를 관리하는 Provider
/// PetService를 주입받아 사용합니다.
final petListProvider = NotifierProvider<PetListNotifier, AsyncValue<List<PetInfo>>>(PetListNotifier.new);

/// 현재 반려동물 정보를 쉽게 접근하기 위한 Provider
final currentPetProvider = Provider<PetInfo?>((ref) {
  final petState = ref.watch(petProvider);
  return petState.value;
});

/// 반려동물 목록을 쉽게 접근하기 위한 Provider
final currentPetListProvider = Provider<List<PetInfo>>((ref) {
  final petListState = ref.watch(petListProvider);
  return petListState.value ?? [];
});

