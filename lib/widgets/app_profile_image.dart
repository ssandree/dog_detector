import 'package:cached_network_image/cached_network_image.dart';
import '../core/index_export.dart';

/// 프로필 이미지 통합 컴포넌트
class AppProfileImage extends StatelessWidget {
  /// 이미지 URL
  final String? imageUrl;
  
  /// 원형 크기
  final double size;
  
  /// 탭 콜백
  final VoidCallback? onTap;
  
  /// 텍스트 표시 여부 (파일명 초기 등)
  final bool showAddButton;
  
  /// 테두리 색상
  final Color? borderColor;
  
  /// 테두리 두께
  final double borderWidth;

  const AppProfileImage({
    super.key,
    this.imageUrl,
    this.size = 120.0,
    this.onTap,
    this.showAddButton = true,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // cached_network_image를 사용하여 네트워크 이미지 로딩 및 캐싱 처리
    // 자동으로 로딩 상태, 에러 상태, 플레이스홀더를 관리합니다.
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // 이미지 로딩 중 표시할 플레이스홀더
          placeholder: (context, url) => _buildLoadingPlaceholder(),
          // 이미지 로딩 실패 시 표시할 에러 위젯
          errorWidget: (context, url, error) => _buildPlaceholder(),
          // 메모리 캐시 활성화 (기본값: true)
          memCacheWidth: size.toInt(),
          memCacheHeight: size.toInt(),
        ),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: borderColor ?? AppColors.grey5,
            width: borderWidth,
          ),
        ),
        child: imageWidget,
      ),
    );
  }

  /// 로딩 중 표시할 플레이스홀더
  /// cached_network_image가 자동으로 호출하는 콜백입니다.
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.grey3,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.green6),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.beige3,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.pets,
            size: size * 0.5,
            color: AppColors.grey7,
          ),
          if (showAddButton)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.green6,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: borderWidth,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 작은 프로필 이미지 (리스트 등에서 사용)
  factory AppProfileImage.small({
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return AppProfileImage(
      imageUrl: imageUrl,
      size: 56.0,
      onTap: onTap,
      showAddButton: false,
    );
  }

  /// 중간 프로필 이미지
  factory AppProfileImage.medium({
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return AppProfileImage(
      imageUrl: imageUrl,
      size: 80.0,
      onTap: onTap,
      showAddButton: false,
    );
  }

  /// 큰 프로필 이미지
  factory AppProfileImage.large({
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return AppProfileImage(
      imageUrl: imageUrl,
      size: 120.0,
      onTap: onTap,
    );
  }
}

