import '../../../core/index_export.dart';
import '../report/report_screen.dart';
import '../calendar/calendar_screen.dart';
import '../realtime/realtime_screen.dart';
import 'widgets/pet_greeting_card.dart';
import 'widgets/emotion_graph_card.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens() => [
        _HomeContent(
          onNavigateTab: (i) => setState(() => _currentIndex = i),
        ),
        const RealtimeScreen(),
        const ReportScreen(),
        const CalendarScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final currentScreen = _buildScreens()[_currentIndex];
    final bottomNav = BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
    );

    // 홈 화면(_currentIndex == 0)일 때만 CustomScrollView 사용
    if (_currentIndex == 0) {
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final headerHeight = statusBarHeight + 80.0;
      
      return Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: bottomNav,
        body: buildCollapsingScrollView(
          headerHeight: headerHeight,
          customHeader: _buildHeader(context),
          child: currentScreen,
        ),
      );
    }

    // 다른 화면들은 BaseScaffold 사용
    return BaseScaffold(
      body: currentScreen,
      bottomNavigationBar: bottomNav,
    );
  }

  /// 🐶 Collapsing Header 위젯
  /// CustomScrollView의 SliverAppBar에 flexibleSpace로 들어가며
  /// 스크롤 시 자연스럽게 fade-out 효과가 적용됨.
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConstants.smallPadding.horizontal,
          right: AppConstants.smallPadding.horizontal,
          top: statusBarHeight,
          bottom: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '견심술',
              style: TextStyle(
                color: AppColors.grey12,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO: 알림 기능 추가
                  },
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppColors.grey8,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.push(AppRoutes.settings);
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.grey8,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈 탭 콘텐츠
/// SliverToBoxAdapter 내부에 들어가기 때문에 Column은 유한 높이만 사용 가능
class _HomeContent extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;
  const _HomeContent({required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ 무한 높이 방지
      children: const [
        PetGreetingCard(),
        SizedBox(height: 16),
        EmotionGraphCard(),
        SizedBox(height: 16),
        AIRecommendationCard(),
        SizedBox(height: 16),
        WeatherCard(),
      ],
    );
  }
}
