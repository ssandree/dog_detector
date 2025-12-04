// lib/features/cam/widgets/cam_settings_panel.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/app_prefs_provider.dart';
import '../widgets/storage_pie_chart.dart';

class CamSettingsPanel extends ConsumerWidget {
  const CamSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "CAM Mode 설정",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 28),

          const Text( 
            "저장 공간 현황",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const StoragePieChart(),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              onPressed: () {
                context.go("/mode-select");
              },
              child: const Text("모드 재선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: TextButton( 
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () async {
                await ref.read(appPrefsProvider.notifier).setAccessToken(null);
                context.go("/login");
              },
              child: const Text("로그아웃", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
