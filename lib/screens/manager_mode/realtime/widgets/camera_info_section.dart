import '../../../../core/index_export.dart';

/// 카메라 정보 섹션
/// 강아지가 보인 시간과 카메라 총 가동 시간을 표시합니다.
class CameraInfoSection extends StatelessWidget {
  final String cameraId;
  final Duration dogVisibleDuration;
  final Duration cameraTotalDuration;

  const CameraInfoSection({
    super.key,
    required this.cameraId,
    required this.dogVisibleDuration,
    required this.cameraTotalDuration,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videocam,
                size: 20,
                color: AppColors.green6,
              ),
              const SizedBox(width: 8),
              Text(
                '카메라 $cameraId',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.pets,
            label: '강아지가 보인 시간',
            value: _formatDuration(dogVisibleDuration),
            color: AppColors.green6,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.access_time,
            label: '카메라 총 가동 시간',
            value: _formatDuration(cameraTotalDuration),
            color: AppColors.grey7,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.circularBorderRadius - 30),
          ),
          child: Icon(
            icon,
            size: AppConstants.defaultIconSize - 4,
            color: color,
          ),
        ),
        const SizedBox(width: AppConstants.defaultSpacing - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize + 2,
                  color: AppColors.grey7,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

