import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/widgets/base_scaffold.dart';
import '../../core/config/app_colors.dart';
import 'home/manager_home_screen.dart';
import 'calendar/calendar_screen.dart';
import 'realtime/realtime_screen.dart';
import 'setting/setting_screen.dart';

/// 메인 네비게이션 위젯
/// 하단 네비게이션 바와 화면 전환을 관리합니다.
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentScreen = _buildCurrentScreen();
    final bottomNav = BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
    );

    /// 홈 화면 콘텐츠
    switch (_currentIndex) {
      case 0:
        return BaseScaffold(
          title: '홈',
          showNotification: true,
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );
      /// 실시간 모니터링 화면 콘텐츠
      case 1:
        return BaseScaffold(
          title: '실시간 모니터링',
          showNotification: true,
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );
      /// 캘린더 화면 콘텐츠
      case 2:
        return BaseScaffold(
          title: '캘린더',
          showNotification: true,
          bottomNavigationBar: bottomNav,
          body: currentScreen,
        );
      /// 설정 화면 콘텐츠
      case 3:
        return SettingScreen(bottomNavigationBar: bottomNav);

      default:
        return BaseScaffold(body: currentScreen, bottomNavigationBar: bottomNav);
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const ManagerHomeScreen();
      case 1:
        return const RealtimeScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const SizedBox.shrink(); // SettingScreen은 case 3에서 직접 처리
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 하단 네비게이션 바 위젯
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.bottomNavSelectedColor,
      unselectedItemColor: AppColors.bottomNavUnselectedColor,
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
          icon: Icon(Icons.calendar_today),
          label: '캘린더',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
    );
  }
}

