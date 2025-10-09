import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav.dart';
import '../../mode_selection/mode_select_screen.dart';
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
    return Scaffold(
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
      appBar: AppBar(
        title: const Text('매니저모드'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ModeSelectScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정 기능은 준비 중입니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF64B5F6),
            ],
          ),
        ),
        child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.analytics,
              size: 100,
                color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
                '매니저모드',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            ),
            SizedBox(height: 10),
            Text(
                '데이터 분석 및 관리',
              style: TextStyle(
                fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '실시간 분석, 리포트, 캘린더 기능을\n하단 탭에서 확인하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
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

class _RealtimeContent extends StatelessWidget {
  const _RealtimeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 분석'),
        backgroundColor: Colors.green[100],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'REALTIME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '실시간 통증 및 감정 분석',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


