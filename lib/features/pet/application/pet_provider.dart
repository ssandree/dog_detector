// lib/features/pet/application/pet_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/pet_info.dart';
import '../data/remote_pet_service.dart';
import '../../../core/error/exceptions.dart';

class PetNotifier extends Notifier<AsyncValue<List<PetInfo>>> {
  @override
  AsyncValue<List<PetInfo>> build() {
    Future.microtask(_loadPetList);
    return const AsyncValue.loading();
  }

  Future<void> _loadPetList() async {
    try {
      state = const AsyncValue.loading();
      final service = ref.read(remotePetServiceProvider);
      final pets = await service.getPetList();
      state = AsyncValue.data(pets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<PetInfo> getPetInfo(String petId) async {
    try {
      final service = ref.read(remotePetServiceProvider);
      return await service.getPetInfo(petId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 정보를 불러오는데 실패했습니다: $e');
    }
  }

  Future<PetInfo> createPetInfo(PetInfo info) async {
    try {
      final service = ref.read(remotePetServiceProvider);
      final created = await service.createPetInfo(info);
      await _loadPetList();
      return created;
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 등록에 실패했습니다: $e');
    }
  }

  Future<PetInfo> updatePetInfo(String petId, PetInfo info) async {
    try {
      final service = ref.read(remotePetServiceProvider);
      final updated = await service.updatePetInfo(petId, info);
      await _loadPetList();
      return updated;
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 수정에 실패했습니다: $e');
    }
  }

  Future<void> deletePetInfo(String petId) async {
    try {
      final service = ref.read(remotePetServiceProvider);
      await service.deletePetInfo(petId);
      await _loadPetList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw Exception('반려동물 삭제에 실패했습니다: $e');
    }
  }

  Future<void> refresh() async {
    await _loadPetList();
  }
}

final petProvider =
    NotifierProvider<PetNotifier, AsyncValue<List<PetInfo>>>(PetNotifier.new);
