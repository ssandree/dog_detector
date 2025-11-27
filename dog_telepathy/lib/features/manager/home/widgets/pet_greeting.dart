import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/app_constants.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../../core/provider/pet_provider.dart';
import '../../../../core/models/pet_info.dart';
import '../../../../core/routes/app_routes.dart';

class PetGreeting extends ConsumerWidget {
  const PetGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProvider);

    // 상태에 관계없이 클릭 가능하도록 GestureDetector로 감싸기
    return GestureDetector(
      onTap: () {
        // 펫 정보가 있으면 수정 모드로, 없으면 등록 모드로 이동
        petsAsync.whenData((pets) {
          final pet = pets.isNotEmpty ? pets.first : null;
          context.push(
            AppRoutes.managerPetRegistration,
            extra: pet,
          );
        });
        // 로딩/에러 상태에서도 등록 모드로 이동
        if (!petsAsync.hasValue) {
          context.push(AppRoutes.managerPetRegistration);
        }
      },
      child: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            // 펫 정보가 없을 때
            return _buildEmptyState(context);
          } else {
            // 펫 정보가 있을 때
            final pet = pets.first;
            return _buildPetInfo(context, pet);
          }
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context),
      ),
    );
  }

  /// 펫 정보가 없을 때 UI
  Widget _buildEmptyState(BuildContext context) {
    return AppCards.basic(
        child: Row(
          children: [
            // 왼쪽: 동그란 사진
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('lib/core/image/dog_imo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppConstants.w16,
            // 오른쪽: 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '강아지 정보를 등록해주세요',
                    style: TextStyle(
                      fontSize: AppConstants.defaultFontSize,
                      color: AppColors.grey7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 펫 정보가 있을 때 UI
  Widget _buildPetInfo(BuildContext context, PetInfo pet) {
    // 나이 텍스트 생성
    String ageText = '';
    if (pet.age != null) {
      ageText = '${pet.age}세';
    } else if (pet.birthDate != null) {
      final now = DateTime.now();
      int age = now.year - pet.birthDate!.year;
      if (now.month < pet.birthDate!.month ||
          (now.month == pet.birthDate!.month && now.day < pet.birthDate!.day)) {
        age--;
      }
      ageText = '${age}세';
    }

    // 몸무게 텍스트 생성
    String weightText = '';
    if (pet.weightKg != null) {
      weightText = '${pet.weightKg}kg';
    }

    return AppCards.basic(
      child: Row(
        children: [
          // 왼쪽: 동그란 사진
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('lib/core/image/dog_imo.png'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: AppColors.grey4,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
          // 오른쪽: 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이름 (크게)
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: AppConstants.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // 나이와 몸무게 (작게)
                if (ageText.isNotEmpty || weightText.isNotEmpty)
                  Row(
                    children: [
                      if (ageText.isNotEmpty) ...[
                        Text(
                          ageText,
                          style: TextStyle(
                            fontSize: AppConstants.defaultFontSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (weightText.isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: AppConstants.defaultFontSize,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                      if (weightText.isNotEmpty)
                        Text(
                          weightText,
                          style: TextStyle(
                            fontSize: AppConstants.defaultFontSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return AppCards.basic(
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
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
    return AppCards.basic(
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey2,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppConstants.defaultSpacing),
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
}

