import '../../../core/index_export.dart';
import 'widgets/pet_greeting_card.dart';
import 'widgets/emotion_gauge_card.dart';

/// 홈 화면 콘텐츠
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.beige1, // 베이지색 배경
            AppColors.beige2,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PetGreetingCard(),
            AppConstants.h16,
            EmotionGaugeCard(),
            AppConstants.h32,
          ],
        ),
      ),
    );
  }
}
