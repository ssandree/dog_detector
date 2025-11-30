// lib/features/home/widgets/pet_greeting.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dog_telepathy/core/config/app_constants.dart';
import 'package:dog_telepathy/core/config/app_colors.dart';
import 'package:dog_telepathy/core/widgets/app_cards.dart';
import 'package:dog_telepathy/features/pet/domain/pet_info.dart';
import 'package:dog_telepathy/features/pet/application/pet_provider.dart';
import 'package:dog_telepathy/features/pet/presentation/pet_regi_modal.dart';

class PetGreeting extends ConsumerWidget {
  const PetGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProvider);

    return petsAsync.when(
      data: (pets) {
        final PetInfo? pet = pets.isNotEmpty ? pets.first : null;

        return _buildPetCard(context, pet);
      },
      loading: () => _loading(),
      error: (_, __) => _error(),
    );
  }

  Widget _buildPetCard(BuildContext context, PetInfo? pet) {
    const cardPadding = EdgeInsets.all(12);

    return AppCards.basic(
      padding: cardPadding,
      child: Stack(
        children: [
          pet == null ? _emptyBody() : _petInfoBody(pet),
          Positioned(
            top: 0,
            right: 0,
            child: TextButton(
              onPressed: () => showPetRegiModal(
                context,
                existingPetInfo: pet,
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('수정하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBody() {
    return Padding(
      padding: const EdgeInsets.only(right: 60),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _avatar(),
          ),
          AppConstants.w16,
          const Expanded(
            child: Text(
              '강아지 정보를 등록해주세요',
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                color: AppColors.grey7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _petInfoBody(PetInfo pet) {
    final ageText = _ageString(pet);
    final breedText = pet.breed ?? '';

    return Padding(
      padding: const EdgeInsets.only(right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _avatar(),
          ),
          SizedBox(width: AppConstants.defaultSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: AppConstants.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (ageText != null || breedText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (ageText != null) _tag(ageText),
                      if (breedText.isNotEmpty) _tag(breedText),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('lib/core/image/dog_imo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _loading() {
    return AppCards.basic(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          AppConstants.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _skeleton(120, 20),
                const SizedBox(height: 8),
                _skeleton(80, 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _error() {
    return AppCards.basic(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Icon(Icons.error_outline, color: AppColors.error),
          ),
          AppConstants.w16,
          const Expanded(
            child: Text(
              '반려동물 정보를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String? _ageString(PetInfo pet) {
    if (pet.age != null) return '${pet.age}살';

    if (pet.birthDate != null) {
      final now = DateTime.now();
      int age = now.year - pet.birthDate!.year;
      final beforeBirthday = now.month < pet.birthDate!.month ||
          (now.month == pet.birthDate!.month &&
              now.day < pet.birthDate!.day);

      if (beforeBirthday) age--;
      return '${age}살';
    }

    return null;
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppConstants.circularBorderRadius),
        border: Border.all(color: AppColors.grey4, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppConstants.smallFontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }
}
