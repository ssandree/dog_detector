import '../../../../core/index_export.dart';

/// 강아지 프로필 카드
class PetProfileCard extends ConsumerWidget {
  const PetProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petInfo = ref.watch(currentPetProvider);
    
    return AppCards.basic(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.beige3,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey5, width: 2),
            ),
            child: const Center(
              child: Text(
                '🐕',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petInfo?.name ?? '강아지',
                  style: const TextStyle(
                    fontSize: AppConstants.titleFontSize - 4,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey12,
                  ),
                ),
                if (petInfo?.breed != null) ...[
                  AppConstants.h4,
                  Text(
                    petInfo!.breed!,
                    style: const TextStyle(
                      fontSize: AppConstants.smallFontSize + 2,
                      color: AppColors.grey8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

