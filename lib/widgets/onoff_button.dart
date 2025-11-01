import '../core/index_export.dart';

/// 공통 On/Off 토글 버튼
/// - 디자인 기준: 어두운 회색(ON), 연한 회색(OFF) 배경에 흰색 핸들
/// - 크기 조절 가능: width/height
class OnOffButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final bool enabled;

  const OnOffButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 42, // 80% of 52
    this.height = 22, // 80% of 28
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final double handleSize = height - 6; // 내부 여백 3px 양쪽
    final Alignment handleAlign = value ? Alignment.centerRight : Alignment.centerLeft;
    final Color trackColor = enabled
        ? (value ? AppColors.grey8 : AppColors.grey4)
        : AppColors.grey3;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: AppConstants.fastAnimationDuration,
        curve: Curves.easeOut,
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(height),
        ),
        child: AnimatedAlign(
          duration: AppConstants.fastAnimationDuration,
          alignment: handleAlign,
          curve: Curves.easeOut,
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey7,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


