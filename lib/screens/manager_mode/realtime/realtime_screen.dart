import 'package:flutter/material.dart';
import '../realtime/widgets/video_player_section.dart';
import '../realtime/widgets/detect_timelist.dart';
import '../realtime/widgets/state_summary.dart';
import '../../../core/index_export.dart';

class RealtimeScreen extends StatelessWidget {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RealtimeContent();
  }
}


class _RealtimeContent extends StatelessWidget {
  const _RealtimeContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNav.withNotification(
        title: '실시간 모니터링',
        showBackButton: false,
        onNotificationPressed: () {
          // 알림 기능
        },
      ),
      body: Column(
        children: [
          // 비디오 플레이어 영역
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: const VideoPlayerSection(),
          ),
          
          // 실시간 분석 섹션
          Expanded(
            child: AppCards.basic(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.grey[50],
              child: Column(
                children: [
                  // 헤더
                  Row(
                    children: [
                      const Text(
                        '실시간 분석',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.swap_vert,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                  
                  // 분석 리스트
                  Expanded(
                    child: const DetectTimelist(),
                  ),
                  
                  // 하단 상태 요약
                  const StateSummary(
                    emotion: '편안함',
                    emoji: '😊',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

