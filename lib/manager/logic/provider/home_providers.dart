// lib/manager/provider/home_providers.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/pet/application/current_pet_provider.dart';
import '../../../features/pet/domain/pet_info.dart';

final homeCurrentPetProvider = Provider<PetInfo?>((ref) {
  return ref.watch(currentPetProvider);
});
