import 'package:flutter/material.dart';
import '../../../core/index_export.dart';

class ModeSelectionSection extends StatelessWidget {
final Animation<double> buttonOpacityAnimation;
final Animation<double> modeButtonsAnimation;
final bool showModeButtons;
final VoidCallback onStartButtonPressed;

const ModeSelectionSection({
   super.key,
   required this.buttonOpacityAnimation,
   required this.modeButtonsAnimation,
   required this.showModeButtons,
   required this.onStartButtonPressed,
});

@override
Widget build(BuildContext context) {
   return AnimatedBuilder(
      animation: buttonOpacityAnimation,
      builder: (context, _) {
      return Stack(
         alignment: Alignment.center,
         children: [
            /// 시작하기 버튼
            Opacity(
            opacity: buttonOpacityAnimation.value,
            child: AppButtons.primary(
               width: MediaQuery.of(context).size.width * 0.6,
               height: 60,
               text: '시작하기',
               onPressed: onStartButtonPressed,
            ),
            ),

            /// 모드 선택 버튼들
            if (showModeButtons)
            AnimatedBuilder(
               animation: modeButtonsAnimation,
               builder: (context, _) {
                  return Opacity(
                  opacity: modeButtonsAnimation.value,
                   child: Transform.translate(
                        offset: Offset(
                           0, 40 * (1 - modeButtonsAnimation.value) - 50), // 10픽셀 아래로 조정
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           AppButtons.secondary(
                              text: '캠 모드',
                              icon: Icons.videocam,
                              height: 100,
                              subtitle: '강아지를 촬영하는 모드',
                              onPressed: () {
                              Navigator.pushNamed(
                                    context, AppRoutes.cameraHome);
                              },
                           ),
                           const SizedBox(height: 20),
                           AppButtons.primary(
                              text: '매니저 모드',
                              icon: Icons.bar_chart,
                              height: 100,
                              subtitle: '견심술 탐지 결과를 보고 관리하는 모드',
                              onPressed: () {
                              Navigator.pushNamed(
                                    context, AppRoutes.managerHome);
                              },
                           ),
                        ],
                        ),
                     ),
                   );
               },
            ),
         ],
      );
      },
   );
}
}
