import 'package:flutter/material.dart';
import '../realtime/video_evidence_screen.dart';
import '../../../widgets/cards/app_cards.dart';
import '../../../constants/app_constants.dart';
import '../../../theme/app_colors.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '실시간 모니터링',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // 알림 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 비디오 플레이어 영역
          AppCards.videoPlayer(
            liveBadgeText: 'LIVE',
            overlayWidgets: [
              // 비디오 배경 (강아지 이미지 시뮬레이션)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              // LIVE 배지
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 컨트롤 버튼들
              Positioned(
                bottom: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_off,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: const SizedBox.shrink(), // 실제 비디오 위젯이 들어갈 자리
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
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildAnalysisItem(
                          icon: Icons.pets,
                          iconColor: Colors.orange,
                          text: "'편안함' 감정이 높게 나타납니다.",
                          highlightText: '편안함',
                          time: '14:08',
                          onTap: () => _openEvidence(context, '편안함', '오후 2:08에 발생'),
                        ),
                        _buildAnalysisItem(
                          icon: Icons.person,
                          iconColor: Colors.grey[700]!,
                          text: "우리 개 지금 전반적인 상태가 어때?",
                          time: '14:08',
                          onTap: () => _openEvidence(context, '질문', '오후 2:08에 발생'),
                        ),
                        _buildAnalysisItem(
                          icon: Icons.pets,
                          iconColor: Colors.orange,
                          text: "'편안함' 감정이 감지되었습니다.",
                          highlightText: '편안함',
                          time: '11:37',
                          onTap: () => _openEvidence(context, '편안함', '오전 11:37에 발생'),
                        ),
                        _buildAnalysisItem(
                          icon: Icons.notification_important,
                          iconColor: Colors.orange,
                          text: "음성 메시지를 전달했습니다.",
                          time: '11:36',
                          onTap: () => _openEvidence(context, '메시지', '오전 11:36에 발생'),
                        ),
                        _buildAnalysisItem(
                          icon: Icons.pets,
                          iconColor: Colors.orange,
                          text: "'불안함' 감정이 감지되었습니다.",
                          highlightText: '불안함',
                          time: '09:22',
                          onTap: () => _openEvidence(context, '불안함', '오전 9:22에 발생'),
                        ),
                      ],
                    ),
                  ),
                  
                  // 하단 상태 요약
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '😊',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: TextSpan(
                            text: "현재 반려견은 '",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '편안함',
                                style: TextStyle(
                                  color: Colors.blue[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: "' 상태입니다.",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String time,
    String? highlightText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: highlightText != null
                ? RichText(
                    text: TextSpan(
                      text: text.replaceAll("'$highlightText'", ''),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "'$highlightText'",
                          style: TextStyle(
                            color: Colors.blue[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " [$time]",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    '$text [$time]',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
          ),
          ],
        ),
      ),
    );
  }

  void _openEvidence(BuildContext context, String emotionName, String timeText) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => VideoEvidenceScreen(
          emotionName: emotionName,
          timeText: timeText,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child),
          );
        },
      ),
    );
  }
}

