import '../../../core/index_export.dart';

class PlaceholderCamera extends StatelessWidget {
  final bool loading;
  final String? error;

  const PlaceholderCamera({super.key, this.loading = false, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.white)
            else if (error != null)
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              )
            else
              Icon(
                Icons.camera_alt,
                size: 80,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              loading ? '카메라 초기화 중...' : error ?? '카메라 프리뷰',
              style: TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (error == null && !loading) ...[
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                '강아지를 카메라에 비춰주세요',
                style: TextStyle(
                  fontSize: AppConstants.smallFontSize + 2,
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


