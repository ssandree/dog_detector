// lib/features/pet/application/pet_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/pet_info.dart';
import '../data/remote_pet_service.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/storage/app_prefs_provider.dart';
import '../../../core/storage/app_prefs_state.dart';

class PetNotifier extends Notifier<AsyncValue<List<PetInfo>>> {
  String? _lastToken;

  @override
  AsyncValue<List<PetInfo>> build() {
    // 토큰 변경 감지: 토큰이 없거나 변경되면 리셋
    final prefsAsync = ref.watch(appPrefsProvider);
    
    // 토큰 변경 감지를 위한 리스너
    ref.listen<AsyncValue<AppPrefsState>>(appPrefsProvider, (previous, next) {
      next.whenData((prefs) {
        final currentToken = prefs.accessToken;
        
        // 토큰이 없거나 변경되었으면 리셋
        if (currentToken == null || currentToken.isEmpty) {
          if (_lastToken != null) {
            // 이전에 토큰이 있었는데 지금 없으면 리셋
            _lastToken = null;
            state = const AsyncValue.data([]);
          }
          return;
        }
        
        // 토큰이 변경되었으면 다시 로드
        if (_lastToken != currentToken) {
          _lastToken = currentToken;
          Future.microtask(_loadPetList);
        }
      });
    });
    
    // 초기 상태: 토큰이 없으면 빈 리스트, 있으면 로딩
    return prefsAsync.when(
      data: (prefs) {
        final token = prefs.accessToken;
        _lastToken = token;
        
        if (token == null || token.isEmpty) {
          return const AsyncValue.data([]);
        }
        Future.microtask(_loadPetList);
        return const AsyncValue.loading();
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
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

  /// 로그아웃 시 명시적으로 리셋
  void reset() {
    state = const AsyncValue.data([]);
  }
}

final petProvider =
    NotifierProvider<PetNotifier, AsyncValue<List<PetInfo>>>(PetNotifier.new);
