import 'package:flutter/material.dart';
import '../camera_mode/home_screen.dart' as camera_home;
import '../manager_mode/(tabs)/home_screen.dart' as manager_home;

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              
              // 강아지 로고
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'lib/config/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              
              // 환영 메시지
              const Text(
                '민호님, 환영합니다!',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),
              
              // 안내 문구
              const Text(
                '시작할 모드를 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 50),
              
              // 캠모드 버튼
              _buildModeButton(
                context: context,
                title: '캠 모드',
                icon: Icons.videocam,
                backgroundColor: const Color(0xFF81C784),
                iconColor: const Color(0xFF1976D2),
                textColor: const Color(0xFF673AB7),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const camera_home.HomeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              
              // 매니저모드 버튼
              _buildModeButton(
                context: context,
                title: '매니저 모드',
                icon: Icons.bar_chart,
                backgroundColor: const Color(0xFFFFE082),
                iconColor: const Color(0xFFFF9800),
                textColor: const Color(0xFF8D6E63),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const manager_home.HomeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(height: 10),
            
            // 텍스트
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            
            // 설명 텍스트
            Text(
              title == '캠 모드' ? '강아지를 촬영하는 모드' : '견심술 탐지 결과를 보고 관리하는 모드',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}