import '../../../../core/index_export.dart';

/// 빈 상태 위젯 (탐지된 영상이 없을 때)
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off,
            size: 64,
            color: AppColors.grey6,
          ),
          AppConstants.h16,
          Text(
            '탐지된 영상이 없습니다',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize,
              color: AppColors.grey8,
            ),
          ),
        ],
      ),
    );
  }
}

