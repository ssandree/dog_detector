// lib/features/pet/application/current_pet_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/pet_info.dart';
import 'pet_provider.dart';

final currentPetProvider = Provider<PetInfo?>((ref) {
  final petsAsync = ref.watch(petProvider);
  
  return petsAsync.when(
    data: (pets) => pets.isNotEmpty ? pets.first : null,
    loading: () => null,
    error: (_, __) => null,
  );
});
