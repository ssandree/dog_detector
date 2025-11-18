import '../../../core/index_export.dart';

/// 페이지 인디케이터 위젯
/// 현재 페이지를 시각적으로 표시하는 점(dot) 인디케이터입니다.
class PageIndicator extends StatelessWidget {
  /// 총 페이지 수
  final int totalPages;
  
  /// 현재 페이지 인덱스 (0부터 시작)
  final int currentPage;

  const PageIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: AppConstants.defaultAnimationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 16 : 8, // 활성 페이지는 더 길게
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.appBarColor : AppColors.grey3,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

