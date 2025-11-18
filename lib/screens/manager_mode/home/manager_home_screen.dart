import '../../../core/index_export.dart';
import 'widgets/pet_profile_card.dart';
import 'widgets/recent_detection_card.dart';
import 'widgets/emotion_tags_card.dart';
import 'widgets/video_list_card.dart';

/// 홈 화면 콘텐츠
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          PetProfileCard(),
          AppConstants.h16,
          RecentDetectionCard(),
          AppConstants.h16,
          EmotionTagsCard(),
          AppConstants.h16,
          VideoListCard(),
          AppConstants.h16,
        ],
      ),
    );
  }
}
