import '../../../core/index_export.dart';
import '../report/report_screen.dart';
import '../calendar/calendar_screen.dart';
import '../realtime/realtime_screen.dart';
import 'widgets/pet_greeting_card.dart';
import 'widgets/emotion_graph_card.dart';
import 'widgets/ai_recommendation_card.dart';
import 'widgets/weather_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _reportTabController;

  @override
  void initState() {
    super.initState();
    _reportTabController = TabController(length: 2, vsync: this);
    _reportTabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_reportTabController.indexIsChanging) {
      // 탭 변경이 완료된 후에만 Provider 업데이트
      ref.read(reportTabProvider.notifier).changeTab(_reportTabController.index);
    }
  }

  @override
  void dispose() {
    _reportTabController.removeListener(_onTabChanged);
    _reportTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider 상태 변경 시 TabController 동기화
    final currentTab = ref.watch(reportTabProvider);
    if (_reportTabController.index != currentTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _reportTabController.index != currentTab) {
          _reportTabController.animateTo(currentTab);
        }
      });
    }
    final currentScreen = _buildCurrentScreen();
    final bottomNav = BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
    );

    final statusBarHeight = MediaQuery.of(context).padding.top;

    switch (_currentIndex) {
      case 0:
        return CollapsibleScaffold(
          headerTitle: '견심술',
          headerHeight: statusBarHeight + 80,
          headerActions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.blackAppBarTextColor),
              onPressed: () => context.push(AppRoutes.notification),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.blackAppBarTextColor),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );

      case 1:
        return CollapsibleScaffold(
          headerTitle: '실시간 모니터링',
          headerHeight: statusBarHeight + 80,
          headerActions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.blackAppBarTextColor),
              onPressed: () => context.push(AppRoutes.notification),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );

      case 2:
        return CollapsibleScaffold(
          headerTitle: '분석리포트',
          headerHeight: statusBarHeight + 80 + kTextTabBarHeight + 16,
          header: _buildReportHeader(context),
          fillRemaining: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );

      case 3:
        return CollapsibleScaffold(
          headerTitle: '캘린더',
          headerHeight: statusBarHeight + 80,
          headerActions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.blackAppBarTextColor),
              onPressed: () => context.push(AppRoutes.notification),
            ),
          ],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );

      default:
        return BaseScaffold(body: currentScreen, bottomNavigationBar: bottomNav);
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const _HomeContent();
      case 1:
        return const RealtimeScreen();
      case 2:
        return const ReportScreen();
      case 3:
        return const CalendarScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReportHeader(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타이틀과 알림 아이콘을 한 줄로 배치
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '분석리포트',
                    style: TextStyle(
                      color: AppColors.blackAppBarTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.appBarTitleFontSize,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: AppColors.blackAppBarTextColor),
                    onPressed: () => context.push(AppRoutes.notification),
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _reportTabController,
            indicatorColor: AppColors.blackAppBarTextColor,
            labelColor: AppColors.blackAppBarTextColor,
            unselectedLabelColor: AppColors.blackAppBarTextColor.withValues(alpha: 0.6),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [Tab(text: '일별'), Tab(text: '주별')],
          ),
          AppConstants.h16,
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        PetGreetingCard(),
        AppConstants.h16,
        EmotionGraphCard(),
        AppConstants.h16,
        AIRecommendationCard(),
        AppConstants.h16,
        WeatherCard(),
      ],
    );
  }
}
