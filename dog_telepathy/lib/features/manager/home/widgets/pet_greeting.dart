import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/app_constants.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/models/pet_info.dart';
import '../../../../core/provider/pet_provider.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../../core/widgets/app_status_tags.dart';
import '../../pet_regi/pet_regi_modal.dart';

class PetGreeting extends ConsumerWidget {
  const PetGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProvider);

    return petsAsync.when(
      data: (pets) {
        final pet = pets.isNotEmpty ? pets.first : null;
        return _buildPetCard(context, pet);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildPetCard(
    BuildContext context,
    PetInfo? pet,
  ) {
    const cardPadding = EdgeInsets.all(12);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Stack(
          children: [
            if (pet == null)
              _buildEmptyBody(cardPadding)
            else
              _buildPetInfoBody(pet, cardPadding),
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
      ),
    );
  }

  Widget _buildEmptyBody(EdgeInsets cardPadding) {
    return Padding(
      padding: const EdgeInsets.only(right: 60),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('lib/core/image/dog_imo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          AppConstants.w16,
          Expanded(
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

  Widget _buildPetInfoBody(
    PetInfo pet,
    EdgeInsets cardPadding,
  ) {
    String ageText = '';
    if (pet.age != null) {
      ageText = '${pet.age}살';
    } else if (pet.birthDate != null) {
      final now = DateTime.now();
      int age = now.year - pet.birthDate!.year;
      if (now.month < pet.birthDate!.month ||
          (now.month == pet.birthDate!.month && now.day < pet.birthDate!.day)) {
        age--;
      }
      ageText = '${age}살';
    }

    final breedText = pet.breed ?? '';

    return Padding(
      padding: const EdgeInsets.only(right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('lib/core/image/dog_imo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                if (ageText.isNotEmpty || breedText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (ageText.isNotEmpty)
                        _buildSmallTag(ageText),
                      if (breedText.isNotEmpty)
                        _buildSmallTag(breedText),
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


  /// 로딩 상태 UI
  Widget _buildLoadingState(BuildContext context) {
    return _buildSkeletonCard(
      context,
      body: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          SizedBox(width: AppConstants.defaultSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grey2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState(BuildContext context) {
    return _buildSkeletonCard(
      context,
      body: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: AppConstants.defaultSpacing),
          Expanded(
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

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius),
        border: Border.all(
          color: AppColors.grey4,
          width: 1,
        ),
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

  Widget _buildSkeletonCard(BuildContext context, {required Widget body}) {
    const cardPadding = EdgeInsets.all(12);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Stack(
          children: [
            body,
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: () => showPetRegiModal(
                  context,
                  existingPetInfo: null,
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
      ),
    );
  }

}
