// lib/features/home/application/home_providers.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../pet/application/current_pet_provider.dart';
import '../../pet/domain/pet_info.dart';

final homeCurrentPetProvider = Provider<PetInfo?>((ref) {
  return ref.watch(currentPetProvider);
});
