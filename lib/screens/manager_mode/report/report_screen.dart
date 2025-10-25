import 'package:flutter/material.dart';
import '../report/daily_report.dart';
import '../report/weekly_report.dart';
import '../../../core/index_export.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    
    // 탭과 페이지 동기화
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav.withTabBar(
        title: '실시간 분석',
        showBackButton: false,
        tabController: _tabController,
        tabs: const [
          Tab(text: '일별'),
          Tab(text: '주별'),
        ],
        backgroundColor: Colors.grey[100],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: [
          const DailyReport(),
          const WeeklyReport(),
        ],
      ),
    );
  }
}
