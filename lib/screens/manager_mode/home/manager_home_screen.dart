import 'package:flutter/material.dart';
import '../../../core/index_export.dart';
import '../settings/setting_screen.dart';
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
    return BaseScaffold(
      showAppBar: false,
      body: _buildScreens()[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;
  const _HomeContent({required this.onNavigateTab});

@override
Widget build(BuildContext context) {
  return Container(
    color: AppColors.white,
    child: SafeArea(
      child: Column(
        children: [
          // 간단한 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '견심술',
                  style: TextStyle(
                    color: AppColors.grey12,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // 알림 기능
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                        color: AppColors.grey8,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        AppUtils.navigateTo(context, const SettingScreen());
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
          // 스크롤 가능한 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  // 1. 강아지 인사 카드 (설정 버튼 포함)
                  const PetGreetingCard(),
                  const SizedBox(height: 16),
                  
                  // 2. 최근 24시간 감정 그래프
                  const EmotionGraphCard(),
                  const SizedBox(height: 16),
                  
                  // 3. AI 추천 액션 카드
                  const AIRecommendationCard(),
                  const SizedBox(height: 16),
                  
                  // 4. 날씨 정보 카드
                  const WeatherCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}