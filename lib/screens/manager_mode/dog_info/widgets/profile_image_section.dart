import '../../../../core/index_export.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.beige3,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppColors.grey5, width: 2),
            ),
            child: const Icon(
              Icons.pets,
              size: 60,
              color: AppColors.grey7,
            ),
          ),
          AppConstants.h12,
          TextButton(
            onPressed: () {
              // TODO: 이미지 선택 기능 구현
              AppToast.info(context, '이미지 선택 기능은 추후 구현됩니다.');
            },
            child: const Text('프로필 사진 추가'),
          ),
        ],
      ),
    );
  }
}

