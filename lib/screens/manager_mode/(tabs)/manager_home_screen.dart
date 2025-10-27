import 'package:flutter/material.dart';
import '../../../core/index_export.dart';
import '../../main/main_screen.dart';
import 'report_screen.dart';
import 'calendar_screen.dart';
import 'realtime_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const RealtimeScreen(),
    const ReportScreen(),
    const CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showAppBar: false,
      body: _screens[_currentIndex],
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
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNav.managerMode(
        title: '매니저모드',
        onBackPressed: () {
          AppUtils.navigateTo(
            context,
            const MainScreen(),
            replace: true,
          );
        },
        onSettingsPressed: () {
          AppUtils.showComingSoonMessage(context, feature: '설정');
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryAppBarColor,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics,
                size: 100,
                color: AppColors.white,
              ),
              SizedBox(height: 20),
              Text(
                '매니저모드',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '데이터 분석 및 관리',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color(0xB3FFFFFF), // AppColors.white.withOpacity(0.7)
                ),
              ),
              SizedBox(height: 20),
              Text(
                '실시간 분석, 리포트, 캘린더 기능을\n하단 탭에서 확인하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0x99FFFFFF), // AppColors.white.withOpacity(0.6)
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

