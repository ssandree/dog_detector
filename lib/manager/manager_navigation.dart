import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

import '../../core/widgets/base_scaffold.dart';
import '../../core/config/app_colors.dart';

import 'manager_home/home_screen.dart';
import 'realtime/realtime_screen.dart';
import 'event_timeline/event_timeline_screen.dart';
import 'calendar/calendar_screen.dart';
import 'manager_home/widgets/manager_settings_panel.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final GoRouterState? state;

  const MainNavigation({super.key, this.state});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0; // 기본값으로 초기화
  DateTime? _initialTimelineDate;

  @override
  void initState() {
    super.initState();
    _updateFromQueryParams(useSetState: false);
  }

  @override
  void didUpdateWidget(MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // query parameter가 변경되었을 때 업데이트
    final oldDateStr = oldWidget.state?.uri.queryParameters['date'];
    final newDateStr = widget.state?.uri.queryParameters['date'];
    if (oldDateStr != newDateStr) {
      _updateFromQueryParams(useSetState: true);
    }
  }

  void _updateFromQueryParams({required bool useSetState}) {
    // URL query parameter에서 날짜 확인
    final dateStr = widget.state?.uri.queryParameters['date'];
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        if (useSetState && mounted) {
          setState(() {
            _initialTimelineDate = date;
            _currentIndex = 2; // 타임라인 탭으로 설정
          });
        } else {
          _initialTimelineDate = date;
          _currentIndex = 2; // 타임라인 탭으로 설정
        }
      } catch (e) {
        if (useSetState && mounted) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          _currentIndex = 0;
        }
      }
    } else {
      // date 파라미터가 없으면 현재 탭 유지 (이미 탭에 있다면)
      if (_currentIndex == 2 && _initialTimelineDate != null) {
        // 타임라인 탭에 있지만 date 파라미터가 사라진 경우는 그대로 유지
        return;
      }
      // 초기 로드 시에만 홈으로 설정
      if (useSetState && mounted) {
        setState(() {
          _currentIndex = 0;
        });
      } else {
        _currentIndex = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = _buildCurrentScreen();
    final titles = ['홈', '실시간 모니터링', '타임라인', '캘린더'];

    return BaseScaffold(
      title: titles[_currentIndex],
      body: screen,
      showNotification: true,
      bottomNavigationBar: _buildBottomNav(),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            _showSettingsPanel(context);
          },
        ),
      ],
    );
  }

  /// ----------------------------------------
  /// BODY SCREEN
  /// ----------------------------------------
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const RealtimeScreen();
      case 2:
        return EventTimelineTabScreen(initialDate: _initialTimelineDate);
      case 3:
        return const CalendarScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  /// ----------------------------------------
  /// BOTTOM NAVIGATION
  /// ----------------------------------------
  Widget _buildBottomNav() {
    return SizedBox(
      height: 70.h,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.bottomNavSelectedColor,
        unselectedItemColor: AppColors.bottomNavUnselectedColor,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '실시간',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '타임라인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
        ],
      ),
    );
  }

  /// ----------------------------------------
  /// SETTINGS PANEL
  /// ----------------------------------------
  void _showSettingsPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '설정',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const ManagerSettingsPanel();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: Align(
            alignment: Alignment.centerRight,
            child: child,
          ),
        );
      },
    );
  }
}
