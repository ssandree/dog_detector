import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});

  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen> {
  int _currentIndex = 1; // 실시간 탭이 두 번째

  final List<Widget> _screens = [
    const _HomeContent(),
    const _RealtimeContent(),
    const _ReportContent(),
    const _CalendarContent(),
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
        title: const Text('홈'),
        backgroundColor: Colors.blue[100],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'HOME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '강아지 통증탐지+감정탐지 앱',
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

class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("리포트"),
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "일별"),
              Tab(text: "주별"),
              Tab(text: "월별"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('일별 리포트')),
            Center(child: Text('주별 리포트')),
            Center(child: Text('월별 리포트')),
          ],
        ),
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        backgroundColor: Colors.purple[100],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 100,
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              'CALENDAR',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '일정 및 기록 관리',
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
