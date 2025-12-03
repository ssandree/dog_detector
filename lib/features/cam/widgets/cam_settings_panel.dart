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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "CAM Mode 설정",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const Text(
            "저장 공간 현황",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const StoragePieChart(),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              context.go("/mode-select");
            },
            child: const Text("모드 재선택"),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              await ref.read(appPrefsProvider.notifier).setAccessToken(null);
              context.go("/login");
            },
            child: const Text("로그아웃"),
          ),
        ],
      ),
    );
  }
}
