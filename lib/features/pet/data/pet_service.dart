// lib/features/pet/data/pet_service.dart

import '../domain/pet_info.dart';

abstract class PetService {
  Future<PetInfo> getPetInfo(String petId);

  Future<PetInfo> createPetInfo(PetInfo petInfo);

  Future<PetInfo> updatePetInfo(String petId, PetInfo petInfo);

  Future<void> deletePetInfo(String petId);

  Future<List<PetInfo>> getPetList();
}
