import 'package:flutter/material.dart';
import '../../core/index_export.dart';
import 'widgets/simple_description.dart';
import 'widgets/mainscreen_buttons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _topSectionAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _modeButtonsAnimation;
  
  bool _showModeButtons = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _topSectionAnimation = Tween<double>(
      begin: 0.0,
      end: -60.0, // 위로 너무 올라가면 잘리니까 60 정도만 이동
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _buttonOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _modeButtonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    ));
  }

  void _onStartButtonPressed() {
    setState(() {
      _showModeButtons = true;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.beige2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 중앙 섹션
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: _topSectionAnimation,
                  builder: (context, _) {
                    return Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: Offset(0, _topSectionAnimation.value),
                        child: Center(
                          child: SimpleDescription(animation: _topSectionAnimation),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 버튼 섹션 - 고정 높이로 오버플로우 방지
              SizedBox(
                height: 320, // 충분한 고정 높이 (버튼 2개 + 간격 + 여유공간)
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.12),
                      child: ModeSelectionSection(
                        buttonOpacityAnimation: _buttonOpacityAnimation,
                        modeButtonsAnimation: _modeButtonsAnimation,
                        showModeButtons: _showModeButtons,
                        onStartButtonPressed: _onStartButtonPressed,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
