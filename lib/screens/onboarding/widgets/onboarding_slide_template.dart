import '../../../core/index_export.dart';

class OnboardingSlideTemplate extends StatelessWidget {
  const OnboardingSlideTemplate({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  final String imageAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppCards.basic(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            child: Image.asset(
              imageAsset,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          AppConstants.h24,
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppConstants.titleFontSize - 2,
              fontWeight: FontWeight.bold,
              color: AppColors.grey12,
            ),
          ),
          AppConstants.h16,
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppConstants.defaultFontSize - 1,
              color: AppColors.grey7,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

