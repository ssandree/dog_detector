import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pet_info.dart';
import 'pet_provider.dart';

/// 현재 선택된 반려동물 정보 Provider
/// Pet 목록의 첫 번째 반려동물을 현재 반려동물로 사용
final currentPetProvider = Provider<PetInfo?>((ref) {
  final petsAsync = ref.watch(petProvider);
  
  return petsAsync.when(
    data: (pets) => pets.isNotEmpty ? pets.first : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

