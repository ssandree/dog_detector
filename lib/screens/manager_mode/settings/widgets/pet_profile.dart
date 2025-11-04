import '../../../../core/index_export.dart';
import '../../../../models/pet_info.dart';
import '../../../register/pet_regi_screen.dart';

class PetProfile extends ConsumerWidget {
  const PetProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petInfo = ref.watch(currentPetProvider);
    return GestureDetector(
      onTap: petInfo == null ? () => _navigateToPetRegistration(context) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.beige3,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: petInfo == null ? Border.all(color: AppColors.white, width: 2) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'lib/config/logo.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    petInfo?.name ?? '강아지 등록하기',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                      color: petInfo == null ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buildPetInfoText(petInfo),
                    style: TextStyle(
                      fontSize: 12, 
                      color: petInfo == null ? AppColors.white : AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (petInfo != null)
              TextButton(
                onPressed: () => _navigateToPetRegistration(context),
                child: const Text('정보 수정하기'),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.green6,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  String _buildPetInfoText(PetInfo? petInfo) {
    if (petInfo == null) {
      return '클릭하여 강아지 정보를 등록해주세요';
    }
    
    String info = '';
    
    if (petInfo.age != null) {
      info += '나이  ${petInfo.age}살';
    }
    
    if (petInfo.weight > 0) {
      if (info.isNotEmpty) info += '    ';
      info += '몸무게  ${petInfo.weight}kg';
    }
    
    if (petInfo.birthday != null) {
      if (info.isNotEmpty) info += '\n';
      info += '생일  ${petInfo.birthday!.year}.${petInfo.birthday!.month.toString().padLeft(2, '0')}.${petInfo.birthday!.day.toString().padLeft(2, '0')}';
    }
    
    return info.isEmpty ? '정보 없음' : info;
  }

  void _navigateToPetRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetRegiScreen(),
      ),
    );
  }
}
