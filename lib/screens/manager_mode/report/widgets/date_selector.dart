import '../../../../core/index_export.dart';

class DateSelector extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const DateSelector({
    super.key,
    required this.title,
    required this.subtitle,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: AppConstants.appBarIconSize),
          onPressed: onPrevious,
        ),
        Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.titleFontSize - 6,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: AppColors.grey6,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: AppConstants.appBarIconSize),
          onPressed: onNext,
        ),
      ],
    );
  }
}
