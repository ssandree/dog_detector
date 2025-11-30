// lib/features/home/widgets/manager_settings_panel.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_constants.dart';

class ManagerSettingsPanel extends StatelessWidget {
  const ManagerSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: EdgeInsets.all(AppConstants.defaultSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            "설정",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          _settingItem(Icons.notifications, "알림 설정"),
          _settingItem(Icons.person, "반려동물 정보"),
          _settingItem(Icons.analytics, "AI 분석 기록"),
          _settingItem(Icons.logout, "로그아웃"),
        ],
      ),
    );
  }

  Widget _settingItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
